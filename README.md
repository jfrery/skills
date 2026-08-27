# skills

Agent skills I use day to day, kept in one place so Claude Code and Codex read
the same files instead of drifting apart.

Each skill is a directory under `skills/` containing a `SKILL.md` with YAML
frontmatter (`name`, `description`). That is the format both harnesses expect,
and it matches the Claude Code plugin layout, so this repo can be installed as a
plugin later without moving anything.

## Skills

| Skill | What it does |
|-------|--------------|
| [`research`](skills/research/SKILL.md) | Multi-step research workflow built to minimise hallucination. Decomposes the question, grounds every claim in a quoted source, cross-references, rates confidence, and self-verifies before answering. |
| [`hindsight-context`](skills/hindsight-context/SKILL.md) | Run after a session lands. Compares the path taken against the shortest credible one and makes at most one minimal update to the project's `AGENTS.md` so the next agent gets there faster. |

## Install

```sh
git clone git@github.com:jfrery/skills.git ~/skills
cd ~/skills
./install.sh --dry-run   # see the plan
./install.sh             # apply it
```

The installer symlinks every directory under `skills/` into
`~/.claude/skills/` and `~/.codex/skills/`. Editing a skill here changes it for
both harnesses at once.

It is safe to re-run. Links that already point here are left alone, and anything
else sitting at a target path is moved to `../skills-backup/<name>.bak.N` rather
than deleted. Backups deliberately land beside the skills directory instead of
inside it, because a harness scans that directory and would otherwise load the
backup as a second skill with a duplicate name. A harness directory that does
not exist yet is created, so installing before Claude Code or Codex is set up
still works.

## Adding a skill

```sh
mkdir -p skills/<name>
$EDITOR skills/<name>/SKILL.md   # frontmatter: name, description
./install.sh
```

The `description` is what the agent matches against when deciding whether to
load the skill, so write it as a trigger ("Use when ...") rather than a summary.

## Uninstall

```sh
rm ~/.claude/skills/<name> ~/.codex/skills/<name>
```

Removing a symlink leaves the repo untouched.
