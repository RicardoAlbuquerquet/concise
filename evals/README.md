# Evals

Forty cases, eight at a time. Each gives the model the facts it would have discovered, sends
a prompt, and grades the response against a rubric of checkable properties —
answer in the first sentence, exact values kept, cost stated, bad news not
softened.

```bash
bash evals/run.sh
```

On Windows, run it from **Git Bash** — typed into PowerShell, `bash` is the
WSL stub, which answers that no distribution is installed. From PowerShell
the long form works:

```powershell
& "C:\Program Files\Git\bin\bash.exe" evals/run.sh
```

## What you can vary

| Variable | What it does |
|---|---|
| `CORE=1` | judges only the core the output style carries, not the full skill |
| `BASELINE=1` | no style at all — see below |
| `PLUGIN=1` | the plugin as an install delivers it: output style, turn reminder, hooks — see below |
| `RESPONSES=out` | keeps every answer in `out/`, one file per case and attempt |
| `RUNS=3` | three attempts per case; anything short of all-pass reports `FLAKY` |
| `MODEL=claude-sonnet-5` | pins the model, so two runs are comparable |
| `JOBS=1` | serial, for a rate limit or a log you want to read as it goes |
| `JUDGE_MODEL=` | judges with `MODEL` instead of the fast default |
| `ONLY=07` | one case by number or filename fragment; `ONLY=10,18,26` for several |
| `MIN_RUNS=2` | with `RUNS=5`, stops a case at two runs that agree, and agree with `COMPARE` |
| `COMPARE=evals/baseline/claude-opus-5.tsv` | better, same or worse per case against a saved run, each case stopping once its verdict is settled; exits 1 when one got worse |
| `WORSE_ONLY=1` | with `COMPARE`, only whether a case got worse; skips the cases whose saved side passes under 40% |
| `SET=core` | the cases listed in `evals/sets/core.txt` — the daily ten |
| `CASES=commands` | the six cases in `evals/commands/`, whose prompt is a plugin command such as `/concise:pr`; needs `PLUGIN=1` |
| `RESULTS=file` | saves passes and runs per case; cases that didn't run keep their line |
| `CLAUDE_BIN=./stub` | swaps the CLI — how the harness itself is tested, free |

In skill mode the harness appends every file in `references/` after `SKILL.md`:
a case can't open a file, and the command that writes a PR or a card would have
read its own.

**`BASELINE=1` is the one that tells you whether a case is worth having.** It
runs the same prompts with no style attached. A case that passes at baseline
measures the model's own habits, not the rules, and proves nothing when it
passes with the skill. Its exit code is always 0 — the pass count is the
signal, and a *low* one is the good news.

