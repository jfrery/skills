---
name: hindsight-context
description: After a completed project session, improve project context so future agents reach the same result faster.
---

# Hindsight Context

After a user-accepted or verified session:

1. Compare the actual path with the shortest credible path to the result.
2. Find what was learned too late that would have avoided meaningful search, mistakes, tests, or tool calls.
3. Make at most one minimal project-local update:
   - add or rewrite a concise rule in the nearest `AGENTS.md`; or
   - add a short pointer there to a focused project `.md` file when detail is needed.
4. Prefer authoritative source locations over copied explanations. Keep `AGENTS.md` short.
5. Do not store session summaries, one-off answers, obvious facts, speculation, or volatile information.
6. Make no change unless the expected future time saved clearly exceeds the context cost and risk.
7. Commit the context update with the project work that established it.

Use global memory only for stable behavior or preferences that apply across unrelated projects.
