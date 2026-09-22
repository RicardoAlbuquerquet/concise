<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/banner-dark.svg">
    <img alt="concise. — The answer in the first sentence." src="docs/brand/banner-light.svg" width="100%">
  </picture>
</p>

<p align="center">
  <a href="https://github.com/RicardoAlbuquerquet/concise/actions/workflows/checks.yml"><img alt="checks" src="https://img.shields.io/github/actions/workflow/status/RicardoAlbuquerquet/concise/checks.yml?branch=main&label=checks&style=flat-square&labelColor=24292f"></a>
  <a href="CHANGELOG.md"><img alt="version" src="https://img.shields.io/badge/dynamic/json?label=version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FRicardoAlbuquerquet%2Fconcise%2Fmain%2Fskills%2Fconcise%2F.claude-plugin%2Fplugin.json&style=flat-square&labelColor=24292f&color=ee4a1f"></a>
  <a href="LICENSE"><img alt="license: MIT" src="https://img.shields.io/badge/license-MIT-57606a?style=flat-square&labelColor=24292f"></a>
</p>

<p align="center">
  A Claude Code plugin that makes Claude answer in the register a terminal wants —<br>
  <b>the answer first, nothing padding it, and every caveat that changes what you do kept.</b>
</p>

<p align="center">
  <a href="#measured">Measured</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#install">Install</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#what-it-does">What it does</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#what-ships">What ships</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#the-commands-and-the-agent">Commands</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#cursor-chatgpt-and-the-rest">Other tools</a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#the-bar-for-a-rule">The bar for a rule</a>
</p>

<br>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/brand/before-after-dark.svg">
  <img alt="The same question answered without and with concise: 74 words that never notice the premise is false, against three sentences that open on it." src="docs/brand/before-after-light.svg" width="100%">
</picture>

## Measured

**Say less, get more right.** Answers get 53% shorter — about half the tokens.

```text
answer gets shorter      [########--------]   53% 
answer is more complete  [###########-----]   65%
answer quality improves  [######----------]   40%
```

