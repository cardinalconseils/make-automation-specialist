# Formula Syntax Fundamentals

All expressions are wrapped in double curly braces: `{{expression}}`

## Item References

```
{{1.fieldName}}          — field from module 1
{{1.address.city}}       — nested field
{{1.items[].price}}      — array item field
{{2.body.data.id}}       — HTTP response body path
```

## Argument Separator

SEMICOLONS, not commas.
```
{{substring(1.text; 0; 100)}}    ✓ correct
{{substring(1.text, 0, 100)}}    ✗ WRONG — will error
```

## Nesting

Functions can be nested freely.
```
{{upper(trim(1.name))}}
{{if(length(1.items) > 0; first(1.items).id; "none")}}
```

## String Concatenation

Use `&` operator.
```
{{1.firstName & " " & 1.lastName}}
{{"/api/users/" & 1.userId}}
```

## Operators

**Arithmetic:** `+`, `-`, `*`, `/`, `%` (modulo)

**Comparison:** `=`, `!=`, `>`, `<`, `>=`, `<=`

**Logical:** `and`, `or`, `not`
