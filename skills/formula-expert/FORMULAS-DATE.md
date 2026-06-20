# Date and Time Functions

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
| `formatDate` | `formatDate(date; format; timezone)` | string | timezone optional |
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

## Format Codes for `formatDate`

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

## Common Patterns

```
ISO 8601:   {{formatDate(now; "YYYY-MM-DDTHH:mm:ss")}}
Date only:  {{formatDate(now; "YYYY-MM-DD")}}
US format:  {{formatDate(now; "MM/DD/YYYY")}}
Filename:   {{formatDate(now; "YYYY-MM-DD-HHmm")}}
```

## Gotchas

- `{{now}}` — NO parentheses. `{{now()}}` throws "function not found"
- `parseDate` must exactly match the input format string
- Timezones: pass IANA tz names like `"America/Toronto"`, `"UTC"`, `"Europe/Paris"`
