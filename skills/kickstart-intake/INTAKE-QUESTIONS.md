# Intake: Discovery Interview Protocol

Part of `kickstart-intake`. See `SKILL.md` for execution order.

Sub-files:
- `INTAKE-COLLECTION.md` — per-automation data collection loop + AI detection
- `INTAKE-CLASSIFIER.md` — complexity classifier + priority ranker

---

## Opening (seed provided)

```
Great — let's start with "{seed}".

To design this properly, I need a few quick details:
- What triggers this? (A form submission, a new email, a schedule, a customer action?)
- What should happen as a result?
- Where does the output go?
```

## Opening (no seed)

```
Let's map out what you want to automate.
What's the first thing you wish happened automatically in your business?
Tell me in plain language — no technical details needed.
```

---

## After Each Automation

```
Is there anything else you'd like to automate, or shall we move on to designing these?
```

Loop until the user signals done: "that's it", "that's all", "no more", "let's go", "ready".

---

## Interview Flow

1. Open with seed or open-ended prompt above
2. For each automation: collect fields → see `INTAKE-COLLECTION.md`
3. Reflect back and confirm each automation before moving to the next
4. After all automations: classify and rank → see `INTAKE-CLASSIFIER.md`
5. Display portfolio for confirmation → see `INTAKE-OUTPUTS.md`
