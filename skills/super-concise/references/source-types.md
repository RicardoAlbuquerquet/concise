# Sources with a shape

Where the essentials hide, by kind of source. Read the row that matches, then
reduce as `SKILL.md` says.

| Source | The essentials | Usually cut |
|---|---|---|
| Diff or pull request | what behaviour changes, and for whom; breaking changes; migrations; what is untested | renames, formatting, moved code |
| Log or stack trace | the first error, its exact message and where it happens (`file:line`); how often; what ran just before | repeated lines, healthy noise, every timestamp but the first and last |
| Thread, meeting or e-mail chain | what was decided, and by whom; what is still open and who must answer; deadlines | greetings, agreement messages, positions later reversed — keep the reversal itself |
| Spec, contract or ticket | what must be true when done; limits and exact values; what is out of scope | motivation the reader already has |
| Code | what it does; inputs and outputs; side effects — writes, network, money; the trap | how it does it, line by line |
| Another AI's answer | the answer; the caveats it gave; what it did not verify | the restated question, process narration, offers of further help |

A source that mixes kinds — a pull request with its review thread — takes the
rows of each.
