# Ready-to-Use Formula Patterns and OCR

## Common Patterns

**Truncate text with ellipsis:**
```
{{if(length(1.description) > 100; substring(1.description; 0; 100) & "..."; 1.description)}}
```

**Safe price formatting:**
```
{{formatNumber(iferror(parseNumber(1.price; "."); 0); 2; "."; ",")}}
```

**Today's date as filename:**
```
{{formatDate(now; "YYYY-MM-DD")}}
```

**Calculate days since a date:**
```
{{dateDifference(now; 1.createdAt; "days")}}
```

**Phone number — digits only:**
```
{{replace(1.phone; /[^0-9]/g; "")}}
```

**Null-safe nested field:**
```
{{ifempty(1.address.city; "Unknown City")}}
```

**Concatenate full name:**
```
{{trim(ifempty(1.firstName; "") & " " & ifempty(1.lastName; ""))}}
```

**Convert array to comma-separated string:**
```
{{join(1.tags; ", ")}}
```

**Get first non-empty value:**
```
{{ifempty(1.preferredEmail; ifempty(1.backupEmail; 1.email))}}
```

**Sort contacts by last name:**
```
{{sortBy(1.contacts; "lastName"; "asc")}}
```

## OCR Integration

Make.com has no native OCR module. Three options:

### Option A — Google Cloud Vision (best accuracy)
1. Convert file to base64: `{{base64(1.fileContent)}}`
2. HTTP POST to `https://vision.googleapis.com/v1/images:annotate`
3. Body: `{"requests":[{"image":{"content":"{{base64(1.fileContent)}}"},"features":[{"type":"DOCUMENT_TEXT_DETECTION"}]}]}`
4. Extract text: `{{1.responses[].fullTextAnnotation.text}}`

### Option B — Azure AI Document Intelligence
1. Upload file to Azure blob or use URL
2. HTTP POST to `https://{endpoint}/formrecognizer/v2.1/layout/analyze`
3. Poll the `Operation-Location` URL for result
4. Extract `analyzeResult.readResults[].lines[].text`

### Option C — Make.com OpenAI module
Use GPT-4o vision: send image URL or base64 in user message.
Fastest setup — best for structured extraction from receipts/forms.

**Gotcha:** Images over 4MB need compression. Cloud Vision limit: 10MB per request.

## Key Gotchas Summary

| Gotcha | Wrong | Correct |
|--------|-------|---------|
| `now` has no parens | `{{now()}}` | `{{now}}` |
| Semicolons, not commas | `{{fn(a, b)}}` | `{{fn(a; b)}}` |
| substring is 0-indexed | `{{substring(x; 1; 1)}}` for first char | `{{substring(x; 0; 1)}}` |
| Regex not quoted | `{{replace(x; "/\d/g"; "")}}` | `{{replace(x; /\d/g; "")}}` |
| Divide-by-zero guard | `{{divide(1.a; 1.b)}}` | `{{if(1.b = 0; 0; divide(1.a; 1.b))}}` |
| map+filter can't chain large arrays | Use nested expressions | Use Iterator module |
| `contains` is case-sensitive | `{{contains(1.status; "Active")}}` | `{{contains(lower(1.status); "active")}}` |
