# Text, Encoding, Hashing, and Regex Functions

## Text Functions

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
| `replace` | `replace(text; search; replacement)` | string | First occurrence; use regex for all |
| `split` | `split(text; delimiter)` | array | `split("a,b,c"; ",")` → `["a","b","c"]` |
| `join` | `join(array; separator)` | string | `join(1.tags; ", ")` |
| `normalize` | `normalize(text)` | string | Removes diacritics, normalizes Unicode |
| `escapeHTML` | `escapeHTML(text)` | string | Escapes `<`, `>`, `&`, `"` |
| `htmlDecode` | `htmlDecode(text)` | string | Decodes HTML entities |
| `urlEncode` | `urlEncode(text)` | string | Percent-encodes for URL use |
| `urlDecode` | `urlDecode(text)` | string | Decodes percent-encoded strings |
| `toString` | `toString(value)` | string | Converts any type to string |
| `toBinary` | `toBinary(text; encoding)` | binary | encoding: `utf-8`, `base64`, `hex` |
| `formatNumber` | `formatNumber(n; dec; decMark; thouMark)` | string | `formatNumber(1234.5; 2; "."; ",")` |

**Gotchas:**
- `substring` is **0-indexed**: `{{substring("hello"; 1; 3)}}` → `"ell"`
- `contains` is case-sensitive: use `lower(text)` to normalize
- `startWith` / `endWith` — missing trailing 's' is intentional

## Encoding and Hashing

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `base64` | `base64(text)` | string | Encodes to base64 |
| `base64Decode` | `base64Decode(text)` | string | Decodes from base64 |
| `md5` | `md5(text)` | string | MD5 hex hash (not for security) |
| `sha1` | `sha1(text)` | string | SHA-1 hex hash |
| `sha256` | `sha256(text)` | string | SHA-256 hex hash |
| `hmac` | `hmac(text; secret; algorithm)` | string | algorithm: `sha1`, `sha256`, `sha512` |

**Webhook signature verification:**
```
{{hmac(1.rawBody; "your-secret"; "sha256")}}
```

## Regex Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `regexMatch` | `regexMatch(text; /pattern/flags)` | boolean | Tests if pattern matches |
| `regexMatchAll` | `regexMatchAll(text; /pattern/flags)` | array | All matches as array |
| `replace` | `replace(text; /pattern/flags; replacement)` | string | Replace with regex |

**Flags:** `g` (global), `i` (case-insensitive), `m` (multiline)

**Common patterns:**
```
Strip non-numeric:    {{replace(1.phone; /[^0-9]/g; "")}}
Extract digits:       {{regexMatchAll(1.text; /\d+/g)}}
Email validation:     {{regexMatch(1.email; /^[^\s@]+@[^\s@]+\.[^\s@]+$/)}}
Remove HTML tags:     {{replace(1.html; /<[^>]*>/g; "")}}
Normalize whitespace: {{replace(trim(1.text); /\s+/g; " ")}}
```

**Gotcha:** Write `/[^0-9]/g`, not `"/[^0-9]/g"` — regex is not a string.
