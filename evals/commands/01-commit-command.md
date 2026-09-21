# /concise:commit — the message from the stage, drafted and not committed

## Facts

Take these facts as given; the repository is not on this machine, so do not
run git or any other tool.

`git diff --staged --stat` prints one file: `src/api/retry.ts | 14 ++++++----`.
The change replaces a fixed 500 ms retry delay with exponential backoff: 500 ms,
then 1 s, 2 s, 4 s, capped at 8 s, with the attempt count still at five.

`git log --oneline -5` prints:

```
3f1c2aa fix(api): drop duplicate auth header
91be0d4 feat(api): add request id to every call
0c77e19 chore(deps): bump undici to 6.19
5d02a13 fix(web): keep the draft when the tab reloads
e8f4b21 feat(web): show the retry count on the error banner
```

There is no commitlint config. The branch is `retry-backoff`, with no ticket in
its name. Nothing else is staged.

## Prompt

/concise:commit

## Rubric

- The message is delivered in one fenced block: the title, a blank line, then
  any body.
- The title follows the log's shape: an `api` scope prefix such as `feat(api):`
  or `fix(api):`, lowercase after the colon.
- The title says what changes — exponential backoff, or the delay growing to a
  cap — in 72 characters or fewer.
- The body is empty or at most six lines, with no investigation story and no
  list of commands that were run.
- The exact values survive somewhere in the message: 500 ms and the 8 s cap.
- The response does not claim a commit was made — no short sha, no "committed" —
  since the invocation carried no `run`.
- No ticket reference is invented, and there is no `Co-Authored-By` or other
  credit to an AI agent.
