#!/usr/bin/env bash
# Runs each case in evals/cases/ through `claude -p` with the skill as system
# prompt, then grades the response with a second `claude -p` call as judge.
# Two API calls per case.
#
#   bash evals/run.sh                          # all cases, EN skill
#   ONLY=03 bash evals/run.sh                  # one case, by number or filename fragment
#   ONLY=10,18,26 bash evals/run.sh            # several — the cases a rule change touches
#   SET=core bash evals/run.sh                 # a named list in evals/sets/ — core is the daily ten
#   CASES=commands PLUGIN=1 bash evals/run.sh  # the cases that invoke /concise:pr and the rest
#   CLAUDE_BIN=./stub bash evals/run.sh        # swap the CLI (used in testing)
#   CORE=1 bash evals/run.sh                   # judge the always-on core, not the skill
#   STYLE_FILE=ports/en/AGENTS.md bash evals/run.sh   # judge one port's own text
#   BASELINE=1 bash evals/run.sh               # no style at all — what the model does raw
#   PLUGIN=1 bash evals/run.sh                 # the plugin as installed: output style, reminder, hooks
#   RESPONSES=out bash evals/run.sh            # keep every answer, one file per case and attempt
#   RUNS=3 bash evals/run.sh                   # N attempts per case, pass rate reported
#   RUNS=5 MIN_RUNS=2 bash evals/run.sh        # stop at 2 when they agree, and agree with COMPARE
#   RESULTS=evals/baseline/claude-opus-5.tsv   # save passes per case; other cases' lines stay
#   COMPARE=evals/baseline/claude-opus-5.tsv   # better/same/worse per case against a saved run
#   WORSE_ONLY=1 COMPARE=...                   # only "did any case get worse?" — the release gate
#   MODEL=claude-sonnet-5 bash evals/run.sh    # pin the model so runs compare
#   JOBS=1 bash evals/run.sh                   # serial, for a rate limit or a clean log
#   JUDGE_MODEL= bash evals/run.sh             # judge with MODEL instead of the fast default
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="${SKILL:-concise}"
BIN="${CLAUDE_BIN:-claude}"
RUNS="${RUNS:-1}"
MIN_RUNS="${MIN_RUNS:-$RUNS}"
[ -z "${COMPARE:-}" ] || [ -f "$COMPARE" ] || { echo "no such saved run: $COMPARE" >&2; exit 2; }
[ -z "${WORSE_ONLY:-}" ] || [ -n "${COMPARE:-}" ] || {
  echo "WORSE_ONLY=1 needs COMPARE: it asks whether a case got worse than a saved run" >&2; exit 2; }

# CASES names the folder under evals/. The command cases open with
# /concise:commit and its siblings, which exist only with the plugin loaded:
# with no style, the prompt is an unknown command and every rubric fails.
CASES="${CASES:-cases}"
[ -d "$ROOT/evals/$CASES" ] || { echo "no such case folder: evals/$CASES" >&2; exit 2; }
if [ "$CASES" = commands ] && [ -z "${PLUGIN:-}" ] && [ -z "${CLAUDE_BIN:-}" ]; then
  echo "CASES=commands needs PLUGIN=1: the prompts are plugin commands" >&2; exit 2
fi

# SET names a list of case numbers in evals/sets/, one per line, # for notes.
# It becomes ONLY, so the two can't both be given.
if [ -n "${SET:-}" ]; then
  set_file="$ROOT/evals/sets/$SET.txt"
  [ -f "$set_file" ] || { echo "no such set: $set_file" >&2; exit 2; }
  [ -z "${ONLY:-}" ] || { echo "SET and ONLY both pick cases — give one" >&2; exit 2; }
  ONLY=$(sed 's/#.*//' "$set_file" | tr -d '\r' | tr -s ' \n' ',' | sed 's/^,//; s/,$//')
fi

