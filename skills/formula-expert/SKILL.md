# Formula Expert Skill

Load this skill before writing any Make.com module field expressions.
It is the authoritative reference for Make.com built-in functions and expression syntax.

---

## 1. Expression Syntax Fundamentals

All expressions are wrapped in double curly braces: `{{expression}}`

**Item references** — access module output fields:
```
{{1.fieldName}}          — field from module 1
{{1.address.city}}       — nested field
{{1.items[].price}}      — array item field
{{2.body.data.id}}       — HTTP response body path
```

**Argument separator:** SEMICOLONS, not commas.
```
{{substring(1.text; 0; 100)}}    ✓ correct
{{substring(1.text, 0, 100)}}    ✗ WRONG — will error
```

**Nesting:** Functions can be nested freely.
```
{{upper(trim(1.name))}}
{{if(length(1.items) > 0; first(1.items).id; "none")}}
```

**String concatenation:** Use `&` operator.
```
{{1.firstName & " " & 1.lastName}}
{{"/api/users/" & 1.userId}}
```

**Arithmetic operators:** `+`, `-`, `*`, `/`, `%` (modulo)

**Comparison operators:** `=`, `!=`, `>`, `<`, `>=`, `<=`

**Logical operators:** `and`, `or`, `not`

---

## 2. Text Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `trim` | `trim(text)` | string | Strips leading/trailing whitespace |
| `upper` | `upper(text)` | string | Uppercases all characters |
| `lower` | `lower(text)` | string | Lowercases all characters |
| `capitalize` | `capitalize(text)` | string | First letter uppercase |
| `length` | `length(text)` | number | Character count |
| `contains` | `contains(text; search)` | boolean | Case-sensitive substring check |
| `startWith` | `startWith(text; prefix)` | boolean | Note: no 's' at end |
| `endWith` | `endWith(text; suffix)` | boolean | Note: no 's' at end |
| `indexOf` | `indexOf(text; search)` | number | 0-based position; -1 if not found |
| `substring` | `substring(text; start; length)` | string | 0-indexed start; length optional |
| `replace` | `replace(text; search; replacement)` | string | Replaces first occurrence; use regex for all |
| `split` | `split(text; delimiter)` | array | e.g. `split("a,b,c"; ",")` → `["a","b","c"]` |
| `join` | `join(array; separator)` | string | e.g. `join(1.tags; ", ")` |
| `normalize` | `normalize(text)` | string | Removes diacritics, normalizes Unicode |
| `escapeHTML` | `escapeHTML(text)` | string | Escapes `<`, `>`, `&`, `"` |
| `htmlDecode` | `htmlDecode(text)` | string | Decodes HTML entities |
| `urlEncode` | `urlEncode(text)` | string | Percent-encodes for URL use |
| `urlDecode` | `urlDecode(text)` | string | Decodes percent-encoded strings |
| `md5` | `md5(text)` | string | MD5 hash (hex) |
| `sha1` | `sha1(text)` | string | SHA-1 hash (hex) |
| `base64` | `base64(text)` | string | Base64 encodes text |
| `base64Decode` | `base64Decode(text)` | string | Decodes base64 to text |
| `formatNumber` | `formatNumber(number; decimals; decimalMark; thousandsMark)` | string | e.g. `formatNumber(1234.5; 2; "."; ",")` → `"1,234.50"` |
| `toString` | `toString(value)` | string | Converts any type to string |
| `toBinary` | `toBinary(text; encoding)` | binary | For file operations; encoding: `utf-8`, `base64`, `hex` |

**Gotchas:**
- `substring` is **0-indexed**: `{{substring("hello"; 1; 3)}}` → `"ell"`
- `contains` is case-sensitive: use `lower(text)` to normalize before checking
- `startWith` / `endWith` — missing trailing 's' is intentional in Make.com

---

