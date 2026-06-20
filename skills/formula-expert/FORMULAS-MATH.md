# Math Functions

| Function | Syntax | Returns | Notes |
|----------|--------|---------|-------|
| `add` | `add(a; b; ...)` | number | Adds two or more numbers |
| `subtract` | `subtract(a; b)` | number | a - b |
| `multiply` | `multiply(a; b)` | number | a × b |
| `divide` | `divide(a; b)` | number | ALWAYS guard against zero |
| `ceil` | `ceil(number)` | integer | Rounds up |
| `floor` | `floor(number)` | integer | Rounds down |
| `round` | `round(number; decimals)` | number | `round(3.14159; 2)` → `3.14` |
| `max` | `max(a; b; ...)` | number | Largest of values |
| `min` | `min(a; b; ...)` | number | Smallest of values |
| `abs` | `abs(number)` | number | Absolute value |
| `mod` | `mod(a; b)` | number | Remainder: `mod(10; 3)` → `1` |
| `average` | `average(a; b; ...)` | number | Arithmetic mean |
| `sum` | `sum(array)` | number | Sum of array values |
| `sqrt` | `sqrt(number)` | number | Square root |
| `pow` | `pow(base; exponent)` | number | `pow(2; 10)` → `1024` |
| `log` | `log(number; base)` | number | Logarithm; base optional (default 10) |
| `exp` | `exp(number)` | number | e raised to the power |
| `random` | `random()` | number | Float between 0 and 1 |
| `parseNumber` | `parseNumber(text; decimalMark)` | number | `parseNumber("1,234.50"; ".")` → `1234.5` |
| `toNumber` | `toNumber(value)` | number | Type coercion |

## Gotchas

- `divide(a; 0)` throws a runtime error — always guard:
  ```
  {{if(1.quantity = 0; 0; divide(1.total; 1.quantity))}}
  ```
- `parseNumber` requires explicit decimal mark if input uses comma as decimal