**`PLUGIN=1` measures what an install delivers.** The other modes paste text
into the system prompt; this one loads `skills/concise` with `--plugin-dir` on
the answer call, so the forced output style, the turn reminder and the
SessionStart line all run, and the judge runs without them. The hooks get a
scratch `HOME`, and the mode refuses to start without the isolated
`CLAUDE_CONFIG_DIR` that the baseline needs too — see
[the last full measurement](#last-full-measurement).

The style and the facts reach the CLI through `--append-system-prompt-file`,
  not the command line. That is not a detail: Windows caps a command line at
32767 characters, a skill past 31 KB made the full run die
at case 17 with "Argument list too long" before the switch. A CLI old enough
to lack the flag still works and says so.

**Cost:** two API calls per case per run, so the default suite is 80 calls
and a few minutes; `RUNS=3` triples that. The judge is a model grading prose:
a FAIL is a signal to read the printed verdict, not a verdict by itself.

## What a check costs

| Check | Calls |
|---|---|
| Daily: the ten core cases, only whether any got worse | ~17 |
| Daily: the ten core cases, better, same and worse | ~56 |
| A rule change: only the cases it touches | ~30 for three cases |
| Before a release: all cases, only whether any got worse | ~58 |
| The README numbers: all cases, better, same and worse | ~214 |
| The side with no plugin again, only when the model changes | ~400 |

The side with no style depends on the model, not on the plugin, so it runs
once and stays saved: [`baseline/claude-opus-5.tsv`](baseline/claude-opus-5.tsv),
five runs per case on 2026-09-14. A plugin run compares against it instead of
running it again. The commands need the isolated config and the directory
described in [the last full measurement](#last-full-measurement).

1. Every day, the ten cases in [`sets/core.txt`](sets/core.txt) — three
   simple, three medium, four complex. Whether any got worse takes about 17
   calls:

   ```bash
   CLAUDE_CONFIG_DIR=~/.claude-eval PLUGIN=1 RUNS=5 MIN_RUNS=1 SET=core WORSE_ONLY=1 COMPARE=~/concise/evals/baseline/claude-opus-5.tsv bash ~/concise/evals/run.sh
   ```

   Better, same and worse for the same ten take about 56:

   ```bash
   CLAUDE_CONFIG_DIR=~/.claude-eval PLUGIN=1 RUNS=5 MIN_RUNS=2 SET=core COMPARE=~/concise/evals/baseline/claude-opus-5.tsv bash ~/concise/evals/run.sh
   ```

   The rules the other thirty cases test wait for a release, and ten cases
   put the overall pass rate within about 14 points instead of 7.

2. While changing a rule, run only the cases the map below ties to it —
   about 30 calls for three cases:

   ```bash
   CLAUDE_CONFIG_DIR=~/.claude-eval PLUGIN=1 RUNS=5 MIN_RUNS=2 ONLY=10,18,26 COMPARE=~/concise/evals/baseline/claude-opus-5.tsv bash ~/concise/evals/run.sh
   ```

3. Before a release, ask only whether any case got worse. `WORSE_ONLY=1`
   skips the cases whose saved side passes under 40% — they have no room for a
   two-run drop — and stops every other case as soon as "worse" is settled
   either way, or after one run that agrees with the saved side. Simulated
   over every order the 1.71.0 passes could have come in, that is about 58
   calls.

   ```bash
   CLAUDE_CONFIG_DIR=~/.claude-eval PLUGIN=1 RUNS=5 MIN_RUNS=1 WORSE_ONLY=1 COMPARE=~/concise/evals/baseline/claude-opus-5.tsv bash ~/concise/evals/run.sh
   ```

   The README numbers need better and same as well: the same command without
   `WORSE_ONLY`, about 214 calls. There a case stops once the runs left can no
   longer change its verdict — 0 of 2 against a saved 5 of 5 is worse whatever
   comes next — or after two runs that agree with the saved side, within one.

4. Measure the saved side again only when the model changes, or for the one
   case whose rubric changed — `RESULTS` rewrites that case's line and keeps
   the others. All forty cases cost about 400 calls; one case, about 10:

   ```bash
   CLAUDE_CONFIG_DIR=~/.claude-eval BASELINE=1 RUNS=5 ONLY=18 RESULTS=~/concise/evals/baseline/claude-opus-5.tsv bash ~/concise/evals/run.sh
   ```

Each stop has a price, simulated on the 1.71.0 passes. The stop on a settled
verdict is free: the full count would print the same line. Stopping after two
runs that agree gets under one case per full sweep wrong. Stopping after one
gets about 0.2 wrong in a worse-only check, where a suspicious "worse" is cheap
to run again, and about two in a full sweep — enough to flip a "none worse",
which is why the README numbers keep two.

Grading the first two answers of a case in one judge call was tried and left
out: on the saved 1.71.0 answers it passed 110 of 200 where one answer per call
passed 132, lower in every case that differed, and it turned two cases worse.

## Rule → case

The map is what makes an edited rule regress instead of silently drifting: if
you change a rule here, change the rubric that tests it. The two scores come
from [the last full measurement](#last-full-measurement): a case that passes
with no style measures the model's own habits. The no-style score is always
out of five; the plugin score is out of the runs that case got, since a case
stops as soon as the runs left cannot change its verdict.

| Rule (`SKILL.md` or its reference file) | Case | No style | Plugin |
|---|---|---|---|
| Answer in the first sentence; no preamble | 01, and every other rubric | 4/5 | 5/5 |
| Completed work ≤5 lines, gate result | 02 | 1/5 | 3/3 |
| Investigation: finding + consequence | 03 | 5/5 | 2/2 |
| Always keep: caveat that changes what the user does | 04 | 5/5 | 2/2 |
| Recommendation carries its cost | 05 | 5/5 | 5/5 |
| The user's choice: options side by side + a recommendation | 06 | 0/5 | 4/5 |
| A runnable command gets its own `bash` fence | 07 | 5/5 | 2/2 |
| Overloaded opening: verdict first, support second | 08 | 5/5 | 2/2 |
| Commit message: title says what changes, body says why | 09 | 4/5 | 5/5 |
| PR description: test steps, unverified named | 10 | 3/5 | 5/5 |
| Card: stands alone, narrow-panel structure | 11 | 0/5 | 5/5 |
| Status update: only the delta | 12 | 5/5 | 2/2 |
| Bad news; the second question in a two-question message | 13 | 5/5 | 5/5 |
| Draw the shape; gloss by consequence | 14 | 0/5 | 2/4 |
| Correcting yourself: no story of the mistake, no re-announcing | 15 | 2/5 | 2/5 |
| Commit lands inside the repo log's convention | 16 | 5/5 | 4/5 |
| Several deliverables read as a markdown list | 17 | 0/5 | 3/5 |
| A list item stays an item, not a packed paragraph | 18 | 5/5 | 2/4 |
| What waits on the reader sits apart from what informs them | 19 | 3/5 | 3/5 |
| A name out of the code stays only if the reader will use it | 20 | 0/5 | 0/2 |
| A fence is tagged for the shell the reader will paste into | 21 | 4/5 | 2/2 |
| The outcome, not the itinerary of the work | 22 | 2/5 | 1/5 |
| A table column with one repeated value is not a column | 23 | 0/5 | 1/5 |
| The reader's choice still gets a recommendation, at the end of a long report | 24 | 2/5 | 3/5 |
| A note on a card is the summary of the summary | 25 | 2/5 | 4/4 |
| PR title: the area first, the state after the merge | 26 | 5/5 | 5/5 |
| Drawing craft: one glyph set, nothing wraps, labels hang off their box | 27 | 0/5 | 0/2 |
| One hanging note, and it sits on the finding | 28 | 0/5 | 2/3 |
| One gloss per response; the rest of the terms become what they do | 29 | 3/5 | 5/5 |
| One budget for the turn: a block that leaves the reader nothing gets a line, or goes | 30 | 1/5 | 3/3 |
| PR description inside a screenful, and the cut comes out of what repeats | 31 | 0/5 | 2/3 |
| Commit body: six lines at most, no investigation, no list of what was run | 32 | 3/5 | 4/5 |
| Comment: three lines, no greeting, no praise, and the omission stays silent | 33 | 0/5 | 4/5 |
| Card layout: two paragraphs, then labelled lines, spans off the prose | 34 | 0/5 | 0/5 |
| The delivered artifact is the answer; no tour of it, no praise for the tooling | 35 | 0/5 | 2/5 |
| A comment says only what the code can't; no docstring retelling the signature, no banner | 36 | 0/5 | 2/3 |
| A screen says each thing once, no toast for what the user watched, and the consequence stays | 37 | 1/5 | 2/5 |
| PR description: the words are the reviewer's, and a name only the repo knows becomes what it does | 39 | 0/5 | 2/3 |
| Status update: a background result is only its delta — the unchanged queue and risk stay unsaid | 40 | 0/5 | 2/2 |
| A description is one sentence, plus the one thing the reader acts on | 41 | 0/5 | 5/5 |

## Last full measurement

Version 1.72.0 on 2026-09-14: `claude-opus-5` answering, `claude-haiku-4-5`
judging, the plugin arm run against the saved no-style side, so a case stops
once the runs left cannot change its verdict. Twenty-two of the forty ran all
five times, ten of them chosen at random among the cases that had stopped
early and perfect, to price that stop: they came back 45 of 50, not 50.

| | No style | Plugin |
|---|---|---|
| Runs that pass their rubric | 85 of 200 | about 141 of 200 |
| Words per answer, median / mean | 162 / 177 | 77 / 108 |
| Requests better / same / worse | — | 16 / 23 / 1 |

**The plugin total is an estimate within about 5 points**: a case that stopped
at 2 of 2 counts as 5 of 5, and the sample above says that costs about half a
run per case. The 85 is exact — the no-style side ran five times everywhere.

**A case counts as worse when the plugin fails at least two more runs of
five**; one run apart is noise. The one worse is case 18, a list whose items
each carry several helpers.

What changed in 1.72.0: the turn reminder now carries the rules of the
artifact being written — card, review comment, PR description, commit message,
drawing — and only on the turn whose request names one. In the core those same
rules cost more elsewhere than they won: tried there, the total stayed at 132
of 200 while four other cases dropped.

## The 1.71.0 measurement, five runs per case

Version 1.71.0 on 2026-09-14: `claude-opus-5` answering, `claude-haiku-4-5`
judging, five runs per case, with and without the plugin. With the saved side and
today's stops, the same table costs about 214 calls.

Both arms need an isolated config, or the plugin gets graded against itself: a
global `CLAUDE.md` carrying the style, an installed copy's hooks and its forced
output style all reach `claude -p`. Copy `~/.claude/.credentials.json` and a
plugin-less `settings.json` into a scratch directory such as `~/.claude-eval`
— an empty directory alone loses the login. Run from a directory with no
`CLAUDE.md` above it, such as `/tmp`: from anywhere under your home, the walk
up the parent directories still finds `~/.claude/CLAUDE.md`. On Windows that
rules out Git Bash's `/tmp`, which lives inside your profile; a folder outside
`C:\Users` works.

```bash
CLAUDE_CONFIG_DIR=~/.claude-eval BASELINE=1 RUNS=5 MODEL=claude-opus-5 RESPONSES=out/none bash ~/concise/evals/run.sh
```

```bash
CLAUDE_CONFIG_DIR=~/.claude-eval PLUGIN=1 RUNS=5 MODEL=claude-opus-5 RESPONSES=out/plugin bash ~/concise/evals/run.sh
```

| | No style | Plugin |
|---|---|---|
| Runs that pass their rubric | 85 of 200 | 132 of 200 |
| Cases that pass all five runs | 10 of 40 | 19 of 40 |
| Words per answer, median / mean | 162 / 177 | 76 / 102 |

**A case counts as worse when the plugin fails at least two more runs of
five**; one run apart is noise, and the rule was set before the plugin arm
ran, and the same two runs make a case better. By it, the plugin is better on
13 cases and worse on one — case 18, 1 of 5 against 5 of 5, which still packs
several helpers into one item — and the other 26 are within one run.

What changed in 1.71.0, each tried on its own cases before this run: the first
sentence carries the result rather than a bare "yes" or a count of steps (22);
what waits on the reader's decision sits apart from the report, and a check
not run is said as not run (19); a PR title keeps the log's area prefix and
its description gets three sections under headers (10, 26); and two things
joined by and, a semicolon or parentheses are two list items (18).

## The 1.69.0 measurement, three runs per case

Version 1.69.0 on 2026-09-13: `claude-opus-5` answering, `claude-haiku-4-5`
judging, three runs per case in each arm — 480 calls.

| | No style | Plugin |
|---|---|---|
| Runs that pass their rubric | 48 of 120 | 72 of 120 |
| Cases that pass all three runs | 11 of 40 | 20 of 40 |
| Words per answer, median / mean | 165 / 178 | 70 / 94 |

Words are counted on the saved answers, the way `wc -w` counts them, and every
case averaged fewer with the plugin.

**The plugin wins 14 cases, ties 22 and loses 4.** Cases 19 and 22 lose by one
run, which three runs and a model judge can't tell from noise. Cases 18 and 26
were re-run five times, on 1.68.0 and on 1.69.0:

- **Case 26 was noise.** It passed 5 of 5 on both versions; the 1 of 3 above
  came from two runs that left the `invoices:` area off the title as a repeat
  of the branch name.
- **Case 18 holds, and predates the core rewrite**: 0 of 5 on both versions.
  Most failing runs drop exact values, the smoke test's 120 rows and 6 pages
  most often, and several pack the whole library into one table row with its
  details in parentheses. Its rubric misfired too, grading the opening
  "Pronto, nada commitado ainda" as a preamble and "~1,5 MB" as a lost value;
  it now says both are fine, and re-graded with it, case 18's scores hold.

**Eleven cases fail every run in both arms.** Nine ask for a PR (10, 17, 31,
39), a card (11, 34), a comment (33) or a drawing (27, 28), and their rules
arrive with the command that writes each; a case has no tools to run one, so
this mode measures them without their rules. The other two are plain replies:
14 named a signature check without saying what it protects, and 20 named a
table the reader will never open.

**Case 40 slid with the core rewrite in 1.69.0**: 4 of 5 on 1.66.0, 3 of 5 on
1.68.0 and 1 of 5 on 1.69.0, five runs each. The failing runs add that the
read-path switch and the PR still wait, and that the load-test risk hasn't
changed. The cause is the status sentence: the rewrite's "only what changed
since the previous update" lets the steps still waiting count as a change.

| Core | Case 40 |
|---|---|
| 1.69.0 with three other sentences put back, one at a time | 0, 1 and 0 of 5 |
| 1.69.0's beliefs, desires and intentions alone | 0 of 5 |
| 1.68.0 with 1.69.0's sections from Structure down | 4 of 5 |
| 1.69.0 with 1.68.0's "send only the delta since your last message" | 7 of 10 |

Case 12, the other status case, passes 5 of 5 with either sentence. The fix
is [#100](https://github.com/RicardoAlbuquerquet/concise/pull/100), for 1.70.0.

## Earlier measurements

**Measured 2026-08-20, on `claude-opus-5`: all 21 cases pass three times each
with the skill.** The baseline figure is older and narrower: 11 of the first 18
passed with no style at all, on 2026-08-19, and cases 19, 20 and 21 were
measured against baseline one at a time, at 1/3, 0/3 and 1/3. So ten cases
measure what the plugin adds; the other eleven describe behaviour Claude Code
already has by default, and would keep passing if the rule vanished. They are
not worthless — a default can regress, and a rule that matches the default
still documents it — but the suite's discriminating power is those ten, and a
new case should aim to fail at baseline.

Not covered yet: plans and the expand-on-request valve. Those are the next
cases to write.

**Case 33 found a rule that was missing rather than a rubric to loosen.** Its
facts dangle praise the reviewer genuinely means, and two runs in three the
model delivered a three-line comment and then explained, underneath, why the
praise had been left out — a note longer than the praise. Loosening the item
would have graded away the very thing the case is for, so the rule went into
`SKILL.md` instead: what a comment leaves out, it leaves out silently. It
passes 3 of 3 after that, and case 25 still does.

**Case 11 was flaky at 1 of 3 before the card layout rules existed, and the
measurement is what said so.** Its repro came out as one packed line and its
title opened on the product name instead of the board area — both failures
its own rubric already asked about. The layout rules took it to 2 of 3 on
their own; naming the board's areas in the facts, so that "PWA" locates
nothing, took it to 3 of 3. Measure the case against the old skill before
crediting a change with a regression, or with a fix.

**Case 18 was unstable at about 2 of 3 from the day it was written until
1.23.0, and the cause was not the rule it tests.** A dozen claims against a
≤5-line budget left no layout that satisfied both, so each run broke somewhere
different — a packed item, then stacked parentheticals, then the tail of the
list folded back into prose. Rewording the list rule moved the failure around
three times; fixing the budget row fixed the case. When a case fails
*differently* every run, look for two rules colliding before rewording either
of them.

A single-run suite line of 21/21 also means each case drew well once, not that
each rule holds. `RUNS=3` is what tells them apart. **The first full sweep with
it — 2026-08-20, on `claude-opus-5` — has all 21 cases holding three times
each**, but only after it found two real defects that single runs had hidden
for releases: case 07's rubric hard-coded a `bash` fence while its facts named
no platform, so it was grading the machine the suite ran on; and case 18 kept
shortening a path to its basename, one run in three.

Two lessons from that sweep, both cheaper to read than to rediscover. A case
that depends on the reader's platform has to state the platform in its facts.
And a case that fails while the session limit is being hit is not a finding —
case 14 reported 2 of 3 for that reason alone, and passes on re-measurement.

**Case 08 was unstable for a different reason: its rubric graded punctuation.**
It failed any opening that put an em dash after "yes" and let the support
trail, which reads the same as a full stop. It now checks what the rule is
actually for — the verdict arrives before any support, and the caveat gets a
sentence of its own — and passes 3 of 3 with the skill and 3 of 3 at baseline,
measuring what the map already listed it as: not a discriminator.

A rubric can be miscalibrated as easily as a rule can drift. Case 10 asked a
single-change PR for a list of deliverables it did not have — the response
was right and the rubric was wrong. When a case fails, read the quoted
violation before assuming the skill moved.

**Case 10 was flaky at 2 of 3 for the same reason, and it predates the rule
that looked guilty.** "The description ends with a test step containing the
exact command" was read literally: any caveat after the command — the
unverified part, what would prove it broke — failed a response the ruleset
had asked for. Measured against the pre-change skill before touching
anything, which is what said the ceiling added in 1.49.0 was not the cause.
The item now asks that the test steps be the last *section*, and the case
passes 3 of 3.

Case 31 cost four rewrites, and three of them were the rubric rather than the
skill. Two lessons in it. A case whose facts restate work that really landed
in this repository gets contradicted by the session's own git context — the
model reported the branch as already merged, correctly — so its facts now
name a project that has nothing to do with the checkout. And an item that
grades a shape ("one line, not a story") has to say what makes it fail:
counting sentences is checkable, "recounting your trip" is a judgement call
the judge will make differently every run.


**Case 35's first failure was the new rule eating an old one.** The rule that
cuts a tour of the artifact you just delivered was written with the exemption
"what the artifact cannot say about itself" — and the artifact could say it:
the unrun test step was named inside the step. One run in three dropped it
from the reply, correctly by that wording and wrongly by the **Always keep**
list. The exemption is now what the reader *would get wrong by not opening
it*, which keeps the unverified part in the reply even when the PR body also
carries it. An exemption phrased around the artifact will lose to one phrased
around the reader.

Case 22 has been flaky at about 2 of 3 since before this, and the measurement
against the stashed skill is what says so — its failing run buries the
substance in bullets under a bare "yes", which is the first-sentence rule, not
the cut list next to it.

**The first drafts of cases 36 and 37 measured nothing.** A bugfix to a retry
function passed 3 of 3 against the 1.57.0 core, which carries no rule about
code, and so did an export dialog whose facts dictated every string on the
screen — a case that passes without the rule cannot show the rule working.
The current drafts leave the model room to add text: a new file with no
convention to copy, and a settings page with four switches and a toast in
reach.

**Case 39 measures the rule that put plain words in a PR body, and it fires
rarely.** With no style at all the body arrives wearing the repo's own
vocabulary and fails 0 of 3 on exactly that. Against the skill without the
rule it still passes 2 of 3 — the core already asks that a name out of the
code earn its place — and the run it drops, it drops to the same two internal
names left sitting in the body. With the rule it passes 3 of 3.

Two things the case cost before it measured anything. Its rubric started out
grading *where* the unverified note sits, which belongs to another rule, and
every early failure came from that item rather than from the vocabulary one.
And the rule's first draft ran seven lines inside a reference that asks for a
description of twenty-five: case 31 fell from 3 of 3 to 2 of 3 in two samples
while it was in, and came back to 3 of 3 once the rule was three lines long. A
rule that spends the budget it polices pays for itself twice.

**Cases 40 and 41 are measured with the whole plugin loaded, not only its
text.** The turn reminder lives in `hooks.json`, which no mode of `run.sh`
reaches, so a `CLAUDE_BIN` wrapper added `--plugin-dir` to the answer call and
left the judge clean. On `claude-opus-5`, 2026-09-12, three runs per arm:

| Case | No style | Plugin 1.65.0 | Plugin 1.66.0 |
|---|---|---|---|
| 40, background result | 0/3 | 0/3 | 3/3 |
| 41, describing a tool | 0/3, 10–15 lines | 0/3, 9 lines each | 2/3, 2 lines each |

The reminder took eight drafts, and the suite is what told them apart. Five
lines ahead of everything cost case 06 its options table, 3/3 to 0/3, and case
24 an exact value. One sentence for every question cost 06 the table again and
case 14 its drawing, so the one sentence went to descriptions alone and a
choice asks for its table by name. Saying a description's numbers wait dropped
24's value once more; it now says the rest waits. The last draft re-ran 24
and 41 only, the one before it 06, and 40 last ran on the third. Cases 18
and 20 fail 0/3 with either plugin, so both predate this change.

## Adding one

A new case earns its place the same way a rule does: it encodes a real
failure the skill exists to prevent, and its rubric items are checkable
against a finished response. A rubric line the judge can't verify by quoting
the response is decoration. Run `BASELINE=1 RUNS=3 ONLY=<your case>` before
committing it — if it passes without the skill, it isn't testing the skill,
and one attempt is not enough to tell: case 19 passed its first baseline run
and then failed two of the next three.