## 3. Math Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `add` | `add(a; b; ...)` | number | Adds two or more numbers |
| `subtract` | `subtract(a; b)` | number | a - b |
| `multiply` | `multiply(a; b)` | number | a × b |
| `divide` | `divide(a; b)` | number | ALWAYS guard: `if(b = 0; 0; divide(a; b))` |
| `ceil` | `ceil(number)` | integer | Rounds up |
| `floor` | `floor(number)` | integer | Rounds down |
| `round` | `round(number; decimals)` | number | e.g. `round(3.14159; 2)` → `3.14` |
| `max` | `max(a; b; ...)` | number | Largest of values |
| `min` | `min(a; b; ...)` | number | Smallest of values |
| `abs` | `abs(number)` | number | Absolute value |
| `mod` | `mod(a; b)` | number | Remainder: `mod(10; 3)` → `1` |
| `average` | `average(a; b; ...)` | number | Arithmetic mean |
| `sum` | `sum(array)` | number | Sum of array values |
| `sqrt` | `sqrt(number)` | number | Square root |
| `pow` | `pow(base; exponent)` | number | e.g. `pow(2; 10)` → `1024` |
| `log` | `log(number; base)` | number | Logarithm; base optional (default 10) |
| `exp` | `exp(number)` | number | e raised to the power |
| `random` | `random()` | number | Float between 0 and 1 |
| `parseNumber` | `parseNumber(text; decimalMark)` | number | e.g. `parseNumber("1,234.50"; ".")` → `1234.5` |
| `toNumber` | `toNumber(value)` | number | Type coercion |

**Gotchas:**
- `divide(a; 0)` throws a runtime error — always guard: `{{if(1.quantity = 0; 0; divide(1.total; 1.quantity))}}`
- `parseNumber` requires explicit decimal mark if input uses comma as decimal

---

## 4. Date and Time Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `now` | `{{now}}` | timestamp | **No parentheses** — `{{now()}}` is WRONG |
| `today` | `{{today}}` | date | Current date only (no time) |
| `addDays` | `addDays(date; n)` | timestamp | n can be negative |
| `addHours` | `addHours(date; n)` | timestamp | n can be negative |
| `addMinutes` | `addMinutes(date; n)` | timestamp | |
| `addSeconds` | `addSeconds(date; n)` | timestamp | |
| `addMonths` | `addMonths(date; n)` | timestamp | n can be negative |
| `addYears` | `addYears(date; n)` | timestamp | |
| `dateDifference` | `dateDifference(date1; date2; unit)` | number | unit: `seconds`, `minutes`, `hours`, `days` |
| `formatDate` | `formatDate(date; format; timezone)` | string | timezone optional; see format codes below |
| `parseDate` | `parseDate(text; format; timezone)` | timestamp | Converts string → timestamp |
| `setHour` | `setHour(date; hour)` | timestamp | |
| `setMinute` | `setMinute(date; minute)` | timestamp | |
| `setSecond` | `setSecond(date; second)` | timestamp | |
| `setDay` | `setDay(date; day)` | timestamp | |
| `setDate` | `setDate(date; dayOfMonth)` | timestamp | |
| `setMonth` | `setMonth(date; month)` | timestamp | 1–12 |
| `setYear` | `setYear(date; year)` | timestamp | |
| `weekOfYear` | `weekOfYear(date)` | number | ISO week number 1–53 |
| `dayOfYear` | `dayOfYear(date)` | number | 1–366 |
| `dayOfMonth` | `dayOfMonth(date)` | number | 1–31 |
| `dayOfWeek` | `dayOfWeek(date)` | number | 1 (Sun) – 7 (Sat) |
| `hour` | `hour(date)` | number | 0–23 |
| `minute` | `minute(date)` | number | 0–59 |
| `second` | `second(date)` | number | 0–59 |
| `month` | `month(date)` | number | 1–12 |
| `year` | `year(date)` | number | e.g. 2026 |

**Format codes for `formatDate`:**

| Code | Meaning | Example |
|------|---------|---------|
| `YYYY` | 4-digit year | 2026 |
| `YY` | 2-digit year | 26 |
| `MM` | Month 01–12 | 06 |
| `M` | Month 1–12 | 6 |
| `MMMM` | Full month name | June |
| `MMM` | Short month name | Jun |
| `DD` | Day 01–31 | 09 |
| `D` | Day 1–31 | 9 |
| `HH` | Hour 00–23 | 14 |
| `H` | Hour 0–23 | 14 |
| `hh` | Hour 01–12 | 02 |
| `mm` | Minute 00–59 | 30 |
| `ss` | Second 00–59 | 45 |
| `A` | AM/PM | PM |
| `X` | Unix timestamp (seconds) | 1750000000 |
| `x` | Unix timestamp (ms) | 1750000000000 |

**Common patterns:**
```
ISO 8601:   {{formatDate(now; "YYYY-MM-DDTHH:mm:ss")}}
Date only:  {{formatDate(now; "YYYY-MM-DD")}}
US format:  {{formatDate(now; "MM/DD/YYYY")}}
Filename:   {{formatDate(now; "YYYY-MM-DD-HHmm")}}
```

