# Ports

The same ruleset, for the tools that are not Claude Code. Everything here
except this file and the two ChatGPT files is generated
from `skills/` by [`scripts/build-ports.sh`](../scripts/build-ports.sh), and
CI fails when a generated file falls behind the skill it came from.

## Cursor

```bash
mkdir -p .cursor/rules .cursor/commands && cp ports/en/cursor/rules/*.mdc .cursor/rules/ && cp ports/en/cursor/commands/*.md .cursor/commands/
```

```powershell
New-Item -ItemType Directory -Force .cursor\rules, .cursor\commands | Out-Null; Copy-Item ports\en\cursor\rules\*.mdc .cursor\rules\; Copy-Item ports\en\cursor\commands\*.md .cursor\commands\
```

`concise.mdc` carries `alwaysApply: true`, so the core sits in every request —
the same job the forced output style does in Claude Code. The other seven wait
for their description to match what you are doing: `concise-full.mdc` for the
whole ruleset, and one file per surface that leaves the conversation
(`concise-pull-request.mdc`, `concise-commit.mdc`, and four more).

The fourteen commands appear when you type `/` in the chat input, under their
bare names: `/pr`, `/card`, `/commit`, `/comment`, `/release`, `/plan`,
`/decide`, `/draw`, `/status`, `/handoff`, `/rewrite`, `/trim`, `/audit`,
`/woman`.

Cursor also reads `AGENTS.md`, so the section below works there as a lighter
install — rules and commands are the fuller one.

## Codex

Codex loads this same plugin, hooks included, from the marketplace in this
repository:

```bash
codex plugin marketplace add RicardoAlbuquerquet/concise
```

Then `/plugins` inside Codex, and install `concise`.

| In Claude Code | In Codex |
|---|---|
| the core rides the forced output style | the session-start hook hands Codex the core itself |
| the style beside every prompt | the same hook, the same rules |
| the credit guard on shell, file and board writes | the same guard |
| self-update, the welcome note, the nudge to `/concise:pr` | skipped: Codex updates plugins itself and has no plugin commands |
| fourteen commands and the audit agent | not shipped yet |

The hooks tell the two apart by `PLUGIN_ROOT`, which Codex sets and Claude
Code does not; `CONCISE_HOST=codex` forces it. None of this has run under a
real Codex yet: it follows the Codex hook and plugin documentation, and the
tests in `scripts/test-hooks.sh` only simulate it. On Windows, Codex may run a
hook through a shell that leaves `$CLAUDE_PLUGIN_ROOT` unexpanded.

## Kiro

Kiro reads the open Agent Skills format, so it loads `skills/concise/` as it
is. Copy the folder to `~/.kiro/skills/concise/` for every project, or to
`.kiro/skills/concise/` for one workspace:

```bash
mkdir -p ~/.kiro/skills && cp -r skills/concise ~/.kiro/skills/
```

```powershell
New-Item -ItemType Directory -Force $HOME\.kiro\skills | Out-Null; Copy-Item -Recurse skills\concise $HOME\.kiro\skills\
```

A custom agent loads only the skills it lists, so add this line to its
`resources`:

```
skill://~/.kiro/skills/concise/SKILL.md
```

The skill fits Kiro's rules: `name` is `concise`, the same as the folder, and
the `description` is under 1,024 characters. The `/concise:` commands in the
table at the end of `SKILL.md` exist only in Claude Code; in Kiro the model
reads the `references/` file named beside each one. The `hooks/`, `commands/`,
`agents/` and `output-styles/` folders come along in the copy and stay unused.
Not tested in Kiro: this follows its documentation.

## Orca

Orca has no skills folder of its own. It lists the skills of the agents it
runs (Claude Code, Codex, `.agents/skills`), so a skill installed for one of
them shows up there. To install it straight from this repository:

```bash
npx skills add RicardoAlbuquerquet/concise --skill concise --global
```

The command finds the skill at `skills/concise/SKILL.md`. Not tested in Orca:
this follows its documentation.

## super-concise

The second skill in this repository has no generated port: every tool that
reads `SKILL.md` files loads `skills/super-concise/` as it is.

Kiro, for every project:

```bash
mkdir -p ~/.kiro/skills && cp -r skills/super-concise ~/.kiro/skills/
```

A custom agent lists `skill://~/.kiro/skills/super-concise/SKILL.md` in its
`resources`.

Orca, Cursor and the other agents skills.sh supports:

```bash
npx skills add RicardoAlbuquerquet/concise --skill super-concise --global
```

`/super-concise:reduce` exists only in Claude Code. Elsewhere, ask for it by
name: "super-concise this: …". Not tested in Kiro, Orca or Cursor: this
follows their documentation.

## AGENTS.md

Read by Copilot's coding agent, Zed, Gemini CLI, Windsurf, Aider, Jules
and the rest of the `AGENTS.md` family, and by Cursor:

```bash
cp ports/en/AGENTS.md . && cp -r ports/en/concise .
```

```powershell
Copy-Item ports\en\AGENTS.md .; Copy-Item -Recurse ports\en\concise .
```

`AGENTS.md` holds the core and a table saying which file to read for anything
longer — `concise/full.md` for the whole ruleset, `concise/pull-request.md`
and its five siblings for the surfaces. Copying `AGENTS.md` alone still leaves
a working style; the folder is what the table points at.

A repo that already has an `AGENTS.md` gets the contents appended instead,
under a heading of its own.

## ChatGPT

Two files, because ChatGPT has two places to put them:

| File | Where it goes | Cap |
|---|---|---|
| `ports/en/chatgpt/custom-instructions.md` | Settings → Personalization → Custom instructions, in the box about how ChatGPT should answer | 1,500 characters |
| `ports/en/chatgpt/project-instructions.md` | a project's instructions, or a custom GPT's | 8,000 characters |

The first is a compression of the core — 1,500 characters is a quarter of what
the core needs, so it is written by hand rather than generated, and it keeps
the answer-first rule, both lists and the cost of a recommendation. The second
carries the full style, the thirteen commands as typed triggers (`/pr`,
`/commit`, …) and the six surfaces in brief.

The build fails if either file grows past its cap, so a rule added upstream
gets fitted here rather than silently truncated by the box.

## What stays behind

The forced output style, the turn reminder, the credit guard, the PR route
hint and the daily self-update are Claude Code plugin machinery, and they stay
there. In Cursor the always-on half survives as `alwaysApply: true`; in
ChatGPT as the instructions box; in `AGENTS.md` as the file the tool loads on
its own. The `audit` agent has no subagent to run in, so the portable
`/audit` carries the checklist inline instead of handing it over.

## Changing a rule

Edit the skill under `skills/`, then:

```bash
bash scripts/build-ports.sh
```

Commit what it rewrites. `bash scripts/build-ports.sh --check` is what CI
runs, and it also fails when the plugin's own names — `${CLAUDE_PLUGIN_ROOT}`,
the `/concise:` prefix, `$ARGUMENTS` — survive into a file whose reader has
none of them.
