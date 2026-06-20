# Array, Collection, Logic, and Data Parsing Functions

## Array and Collection Functions

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
| `filter` | `filter(array; fieldName; op; value)` | array | Filters items |
| `distinct` | `distinct(array; fieldName)` | array | Removes duplicates by field |
| `flatten` | `flatten(array; depth)` | array | Flattens nested arrays |
| `reverse` | `reverse(array)` | array | Reverses order |
| `sort` | `sort(array; order)` | array | order: `asc` or `desc` |
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

**Gotcha:** `map` and `filter` cannot be chained for large datasets — use an **Iterator** module.

## Logic and Conditions

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

**Patterns:**
```
Null fallback:     {{ifempty(1.phone; "N/A")}}
Multi-case:        {{switch(1.status; "active"; "✓"; "pending"; "…"; "?")}}
Error-safe parse:  {{iferror(parseNumber(1.price; "."); 0)}}
Truthy check:      {{if(and(1.email; contains(1.email; "@")); "valid"; "invalid")}}
```

## Data Parsing

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `parseJSON` | `parseJSON(text)` | object | Parses JSON string; use `iferror` wrapper |
| `parseXML` | `parseXML(text)` | object | Parses XML string |
| `parseCSV` | `parseCSV(text)` | array | Parses CSV string to array of arrays |
| `toBoolean` | `toBoolean(value)` | boolean | "true"/"1"/true → true |
| `toString` | `toString(value)` | string | Any type to string |

**Safe JSON parse pattern:**
```
{{iferror(parseJSON(1.body); toCollection("error"; "invalid json"))}}
```