**Gotchas:**
- `{{now}}` — NO parentheses. `{{now()}}` throws "function not found"
- `parseDate` must exactly match the input format string
- Timezones: pass IANA tz names like `"America/Toronto"`, `"UTC"`, `"Europe/Paris"`

---

## 5. Array and Collection Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `length` | `length(array)` | number | Also works on strings |
| `count` | `count(array)` | number | Same as length for arrays |
| `first` | `first(array)` | item | First element |
| `last` | `last(array)` | item | Last element |
| `get` | `get(array; index)` | item | 0-based index |
| `slice` | `slice(array; start; end)` | array | end is exclusive; 0-based |
| `merge` | `merge(array1; array2; ...)` | array | Concatenates arrays |
| `add` | `add(array; value)` | array | Returns new array with value appended |
| `remove` | `remove(array; index)` | array | 0-based index |
| `contains` | `contains(array; value)` | boolean | Checks if value exists |
| `map` | `map(array; fieldName)` | array | Plucks field from each item |
| `filter` | `filter(array; fieldName; operator; value)` | array | Filters items |
| `distinct` | `distinct(array; fieldName)` | array | Removes duplicates by field |
| `flatten` | `flatten(array; depth)` | array | Flattens nested arrays |
| `reverse` | `reverse(array)` | array | Reverses order |
| `sort` | `sort(array; order)` | array | order: `asc` or `desc`; works on primitives |
| `sortBy` | `sortBy(array; fieldName; order)` | array | Sorts object array by field |
| `toArray` | `toArray(value)` | array | Wraps a value in an array |
| `toCollection` | `toCollection(key; value)` | object | Creates `{key: value}` |
| `keys` | `keys(object)` | array | Object property names |
| `values` | `values(object)` | array | Object property values |
| `groupBy` | `groupBy(array; fieldName)` | object | Groups items by field value |
| `zip` | `zip(array1; array2)` | array | Pairs elements by index |
| `sum` | `sum(array)` | number | Sum of numeric array |
| `average` | `average(array)` | number | Mean of numeric array |
| `max` | `max(array)` | number | Largest value in array |
| `min` | `min(array)` | number | Smallest value in array |

**filter operators:** `=`, `!=`, `>`, `<`, `>=`, `<=`, `contains`, `startWith`, `endWith`

**map + filter pattern:**
```
Map to extract emails: {{map(1.contacts; "email")}}
Filter active users:   {{filter(1.users; "status"; "="; "active")}}
```

**Gotcha:** `map` and `filter` cannot be chained in a single expression for large datasets — use an **Iterator** module with a Router for complex multi-step array transforms.

---

## 6. Logic and Conditions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `if` | `if(condition; valueIfTrue; valueIfFalse)` | any | Ternary |
| `ifempty` | `ifempty(value; fallback)` | any | Returns fallback if value is empty/null |
| `switch` | `switch(value; case1; result1; ...; default)` | any | Last arg is default |
| `and` | `and(a; b; ...)` | boolean | All true |
| `or` | `or(a; b; ...)` | boolean | Any true |
| `not` | `not(value)` | boolean | Inverts boolean |
| `xor` | `xor(a; b)` | boolean | Exactly one true |
| `iferror` | `iferror(expression; fallback)` | any | Returns fallback if expression throws |

**Practical patterns:**
```
Null fallback:     {{ifempty(1.phone; "N/A")}}
Multi-case:        {{switch(1.status; "active"; "✓"; "pending"; "…"; "inactive"; "✗"; "?")}}
Nested if:         {{if(1.score >= 90; "A"; if(1.score >= 80; "B"; if(1.score >= 70; "C"; "F")))}}
Error-safe parse:  {{iferror(parseNumber(1.price; "."); 0)}}
Truthy check:      {{if(and(1.email; contains(1.email; "@")); "valid"; "invalid")}}
```

---

## 7. Data Parsing

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `parseJSON` | `parseJSON(text)` | object | Parses JSON string; use `iferror` wrapper |
| `parseXML` | `parseXML(text)` | object | Parses XML string |
| `parseCSV` | `parseCSV(text)` | array | Parses CSV string to array of arrays |
| `parseDate` | `parseDate(text; format)` | timestamp | See Section 4 |
| `parseNumber` | `parseNumber(text; decimalMark)` | number | See Section 3 |
| `toBoolean` | `toBoolean(value)` | boolean | "true"/"1"/true → true |
| `toString` | `toString(value)` | string | Any type to string |
| `toBinary` | `toBinary(text; encoding)` | binary | For file upload modules |

