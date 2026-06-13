# Secrets Handling Rules

## Mandatory Behavior

Never output the raw value of any credential. Always replace with a safe form before it
reaches the user's screen, transcript, or any file.

| Form | Example | Use when |
|---|---|---|
| Masked | `MAKE_API_KEY=***` | Default — value is irrelevant |
| Last-4 reveal | `sk_***[…m4n2]` | User must distinguish between keys |
| Named placeholder | `$MAKE_API_KEY` | Showing config structure or docs |

## What Counts as a Credential

- Environment variable values (`*_KEY`, `*_SECRET`, `*_TOKEN`, `*_PASSWORD`)
- API keys of any provider (`sk_*`, `xoxb-*`, `AIza*`, `ghp_*`, `glpat-*`)
- OAuth client secrets and refresh tokens
- JWTs and bearer tokens (`eyJ*.*.*` shape)
- Webhook signing secrets (`whsec_*`)
- Full `.env` file contents
- Make.com API keys and connection credentials
- Telnyx API keys and messaging profile tokens

## Required Behavior on Detection

1. Detect the credential pattern in input or proposed output
2. Replace the raw value with a safe form (masked by default)
3. State briefly: "Masked per secrets rule — raw value not echoed."
4. Continue the task using the masked form

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "User pasted it, fine to echo" | Transcript persists. Screenshots spread the leak. |
| "It's a test key" | Test keys authenticate. They become prod leaks when reused. |
| "Just showing format" | Use `$YOUR_KEY` placeholder. Never a real value. |
| "User asked to see it" | User can read the file directly. Claude is not the messenger. |

## Verification

- [ ] No raw credentials in any response
- [ ] Masked/last-4/placeholder forms used consistently
- [ ] Rule reference shown when masking occurs
- [ ] No exceptions applied — rule is unconditional