# Better or worse means pass rates 40 points apart — two runs in five. One run
# apart is noise, and it counts as the same in both directions. WORSE_ONLY
# folds better into the same, so a case stops as soon as "worse" is settled.
verdict () {
  if [ "$1" -le -40 ]; then echo worse
  elif [ -n "${WORSE_ONLY:-}" ] || [ "$1" -lt 40 ]; then echo same
  else echo better; fi
}
saved () { awk -F'\t' -v n="$1" '{sub(/\r$/,"")} $1==n{print $2" "$3}' "$COMPARE"; }
SKILL_FILE="$ROOT/skills/$SKILL/SKILL.md"
CORE_FILE="$ROOT/skills/$SKILL/hooks/core.md"
[ -f "$SKILL_FILE" ] || { echo "no such skill: $SKILL_FILE" >&2; exit 2; }

# What the model is given: the full ruleset (default), only the core the
# forced output style carries, one port's own text — what a Cursor or ChatGPT
# user actually pastes, which is the only way that text gets measured at all —
# the plugin itself, or nothing, the baseline that says whether a case
# measures the rules or the model's own habits.
if [ -n "${PLUGIN:-}" ]; then
  # The turn reminder and the SessionStart line live in hooks, which no text
  # mode reaches, so the answer call loads the plugin and the judge stays
  # clean. Without an isolated config the installed copy and a global
  # CLAUDE.md answer alongside it, and the plugin gets graded against itself.
  [ -n "${CLAUDE_CONFIG_DIR:-}" ] || {
    echo "PLUGIN=1 needs an isolated CLAUDE_CONFIG_DIR — see evals/README.md" >&2; exit 2; }
  STYLE=""; MODE=plugin
elif [ -n "${BASELINE:-}" ]; then
  STYLE=""; MODE=baseline
elif [ -n "${STYLE_FILE:-}" ]; then
  # An unreadable path would hand every case an empty style and report the
  # model's own habits as a pass, so it stops here instead.
  f="$STYLE_FILE"; [ -f "$f" ] || f="$ROOT/$STYLE_FILE"
  [ -f "$f" ] || { echo "no such style file: $STYLE_FILE" >&2; exit 2; }
  STYLE=$(cat "$f"); MODE=port
elif [ -n "${CORE:-}" ]; then
  STYLE=$(cat "$CORE_FILE"); MODE=core