How it was measured, every request's result, and the one that came out
worse: [`evals/README.md`](evals/README.md#last-full-measurement).

## Install

Two commands, typed inside a running Claude Code session:

```
/plugin marketplace add RicardoAlbuquerquet/concise
```

```
/plugin install concise@claude-skill-concise
```

> [!IMPORTANT]
> **It takes effect in your next session, not this one.** The style loads at
> session start, which already happened in the session where you typed the
> install — restart Claude Code, or run `/reload-plugins`, then ask again.
> "I installed it and nothing changed" is almost always this.

**Those are Claude Code commands, not shell commands.** Pasted into PowerShell,
bash or zsh they fail with `command not found` — the leading `/` is the
giveaway. From a terminal, the `claude` CLI does the same on macOS, Linux and
Windows:

```bash
claude plugin marketplace add RicardoAlbuquerquet/concise
```

```bash
claude plugin install concise@claude-skill-concise
```

**In Codex**, the same plugin loads with its hooks — the core, the turn
reminder and the credit guard; the commands stay in Claude Code:

```bash
codex plugin marketplace add RicardoAlbuquerquet/concise
```

Then type `/plugins` inside Codex, install `concise`, and open a new session.
What differs from Claude Code: [`ports/README.md`](ports/README.md#codex).

It replies in the language you write in. Plugin skills are namespaced by the
plugin that ships them, so this registers as `/concise:concise`; `/plugin` →
**Installed** shows the exact name it took.

<details>
<summary><b>Updating</b> — two commands, and why the first one alone changes nothing</summary>
<br>

The first refreshes the catalogue, the second moves the copy that actually
runs:

```
/plugin marketplace update claude-skill-concise
/plugin update concise@claude-skill-concise
```

```bash
claude plugin marketplace update claude-skill-concise
claude plugin update concise@claude-skill-concise
```

Running only the first is the common mistake: it reports `✔ Successfully updated
marketplace` and the installed skill stays exactly where it was. The second one
needs the marketplace inside the name — `claude plugin update concise` on its own
answers `Plugin "concise" not found` — and it moves only when the release bumped
`version`, because it compares version numbers rather than content. Restart
Claude Code afterwards, or run `/reload-plugins`.

Third-party marketplaces ship with auto-update off. To skip the first one by
hand, turn it on in `/plugin` → **Marketplaces** → **Enable auto-update**.

</details>

<details>
<summary><b>Self-updating</b> — the plugin runs that pair itself, every six hours</summary>
<br>

A `SessionStart` hook checks every six hours, in the background, so an
installed copy follows the marketplace with one session of delay: the session
that checks downloads the update, the next one runs it. What that implies:

- It moves only when the release bumped `version`, same as the manual pair —
  an unbumped change on `main` never propagates.
- A check is stamped in `~/.claude` only once it reaches the marketplace, so
  a failure retries at the next session. After a week of failures — or with no
  `claude` on the PATH — the plugin says so on screen, with the command that
  shows the error; until then it stays quiet.
- `~/.claude/.concise-update-hours` holds a different number of hours.
- When an update lands, the next session names the version it moved to.
- **Inside this repo the stamp is ignored** and the check runs every session.
  Whoever ships the versions is the one person who outpaces the window, and a
  stale marketplace cache is also what greys out the update button in the
  client.
- Copies on 1.3.0 or earlier have no hook at all: reaching a version that
  self-updates takes one manual update, or the marketplace toggle above.
- To stop just this: `touch ~/.claude/.concise-no-self-update`. The style,
  the commands and the credit guard keep working.

</details>

<details>
<summary><b>Copying the file instead</b> — no plugin, a project-level copy, or another agent</summary>
<br>

It's a folder of Markdown files with no dependencies, so copying it works too —
and keeps the unprefixed `/concise`. This is the path that differs per platform.

Clone first, on any of the three:

```bash
git clone https://github.com/RicardoAlbuquerquet/concise.git
```

**macOS and Linux** — also Git Bash or WSL on Windows:

```bash
mkdir -p ~/.claude/skills
cp -r concise/skills/concise ~/.claude/skills/
```

**Windows**, in PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path $HOME\.claude\skills | Out-Null
Copy-Item -Recurse concise\skills\concise $HOME\.claude\skills\
```

Project-level instead, committed with the repo so your team shares it: create
`.claude/skills/` at the project root and copy into that.

**In another agent** — Cursor, Copilot, Codex, Windsurf and the rest that read
`SKILL.md` files — the ruleset travels through [skills.sh](https://skills.sh):

```bash
npx skills add RicardoAlbuquerquet/concise
```

Only the ruleset travels. The forced output style, the core, the turn reminder,
the self-update, the guards, the fourteen commands and the audit agent are Claude
Code plugin machinery; in another agent you get the document and invoke it
yourself.

Verify it registered by typing `/concise` in Claude Code. If it doesn't appear,
check the path: copying into a `skills/` directory that doesn't exist yet lands
`SKILL.md` directly in it, one level too high, and reports no error.

</details>

## The problem

Claude's default writing register is expansive. It's a good default for a chat
window and a bad one in a terminal, where it shows up as:

- a preamble before the answer — `"Great question — let me look at that."`
- `##` headers over a three-line reply
- justification nobody asked for, after the answer was already given
- narration of the search — which files were read, in what order
- a menu of four options when one recommendation was wanted
- a closing aphorism, because the paragraph felt like it needed a landing

None of that is wrong. All of it is between you and the answer.

## What it does

The skill installs one rule — **the answer goes in the first sentence, and after
it only what changes a decision** — plus budgets per situation, a list of
constructs to always cut, and a shorter list to *always keep*. The budget is per
turn, not per topic: each block after the first is paid for by what it leaves
the reader doing, which is what stops a reply that breaks no single rule from
arriving three times too long.

**That second list is the part that matters.** Compression is easy to overdo,
and a one-line answer that dropped the caveat about production data is worse
than the bloated version. Bad news, a risk, an exact path or version, a false
premise in the question and an unverified assumption all survive the edit.

Three rules run the other way and *add* text, because what was missing was
information rather than words:

- **A recommendation always ships with its cost.** Recommendation, ≤3 lines of
  why, ≤3 lines of what gets worse or what you give up. From the reader's side,
  a missing downside is indistinguishable from "I examined it and it's cheap".
- **When the decision is yours, the options go side by side** — and Claude still
  recommends one, saying why it beats *the others specifically*. Deciding a
  money or risk question silently is shorter and not its call to make.
- **Draw the shape.** When the answer is a sequence or a branch, a five-line
  ASCII diagram beats the paragraph you would have to assemble in your head.

**It reaches the code Claude writes, too.** A comment carries only what the
code can't say — never the edit that produced it — and a screen says each
thing once: no subtitle echoing its title, no placeholder echoing its label,
a verb on every button. The consequence of an irreversible action, the value
someone decides with and the accessible name stay.

**The ruleset is written as beliefs, desires and intentions**: what Claude holds
true about the reader, the medium and itself, what every reply is for, and what
it commits to on every turn. `SKILL.md` keeps what applies to every reply, in
under 300 lines, and each text that leaves the conversation has its own file,
read by the command that writes it — so a session that compacts still brings
back the rules that matter most.

<details>
<summary><b>Structure, audience and jargon</b> — how the rules decide what stays on the page</summary>
<br>

**Structure is judged by content, not by length.** An earlier version cut
headers and bullets from any response under six lines; that test was wrong,
because it measured the response instead of what's in it. The rule now:
separate what is genuinely separate — two jobs get two blocks, comparisons get
a table, paths and technical terms get code spans — and never fragment a single
thought. If you can say what each block is *for*, the structure is real; if the
blocks are "part one, part two", it's decoration.

**It also fixes the audience.** The skill is written for a reader who owns the
product but is not deep in the stack, and a term faces two questions in order.
*Will they meet it anyway* — type it, click it, approve changing it? If not,
the sentence says what the thing does and never names it. If yes, keep it and
pay for it once by glossing it **through its consequence** rather than its
definition — not "`timestamptz` is a timezone-aware type" but "the column
stores UTC, so a filter built in local time asks for a window that hasn't
started yet". One gloss per response is the ceiling: the second term wanting an
explanation is the reply carrying the shape of the investigation instead of the
answer. And dropping a term is not going vague — "the column stores the time in
UTC" is exact without it; "there's a timezone thing" threw the information away
and kept the length. An answer the reader can't act on isn't concise, it's just
short.

**The same test draws the line the other way.** A name lifted out of the
source — a table, an internal method, a constant — is not a technical term and
has no gloss to give, so it goes unless the reader is going to open it, run it,
or check that number. Cutting those is the rare edit that makes a sentence
clearer at the same time as it makes it shorter.

</details>

See [`examples/before-after.md`](examples/before-after.md) for ten real
transformations. Four of them come out longer.

## What ships

| | Piece | What it does |
|---|---|---|
| **The style** | `concise` skill | the ruleset as beliefs, desires and intentions, invoked when a turn needs it; the rules for PRs, cards, commits, changelogs, comments and code sit in `references/`, read by the command that writes each |
| | `SessionStart` hook | names this machine's shell for the fences, adds your core override when you wrote one; self-updates the plugin |
| | `concise` output style | the same core in the system prompt, forced on while the plugin is enabled |
| | turn reminder | `UserPromptSubmit` hook that restates the style in one line beside every prompt |
| **What leaves the conversation** | `/concise:pr` | drafts the PR description from the real diff, test steps last |
| | `/concise:commit` | drafts the commit message for what is staged — title in the shape the repo log uses, body says why |
| | `/concise:card` | drafts a task/issue card that stands alone; creates it when a destination is named |
| | `/concise:comment` | drafts a review comment, a thread reply or a note on a card — the claim, then the line that proves it |
| | `/concise:release` | drafts the changelog entry and the release body from the commits since the last tag — what breaks first |
| **Thinking out loud** | `/concise:plan` | drafts the plan for approval — steps that name a file or a command, the risk, what it leaves out |
| | `/concise:decide` | live options side by side with their costs, and still a recommendation |
| | `/concise:draw` | draws the shape in ASCII — one glyph set, nothing past 72 columns; refuses when the subject doesn't earn one |
| | `/concise:status` | writes the update as the delta since the last one, bad news on top |
| | `/concise:handoff` | hands the work over: the complete state, every standing caveat back in full, the traps, the resume command |
| **Text that already exists** | `/concise:rewrite` | rewrites a finished text to the rules, keeping every fact |
| | `/concise:trim` | cuts the dead text out of code and screens — comments that repeat the code, copy that repeats the screen |
| | `/concise:audit` | runs the audit agent on a draft, a file, or a PR body and relays the report |
| | `audit` agent | returns only the violations in a draft — quote, rule, fix |
| **Guards** | credit guard | `PreToolUse` hook that denies `git commit` / `gh pr create` carrying AI credit |
| | PR route hint | `PreToolUse` hook that stops the session's first `gh pr create` to point at `/concise:pr`; repeat the call to go ahead |
| | [`extras/stop-audit`](extras/stop-audit/README.md) | opt-in per-turn style judge, installed by hand |

The skill is the product; everything else keeps it applied — in every session,
to text that already exists, and to what leaves the conversation.

## Making it always-on

**A skill alone will not fire on every turn.** Skills are invoked — by you
typing `/concise`, or by the model deciding the `description` matches the task.
A response-*style* rule wants to apply to all of them, including the turns where
nothing about the task suggests "now think about brevity".

**Installed as a plugin, the style is forced on, in two layers** — the second
holds where the first fades:

| Layer | Where it lands | When |
|---|---|---|
| **Output style**, forced | the system prompt | every request — and Claude Code reminds the model of an active style mid-conversation |
| **Turn reminder**, from a `UserPromptSubmit` hook | beside your message, unseen in the transcript | every prompt |

The output style carries the ~95-line core, about 950 tokens, from one
file: [`hooks/core.md`](skills/concise/hooks/core.md); CI fails when the two
drift. The reminder is one line, about 900 characters a
turn. A `SessionStart` hook adds only the line naming your shell, and your core
override when you wrote one. The full ruleset still lives in the skill, which
the model invokes when a turn needs more than the core.

> [!WARNING]
> **Forcing overrides your own output style.** While the plugin is enabled it
> replaces the one you picked — Explanatory, Learning, or your own — and if
> another enabled plugin also forces one, the first loaded wins, and the core
> reaches the session only with `CONCISE_INJECT_CORE=1`. Disabling the plugin
> is the way back; the turn reminder has [its own switch](#the-commands-and-the-agent).

> [!TIP]
> **To check it actually loaded**, ask in a fresh session: *"what response style
> is active right now?"* The answer names the core's rules — answer in the first
> sentence, cut preamble, always keep bad news — when the hook ran, and doesn't
> when it didn't.

<details>
<summary><b>Rewriting the core, running without a shell, and installs by copy</b></summary>
<br>

**To prune or rewrite the core on your machine**, don't edit the cached copy —
the self-update overwrites it on the next release. Write
`~/.claude/concise-core-override.md` instead: when that file exists the hook injects it at every session start, and it survives every
update. The forced output style still carries the shipped core, so the override
lands on top of it — write the rules you change, and say which shipped rule
each one replaces.

**Without a shell, the style still holds.** The hooks run through Git Bash on
Windows, and without Git for Windows installed they fail silently — the
reminder, the override and the guards go quiet, on the same machines where
Claude Code's own Bash tool doesn't run. The forced output style needs no shell,
so the style stays in the system prompt there. A Claude Code too old to know
`force-for-plugin` ignores the key; then pick the style in `/config` →
**Output style** → `concise:concise`, or `export CONCISE_INJECT_CORE=1` to have
the hook print the core at session start instead.

**Installed by copy, the hook doesn't come along** — `~/.claude/skills/` takes
only the skill. Pair it with a line in `CLAUDE.md`, which is loaded into context
every session:

```markdown
## Writing style

Every response to me follows the `concise` skill: answer in the first sentence,
cut preamble and process narration, keep any caveat that would change what I do.
```

The skill holds the full ruleset; the hook or the `CLAUDE.md` line holds the
pointer that guarantees it's in context. Neither one replaces the other.

</details>

## The commands and the agent

The skill governs what Claude writes next. The commands produce one specific
piece of writing on demand — whether it leaves the conversation or stays in it —
or act on what is already written. The injected core names them, so Claude
reaches for one without being told to; that is a nudge competing for attention
with everything else in context, and a command you type is still the only
guarantee.

**Everything drafts by default.** Nothing is published unless you say so, in
the invocation itself:

| Command | Acts beyond the draft only when |
|---|---|
| `/concise:pr [base] [create]` | you type `create` — it opens the PR with exactly the drafted title and body |
| `/concise:commit [context] [run]` | you type `run` — it commits exactly the drafted message |
| `/concise:card <subject>` | you name a destination a tool can reach — an MCP board, a `gh` repo |
| `/concise:comment [subject]` | you name a destination *and* say to post |
| `/concise:release [version]` | never — no `gh release create`, no tag pushed |
| `/concise:status [where]` · `/concise:handoff [who]` | never — naming a channel or a person is not permission to send |
| `/concise:plan [subject]` | never — it doesn't enter plan mode or start step 1 |
| `/concise:trim [paths]` | always — cutting the text is the job, so it edits the files; it never commits |
| `/concise:rewrite` · `/concise:decide` · `/concise:draw` · `/concise:audit` | never — text only |

<details>
<summary><b>Every command in full</b></summary>
<br>

- **`/concise:rewrite <text>`** rewrites a finished text — a PR description,
  an issue body, an e-mail — to the ruleset without losing information: every
  exact value and caveat survives, and anything the original *owed* (a
  missing cost, a missing test step) is either filled from the original or
  reported as a hole, never invented. Empty arguments target Claude's own
  previous reply.
- **`/concise:trim [paths]`** cuts the dead text out of code — the comment
  that repeats the line under it or describes the edit, commented-out code,
  and on screen the second saying of the same thing, the button with no verb,
  the tone words. Empty arguments target the files the branch changed. A
  visible string changes together with the tests, snapshots and locales that
  match it, or stays and is reported; directives, license headers and
  accessible names always stay. It runs the repo's checks and leaves the
  commit to you.
- **`/concise:pr [base] [create]`** drafts the pull request description for
  the current branch from the real diff against `origin/main` (or the base
  you name): what is being solved, what was done, how to test it, with the
  exact test steps at the end. It reads the branch's commits for the why,
  fills the repo's `PULL_REQUEST_TEMPLATE` when one exists, references the
  card or issue that motivated the branch when one is known or findable —
  never invented — and delivers the title alongside the body. Draft only,
  unless you type the word `create`: that opens the PR with exactly the
  drafted title and body and reports the URL.
- **`/concise:card <subject>`** drafts a task/issue card whose body stands
  alone — current → expected behaviour, exact values, a done criterion — and
  creates it when you name a destination a tool can reach (an MCP board, a
  `gh` repo). Creating, it checks for an existing duplicate first, honours
  the tracker's issue template, sets the destination's fields instead of
  restating them in the body, and links named blockers.
- **`/concise:commit [context] [run]`** drafts the commit message for what is
  staged — a title of 72 characters or fewer, in whatever shape the repo log
  already uses, with the area first when the repo holds more than one, and a
  body saying why rather than retelling the diff. Draft only, unless you type
  the word `run`: that commits exactly the drafted message and reports the
  short sha.
- **`/concise:comment [subject]`** drafts a review comment, a reply in a
  thread, a note on someone's card, or a message to a person, in short plain
  sentences: the claim as the user of the app sees it, its cause, and whether
  it blocks, with the `path:line` above the block as where it goes. One point
  per comment — several points come back as several blocks. It reads the line or the thread before writing, and stops
  rather than guess when it can't. Draft only unless you name a destination
  *and* say to post.
- **`/concise:release [version]`** drafts the changelog entry — and the
  release body when you're cutting one — for the commits since the last tag:
  what changes for whoever installs it, what breaks first with the migration
  in the same entry, and the version number alongside the single change that
  forces it. It reads the existing changelog for the shape that file already
  uses, and never runs `gh release create` or pushes a tag.
- **`/concise:plan [subject]`** drafts the plan you are proposing: numbered
  steps that each name the file they touch or the command they run, the risk
  named, what it leaves out, and what it needs from you before step 1 in a
  block of its own. It reads the files the steps point at and marks the ones
  it could not verify. Text only — it does not enter plan mode and does not
  start step 1.
- **`/concise:decide [decision]`** lays out a call that is yours — money,
  risk, anything irreversible — as the live options side by side with what
  each one costs, then still recommends one, argued against the alternatives
  specifically, plus the condition that would flip the recommendation. A cost
  it could not verify comes back marked as unverified rather than rounded off.
- **`/concise:draw [subject]`** draws the shape in ASCII — arrows labelled
  with what flows and what it costs, boxes labelled by what they do rather
  than by their internal name — after reading the source for every hop. It
  carries four canonical layouts (flow, branch, before/after, call tree) and
  the craft rules: one glyph set, nothing past 72 columns, every label
  hanging off the box it names, failure below the main line, repetition as a
  count, no legend; mermaid only where the surface renders it and the graph
  is genuinely two-dimensional. It refuses when the subject does not earn a
  drawing (one function, a three-item list, a picture of a sentence already
  on screen) and says so instead of drawing it anyway.
- **`/concise:status [where]`** writes the update: only the delta since the
  last one, bad news on top, whatever is waiting on you in its own block, and
  when the next update lands. It finds the previous update and checks what
  actually moved — `git log`, the CI run — instead of recalling it. Draft
  only; naming a channel is not permission to post.
- **`/concise:handoff [who]`** hands the work over — the exact opposite of a
  status update, which is why it is a separate command. Where a status drops
  what the reader already has, a handoff assumes they have nothing: the
  branch, the sha, the PR and its state; what is done and verified kept apart
  from what is left with its done criterion; **every standing caveat back in
  full** rather than referred to; the traps that only you can name; what was
  decided and why; and the exact command that resumes the work. It reads
  `git status`, the log and the open PRs instead of recalling them. Draft
  only; naming who picks it up is not permission to send it.
- **`/concise:audit [target]`** runs the audit agent on a draft, a file path,
  or a PR or issue body it fetches, and relays the report as it comes back —
  verdict line, numbered violations, holes — followed by one line with the
  `/concise:rewrite` call that would fix them. It never rewrites, never edits
  the file, and never posts a correction.
- **The `audit` agent** checks a draft against the checklist
  and returns only the violations — quoted line, rule, one-line fix — plus
  required content that is missing. It never rewrites; ask for it when you
  want the diagnosis without the surgery: *"run the audit agent on this
  draft"*.

All of these ship only with the plugin install; the copy-the-file path takes
the skill alone.

</details>

**A credit guard ships enabled.** A `PreToolUse` hook denies a shell call that
would publish credit to an AI agent — a model `Co-Authored-By`, a "generated
with" footer — by deterministic string match, no API call. The call is blocked
with the reason, and the text gets rewritten without the trailer. It covers
`git commit` (including `git -C`), `gh pr create|edit|merge`,
`gh issue create|comment`, `gh release create|edit` and `gh api`, through the
`Bash` and `PowerShell` tools, anywhere in a command chain, and inside every
file the call reads the message from — `-F`, `--body-file`, `$(cat file)` or
`Get-Content file`, quoted or not. It names Claude, Copilot,
Gemini, Cursor, Codex and the `anthropic.com` trailer address.

**A second `PreToolUse` hook routes PR descriptions through the command that
writes them.** The first `gh pr create` — or `gh pr edit --body` — of a session
is denied once, with a reason naming `/concise:pr`; repeat the call and it goes
through, and a session that already ran `/concise:pr` goes through at once. A
description written from memory when a command was there to read the diff, the
log and the template is the failure it exists for, and a hook that kept denying
would be a wall the session could not leave. It cannot see a PR
opened in the browser — nothing in a plugin can — so a repo whose PRs are opened
on github.com puts the line in its own `PULL_REQUEST_TEMPLATE` instead.

Everything around the style switches off on its own, without touching it — a
deterministic guard has false positives, and writing *about* the rule trips it,
as this repo found out:

| To stop | For one shell or session | For good |
|---|---|---|
| the turn reminder | `export CONCISE_NO_TURN_REMINDER=1` | `touch ~/.claude/.concise-no-turn-reminder` |
| the credit guard | `export CONCISE_ALLOW_CREDIT=1` | `touch ~/.claude/.concise-no-credit-guard` |
| the PR route hint | `export CONCISE_NO_ROUTE_HINT=1` | `touch ~/.claude/.concise-no-route-hint` |
| the self-update | — | `touch ~/.claude/.concise-no-self-update` |

There is also an **opt-in Stop auditor** in
[`extras/stop-audit/`](extras/stop-audit/README.md): a hook you install by hand
that judges each turn's final response against the core and warns on clear
violations. It costs one API call per turn, which is why it does not ship
enabled.

## Cursor, ChatGPT and the rest

The plugin is Claude Code's. The same rules ship for the other tools in
[`ports/`](ports/README.md), generated from the very files the plugin uses, so
a rule edited once reaches all of them — and CI fails when a generated file
falls behind.

| Tool | What you copy | What it gives you |
|---|---|---|
| **Cursor** | `ports/en/cursor/rules/` and `ports/en/cursor/commands/` | the core in every request through `alwaysApply: true`, the full ruleset and the six surfaces pulled in when they match, and the fourteen commands under `/` |
| **Codex** | nothing: the plugin itself, from this marketplace | the core at session start, the style beside every prompt with the rule of the artifact being written, and the credit guard — no commands, no self-update |
| **Copilot, Zed, Gemini CLI, Windsurf, Aider, Jules** | `ports/en/AGENTS.md` and the `concise/` folder beside it | the core always on, and a table naming the file to read for anything longer |
| **ChatGPT** | one file into custom instructions, one into a project or a custom GPT | the style on every reply, and the commands as typed triggers |

**The commands travel with them**, minus the plugin prefix: `/pr`, `/card`,
`/commit`, `/comment`, `/release`, `/plan`, `/decide`, `/draw`, `/status`,
`/handoff`, `/rewrite`, `/trim`, `/audit` and `/woman` — the same fourteen
described above, as files Cursor lists when you type `/`, and, all but
`/woman`, as triggers the ChatGPT instructions define.

**Three shapes rather than one, because the targets differ.** Cursor reads one
`.mdc` per rule and one file per command, and ChatGPT's custom-instructions box
stops at 1,500 characters against the ruleset's 35,000 — so that box gets a
compression written by hand, and the tools that read a whole file get the whole
file. The source stays single: `skills/`, and `bash scripts/build-ports.sh`.

What stays behind is the Claude Code machinery — the forced output style, the
turn reminder, the credit guard, the PR route hint, the daily self-update and
the `audit` subagent. [`ports/README.md`](ports/README.md) carries the copy
commands and what replaces each of them.

## Languages

The plugin ships in English and replies in the language you write in: the
rules shape a reply, and a shape needs no translation. Installed by copy
rather than as a plugin, it invokes unprefixed: `/concise`.

## Uninstall

```
/plugin uninstall concise@claude-skill-concise
```

That removes the skill, the commands, the agent and the hooks. Four state files
stay behind in `~/.claude` — harmless, and worth deleting if you want the
welcome note again on a reinstall:

```bash
rm -f ~/.claude/.concise-welcomed ~/.claude/.concise-update-stamp ~/.claude/.concise-update-failed ~/.claude/.concise-update-note
```

Your core override (`~/.claude/concise-core-override.md`) and any opt-out flags
are yours; the uninstall leaves them alone.

## The bar for a rule

This skill is a style guide, which makes it unusually easy to fill with advice
that reads well and changes nothing. Every rule in it has to clear two tests:

1. **Checkable.** A rule you can't verify against a finished response is
   decoration. `"one bold claim per block"` is checkable; `"be clear"` is not.
2. **Names a real failure.** The rule exists because a specific bad output
   happens without it — ideally one you can quote.

`"Be brief"` fails both and is already implicit in every model's instructions.
That's why it isn't in the skill.

The rules are also measured, not only argued. CI refuses a plugin change that
doesn't bump its version;
[`evals/`](evals/README.md) runs judged cases against the ruleset — what each
case discriminates, and when it was last measured, is in its README — and
[`scripts/test-hooks.sh`](scripts/test-hooks.sh) exercises every hook without
touching the network.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

<br>
<p align="center">
  <a href="#readme"><img alt="concise." src="docs/brand/mark.svg" width="44"></a>
</p>