**Safe JSON parse pattern:**
```
{{iferror(parseJSON(1.body); toCollection("error"; "invalid json"))}}
```

---

## 8. Regex Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `regexMatch` | `regexMatch(text; /pattern/flags)` | boolean | Tests if pattern matches |
| `regexMatchAll` | `regexMatchAll(text; /pattern/flags)` | array | All matches as array |
| `replace` | `replace(text; /pattern/flags; replacement)` | string | Replace with regex |

**Regex flags:** `g` (global/all matches), `i` (case-insensitive), `m` (multiline)

**Common patterns:**
```
Strip non-numeric (phone):   {{replace(1.phone; /[^0-9]/g; "")}}
Extract digits only:         {{regexMatchAll(1.text; /\d+/g)}}
Email validation:            {{regexMatch(1.email; /^[^\s@]+@[^\s@]+\.[^\s@]+$/)}}
Remove HTML tags:            {{replace(1.html; /<[^>]*>/g; "")}}
Normalize whitespace:        {{replace(trim(1.text); /\s+/g; " ")}}
Extract between brackets:    {{regexMatchAll(1.text; /\[([^\]]+)\]/g)}}
```

**Gotcha:** The `/pattern/flags` syntax is literal — do not wrap in quotes. Write `/[^0-9]/g`, not `"/[^0-9]/g"`.

---

## 9. Encoding and Hashing

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `base64` | `base64(text)` | string | Encodes to base64 |
| `base64Decode` | `base64Decode(text)` | string | Decodes from base64 |
| `md5` | `md5(text)` | string | MD5 hex hash (not for security) |
| `sha1` | `sha1(text)` | string | SHA-1 hex hash |
| `sha256` | `sha256(text)` | string | SHA-256 hex hash |
| `hmac` | `hmac(text; secret; algorithm)` | string | algorithm: `sha1`, `sha256`, `sha512` |
| `urlEncode` | `urlEncode(text)` | string | Percent-encodes special chars |
| `urlDecode` | `urlDecode(text)` | string | Decodes percent-encoded string |

**Webhook signature verification pattern:**
```
{{hmac(1.rawBody; "your-secret"; "sha256")}}
```
Compare this to the signature in the webhook header.

---

## 10. Common Ready-to-Use Patterns

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

---

## 11. OCR Integration

Make.com does not have a native OCR module. Recommended approaches:

### Option A — Google Cloud Vision (best accuracy)
1. **Convert file to base64:** Use a Function module with `{{base64(1.fileContent)}}`
2. **HTTP POST** to `https://vision.googleapis.com/v1/images:annotate`
3. **Body structure:**
```json
{
  "requests": [{
    "image": {"content": "{{base64(1.fileContent)}}"},
    "features": [{"type": "DOCUMENT_TEXT_DETECTION"}]
  }]
}
```
4. **Extract text:** `{{1.responses[].fullTextAnnotation.text}}`

### Option B — Azure AI Document Intelligence
1. Upload file to Azure blob (or use URL)
2. **HTTP POST** to `https://{endpoint}/formrecognizer/v2.1/layout/analyze`
3. Poll the `Operation-Location` URL for result
4. Extract `analyzeResult.readResults[].lines[].text`

### Option C — Make.com OpenAI module
Use GPT-4o vision: send image URL or base64 in the user message.
Fastest setup but not a dedicated OCR — best for structured extraction from receipts/forms.

**Gotcha:** Images over 4MB need to be compressed before sending. Cloud Vision has a 10MB limit per request.

---

## 12. Key Gotchas Summary

| Gotcha | Wrong | Correct |
|--------|-------|---------|
| `now` has no parens | `{{now()}}` | `{{now}}` |
| Semicolons, not commas | `{{fn(a, b)}}` | `{{fn(a; b)}}` |
| substring is 0-indexed | `{{substring(x; 1; 1)}}` to get first char | `{{substring(x; 0; 1)}}` |
| Regex not quoted | `{{replace(x; "/\d/g"; "")}}` | `{{replace(x; /\d/g; "")}}` |
| Divide-by-zero guard | `{{divide(1.a; 1.b)}}` | `{{if(1.b = 0; 0; divide(1.a; 1.b))}}` |
| map+filter can't chain large arrays | Use nested expressions | Use Iterator module |
| `contains` is case-sensitive | `{{contains(1.status; "Active")}}` | `{{contains(lower(1.status); "active")}}` |
