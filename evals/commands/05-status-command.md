# /concise:status — only what moved since the last update, bad news first

## Facts

Take these facts as given; do not run any tool. The update goes to Marina, the
product lead, in this conversation.

Your previous update, sent yesterday, said: the export redesign is on branch
`export-v2`, PR 412 is open, 3 of 4 CI jobs pass, the Excel format is still
unverified, and you need Marina to decide whether dates export as ISO or as the
account's locale.

Since then: the fourth CI job now fails — `e2e-export` times out on the 10 000
row fixture, after 180 s. Marina answered the date question yesterday: the
account's locale. You implemented that. The Excel format is still unverified.
Nothing else changed. Reviewer approval from Joao is needed before merge, and
the release freeze starts Friday 18:00.

## Prompt

/concise:status

## Rubric

- The first line carries the bad news: `e2e-export` now fails, timing out on
  the 10 000 row fixture.
- Only what moved is reported: the failing job, and the locale choice done.
  Repeating the branch name, the PR number or the still-unverified Excel as if
  new counts as restarting the story — a short clause pointing back is fine.
- What waits on someone gets its own block, apart from what only informs:
  Joao's approval, with the Friday 18:00 freeze as the deadline.
- It says when the next update comes, or what event produces it.
- The exact values survive: `e2e-export`, 10 000 rows, 180 s, Friday 18:00.
- Five lines or fewer, fences not counted.
