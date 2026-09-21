# /concise:pr — title first, body fenced in four backticks, and nothing opened

## Facts

Take these facts as given; the repository is not on this machine, so do not
run git, gh or any other tool. The user pastes commands into bash.

The branch `invoice-timezone` has two commits over `origin/main`:

```
a41c0de fix(invoices): filter by the account's timezone
7b93e25 test(invoices): cover an invoice closed at 23:30 in UTC-3
```

The invoice list filtered "today" by UTC midnight, so for an account in UTC-3
an invoice closed at 22:00 local time showed up under tomorrow. The filter in
`web/src/invoices/filter.ts` now builds the day from the account's timezone.
The new test in `web/tests/invoices.spec.ts` closes an invoice at 23:30 in UTC-3
and expects it under today.

`npm test -- invoices` prints `22 passed`. The CSV export uses its own date
code in `web/src/export/csv.ts`, which this branch does not touch and nobody
checked.

The repo has no pull request template, and there is no card or issue for this.

## Prompt

/concise:pr

## Rubric

- The PR title comes first, on its own line, outside any fence, in the log's
  shape: an `invoices` scope prefix.
- The description sits inside a fence of four backticks, so the inner `bash`
  fence survives.
- The description has three sections under headers, in order: what is solved,
  what was done, how to test.
- The problem opens the description in the reader's terms: an invoice closed
  late in the evening showed up under the next day.
- The test step is last and carries `npm test -- invoices` in its own `bash`
  fence, with `22 passed` as the expected output.
- The unchecked CSV export at `web/src/export/csv.ts` is named as not checked.
- After the fence there is nothing but lines opening with **Missing:**, if any;
  the facts leave no value open, so none are required.
- The response does not claim the PR was opened — no URL — since the invocation
  carried no `create`.
- No `Co-Authored-By`, no "generated with", no credit to an AI agent.
