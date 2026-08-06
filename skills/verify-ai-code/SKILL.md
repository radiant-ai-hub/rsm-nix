---
name: verify-ai-code
description: Do a structured read-and-verify pass on AI-written code before the student trusts, commits, or submits it. Use when the user asks "is this right", "review this", "did it work", "can I commit this", "check the code you wrote", when they are about to commit/push AI-generated changes, or whenever code was generated that has not yet been read and confirmed by the student. Reinforces that the human owns the review and that passing tests is not proof the code is correct.
---

# verify-ai-code

The point of this skill is **critical thinking, not automation**. Help the student
actually understand and confirm AI-written code — do not just re-run it and declare
success. The student owns everything that lands under their name.

Work through these five steps in order and report each one honestly.

## 1. Read the diff

```bash
git --no-pager diff HEAD      # or `git --no-pager diff` for unstaged only
```

Walk the student through **what actually changed**, file by file. Do not summarize
from memory — read the real diff. If nothing is staged/changed, say so.

## 2. Explain each change in plain English

For every non-trivial change, state in one or two sentences: *what* it does and
*why* it's there. Use `file:line` references so the student can follow along.

> Rule of thumb: **if you can't explain a change in plain English, don't commit
> it.** Ask the student whether each part makes sense; offer `/explain <thing>` for
> anything unclear. Losing track of how your own code works is "cognitive debt."

## 3. Run the tests — and confirm they test the change

```bash
uv run pytest
```

Report pass/fail honestly. Then check: **do the tests actually cover what changed?**
A green suite that never exercises the new code proves nothing. If a new/changed
function has no test, say so and offer to add one (`/add-function` or a red/green
test-first pass: write the test, watch it fail, then confirm it passes).

## 4. Exercise it yourself — passing tests ≠ working

Run the real thing on a real input and look at the output with your own eyes:

```bash
uv run python -c "from mod import fn; print(fn(<realistic input>))"
```

For a script, run it. For an API/URL, `curl` it. Show the **actual output**, not a
claim about it. Never report "it works" unless you have just seen it work.

## 5. Check the agent's claims against reality

Coding agents write confident summaries ("done — everything passes"). Treat those
as claims to verify, not facts:

- Does the summary match the diff you just read? (Did it change files it didn't
  mention, or claim changes it didn't make?)
- Did it silently weaken or delete a test to make the suite green?
- Are there `TODO`s, stubbed returns, or hard-coded values left behind?

## Report

Give the student a short verdict:

- **What changed** (1–2 lines).
- **Verified**: tests run + result, and the manual check you actually performed.
- **Not verified / risks**: anything you could not confirm, is untested, or the
  student should look at before committing.

End by reminding the student: **you are the reviewer.** Only commit code you have
read and can explain. When in doubt, keep the change small and commit in steps
(`git` is your safety net).