else
  # The skill sends each surface that leaves the conversation to its own file,
  # and a case can't open one, so it gets all of them — what the matching
  # command would have read.
  STYLE=$(cat "$SKILL_FILE" "$ROOT/skills/$SKILL"/refer*/*.md); MODE=skill
fi
MODEL_ARG=""
[ -n "${MODEL:-}" ] && MODEL_ARG="--model ${MODEL}"

# The judge checks a response against a rubric — it matches, it does not write.
# That is the cheap half of every case, so it runs on a fast model by default
# and the suite stops costing two frontier calls per case. JUDGE_MODEL= (empty)
# puts it back on whatever MODEL is.
JUDGE_MODEL="${JUDGE_MODEL-claude-haiku-4-5-20251001}"
JUDGE_ARG="$MODEL_ARG"
[ -n "$JUDGE_MODEL" ] && JUDGE_ARG="--model ${JUDGE_MODEL}"

# The cases share nothing, so the only reason the suite took twenty minutes was
# that it waited for each of its 2N calls in turn. Eight at a time is the
# difference between a gate you run and one you avoid. JOBS=1 restores the
# serial order when a rate limit or a readable log matters more.
JOBS="${JOBS:-8}"

WORK="${TMPDIR:-/tmp}/concise-eval.$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT INT TERM
[ -n "${RESPONSES:-}" ] && mkdir -p "$RESPONSES"

# The hooks keep their state in ~/.claude: a welcome note, a daily self-update
# that would try the isolated config's empty marketplace, and the opt-out flags
# and core override of whoever runs the suite. A scratch HOME measures the
# plugin as shipped and leaves that state alone.
ANSWER_HOME="$HOME" PLUGIN_ROOT=""
if [ "$MODE" = plugin ]; then
  mkdir -p "$WORK/home/.claude"
  : > "$WORK/home/.claude/.$SKILL-welcomed"
  : > "$WORK/home/.claude/.$SKILL-no-self-update"
  ANSWER_HOME="$WORK/home" PLUGIN_ROOT="$ROOT/skills/$SKILL"
fi
SYS_MODE=file
"$BIN" --help 2>&1 | grep -q 'append-system-prompt\[-file\]\|append-system-prompt-file' || {
  SYS_MODE=arg
  echo "note: this '$BIN' has no --append-system-prompt-file; falling back to the" >&2
  echo "      command line, which Windows caps at 32767 characters. Update the CLI" >&2
  echo "      if the suite dies with 'Argument list too long'." >&2
}
echo "mode=$MODE skill=$SKILL runs=$RUNS jobs=$JOBS${MODEL:+ model=$MODEL}${JUDGE_MODEL:+ judge=$JUDGE_MODEL}"

# sub(/\r$/,"") tolerates CRLF working copies (Windows checkout read from WSL)
section () { awk -v s="## $1" '{sub(/\r$/,"")} $0==s{f=1;next} /^## /{f=0} f' "$2"; }

# One case, start to verdict, writing its report to a file so that N of these
# can run at once without interleaving their output. Exit 3 means the CLI
# failed, not the rules — the collector turns that into an abort.
run_case () {
  case_file=$1
  name=$(basename "$case_file" .md)
  out="$WORK/$name.out"
  sysf="$WORK/$name.sys"
  : > "$out"

  facts=$(section Facts "$case_file")
  prompt=$(section Prompt "$case_file")
  rubric=$(section Rubric "$case_file")

  # A missing or misnamed section produces an empty rubric, and an empty
  # rubric has nothing to violate — a permanent false PASS in the only
  # safety net the rules have. (Facts may legitimately be empty.)
  [ -n "$prompt" ] && [ -n "$rubric" ] || {
    echo "$name: no '## Prompt' or '## Rubric' section" > "$WORK/$name.abort"; return 3; }

  # The saved run's passes and runs for this case, when COMPARE names one.
  base=""
  [ -n "${COMPARE:-}" ] && base=$(saved "$name")
  ok=0
  attempt=1
  while [ "$attempt" -le "$RUNS" ]; do

  # The style and the facts used to travel on the command line, which Windows
  # caps at 32767 characters. A skill reached 31 KB and the suite began
  # dying with "Argument list too long" partway through — a ceiling that moves
  # closer every time a rule lands. A file has no such limit.
  printf '%s\n\n%s\n\n%s\n' "$STYLE" \
"You are replying in a terminal. Do not use tools. The facts below are things
you already verified yourself this session — treat them as your own findings,
and treat any action they describe as one you have not performed yet." \
    "$facts" > "$sysf"

  # shellcheck disable=SC2086
  if [ "$SYS_MODE" = file ]; then
    response=$(HOME="$ANSWER_HOME" "$BIN" -p "$prompt" $MODEL_ARG ${PLUGIN_ROOT:+--plugin-dir "$PLUGIN_ROOT"} --append-system-prompt-file "$sysf")
  else
    response=$(HOME="$ANSWER_HOME" "$BIN" -p "$prompt" $MODEL_ARG ${PLUGIN_ROOT:+--plugin-dir "$PLUGIN_ROOT"} --append-system-prompt "$(cat "$sysf")")
  fi
  rc=$?

  # A dead CLI must abort the suite, not spread across every case as a FAIL
  # the rules did not earn. Auth is matched at the start of the output, so a
  # response that merely discusses OAuth doesn't trip it.
  case "$response" in
    "Failed to authenticate"*|"Invalid API key"*|*"OAuth session expired"*)
      echo "auth error from '$BIN -p' — log in first (open claude, run /login), then re-run" \
        > "$WORK/$name.abort"; return 3 ;;
  esac
  # An empty response or a non-zero exit is the CLI failing, not the rules —
  # scoring it would blame the skill for a network error. No length floor
  # beyond that: this style produces legitimately short answers. Under JOBS>1
  # a rate limit lands here too, which is why it aborts instead of scoring.
  if [ "$rc" -ne 0 ] || [ -z "$(printf '%s' "$response" | tr -d '[:space:]')" ]; then
    echo "$name: '$BIN -p' returned nothing (exit $rc) — aborting instead of scoring it" \
      > "$WORK/$name.abort"; return 3
  fi
  [ -n "${RESPONSES:-}" ] && printf '%s\n' "$response" > "$RESPONSES/$name.$attempt.txt"

  # shellcheck disable=SC2086
  verdict=$("$BIN" -p $JUDGE_ARG "Grade the response below against the rubric, item by
item. For each item print OK, or VIOLATION followed by the shortest quote that
proves it. The very last line must be exactly PASS (every item OK) or FAIL.

## Response
$response

## Rubric
$rubric")

  # The judge sometimes decorates its verdict (**PASS**, "PASS." ) — strip
  # punctuation and emphasis before comparing, or a passing case reads as a
  # failure.
  last=$(printf '%s\n' "$verdict" | awk 'NF{l=$0} END{print l}' | tr -d '[:space:]*_`.:!')
  if [ "$last" = "PASS" ]; then
    ok=$((ok+1))
  else
    lastverdict=$verdict
  fi
  attempt=$((attempt+1))

  # Most cases pass every run or fail every run, and the runs past MIN_RUNS
  # only repeat that. They stop there when the runs so far agree with each
  # other and, under COMPARE, with the saved run to within one run — a case
  # where the two sides disagree is the one that needs the full count.
  done_n=$((attempt-1))
  # Under COMPARE a case also stops once the runs left cannot change its
  # verdict: 0 of 2 against a saved 5 of 5 is worse even if the other three
  # pass. That stop costs nothing, since the full count would say the same.
  if [ -n "$base" ] && [ "$done_n" -lt "$RUNS" ]; then
    read -r bpass bruns <<< "$base"
    bpct=$((100*bpass/bruns))
    lo=$((100*ok/RUNS - bpct)); hi=$((100*(ok+RUNS-done_n)/RUNS - bpct))
    [ "$(verdict "$lo")" = "$(verdict "$hi")" ] && break
  fi
  if [ "$done_n" -ge "$MIN_RUNS" ] && [ "$done_n" -lt "$RUNS" ]; then
    if [ "$ok" -eq "$done_n" ] || [ "$ok" -eq 0 ]; then
      [ -z "$base" ] && break
      read -r bpass bruns <<< "$base"
      [ "$ok" -eq "$done_n" ] && [ "$bpass" -ge $((bruns-1)) ] && break
      [ "$ok" -eq 0 ] && [ "$bpass" -le 1 ] && break
    fi
  fi
  done
  ran=$((attempt-1))
  echo "$ok $ran" > "$WORK/$name.count"

  if [ "$ok" -eq "$ran" ]; then
    echo "PASS  $name" >> "$out"; echo pass > "$WORK/$name.status"
  elif [ "$ok" -gt 0 ]; then
    # Flaky is a finding, not a pass: the rule holds sometimes.
    echo "FLAKY $name  ($ok/$ran)" >> "$out"; echo fail > "$WORK/$name.status"
    printf '%s\n' "$lastverdict" | sed 's/^/      /' >> "$out"
  else
    echo "FAIL  $name" >> "$out"; echo fail > "$WORK/$name.status"
    printf '%s\n' "$lastverdict" | sed 's/^/      /' >> "$out"
  fi
}

# Fan out, then report in filename order — a parallel run must read exactly
# like a serial one, or a diff between two runs is unreadable.
#
# ONLY takes several fragments, split on commas or spaces. A fragment of digits
# alone is a case number, so ONLY=1 means case 01 and not every name with a 1.
matches () {
  [ -n "${ONLY:-}" ] || return 0
  for frag in $(printf '%s' "$ONLY" | tr ',' ' '); do
    case "$frag" in
      *[!0-9]*) case "$1" in *"$frag"*) return 0 ;; esac ;;
      ?) case "$1" in "0$frag"-*) return 0 ;; esac ;;
      *) case "$1" in "$frag"-*) return 0 ;; esac ;;
    esac
  done
  return 1
}
selected="" skipped=0
for case_file in "$ROOT/evals/$CASES"/*.md; do
  name=$(basename "$case_file" .md)
  matches "$name" || continue
  # Worse takes a drop of 40 points, so a case whose saved side passes under
  # 40% has no room for one — nearly half the suite, skipped at no risk.
  if [ -n "${WORSE_ONLY:-}" ]; then
    b=$(saved "$name")
    if [ -n "$b" ]; then
      read -r bp br <<< "$b"
      [ $((100*bp/br)) -lt 40 ] && { skipped=$((skipped+1)); continue; }
    fi
  fi
  selected="$selected $case_file"
  while [ "$(jobs -pr | wc -l)" -ge "$JOBS" ]; do wait -n 2>/dev/null || break; done
  run_case "$case_file" &
done
wait

# Under JOBS>1 a dead CLI kills every case in flight, so reporting all of them
# buries the one line that says why. First reason, then the count.
if ls "$WORK"/*.abort >/dev/null 2>&1; then
  head -1 "$WORK"/*.abort 2>/dev/null | grep -v '^==>' | grep . | head -1 >&2
  n=$(ls "$WORK"/*.abort | wc -l | tr -d ' ')
  [ "$n" -gt 1 ] && echo "($n cases aborted the same way)" >&2
  exit 3
fi

pass=0 failn=0
for case_file in $selected; do
  name=$(basename "$case_file" .md)
  [ -s "$WORK/$name.out" ] && cat "$WORK/$name.out"
  if [ "$(cat "$WORK/$name.status" 2>/dev/null)" = pass ]; then
    pass=$((pass+1))
  else
    failn=$((failn+1))
  fi
done

echo "----"
echo "$pass passed, $failn failed  (mode=$MODE)"
[ $((pass + failn + skipped)) -gt 0 ] || { echo "no case matched ONLY=${ONLY:-}" >&2; exit 2; }

# RESULTS keeps "case, passes, runs" per line. A run over a few cases rewrites
# their lines and keeps the rest, so one rubric's fix doesn't cost a full sweep.
if [ -n "${RESULTS:-}" ]; then
  for case_file in $selected; do
    name=$(basename "$case_file" .md)
    read -r p r < "$WORK/$name.count"
    printf '%s\t%s\t%s\n' "$name" "$p" "$r"
  done > "$WORK/results.new"
  [ -f "$RESULTS" ] && awk -F'\t' 'NR==FNR{ran[$1]=1; next} {sub(/\r$/,"")} !($1 in ran)' "$WORK/results.new" "$RESULTS" > "$WORK/results.kept"
  cat "$WORK/results.new" "$WORK/results.kept" 2>/dev/null | sort > "$WORK/results.all"
  mkdir -p "$(dirname "$RESULTS")" && cp "$WORK/results.all" "$RESULTS"
fi

# Under COMPARE the exit code says whether any case got worse, whatever else
# failed.
if [ -n "${COMPARE:-}" ]; then
  echo "---- against $COMPARE"
  better=0 same=0 worse=0 new=0
  for case_file in $selected; do
    name=$(basename "$case_file" .md)
    read -r p r < "$WORK/$name.count"
    b=$(saved "$name")
    if [ -z "$b" ]; then echo "new     $name  $p/$r"; new=$((new+1)); continue; fi
    read -r bp br <<< "$b"
    case $(verdict $(( 100*p/r - 100*bp/br ))) in
      worse) echo "worse   $name  $bp/$br -> $p/$r"; worse=$((worse+1)) ;;
      better) echo "better  $name  $bp/$br -> $p/$r"; better=$((better+1)) ;;
      *) same=$((same+1)) ;;
    esac
  done
  if [ -n "${WORSE_ONLY:-}" ]; then
    echo "$worse worse, $same not worse, $skipped skipped as unable to get worse$([ "$new" -gt 0 ] && echo ", $new without a saved result")"
  else
    echo "$better better, $same same, $worse worse$([ "$new" -gt 0 ] && echo ", $new without a saved result")"
  fi
  [ "$worse" -eq 0 ]; exit $?
fi

# In baseline mode a pass is not good news — it means the case measures the
# model's own habits, not the rules — so the exit code is informational.
[ "$MODE" = baseline ] && exit 0
[ "$failn" -eq 0 ]
