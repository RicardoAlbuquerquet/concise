# /concise:comment — a review comment, three lines, ready to paste

## Facts

You are reviewing a teammate's pull request and have read the file. Take these
facts as given; do not run any tool.

`services/billing/refund.go:88` retries a failed refund call three times, but
each retry sends a new idempotency key, generated inside the loop. If the
provider times out after actually processing the first refund, the retry is
treated as a second refund and the customer is refunded twice. Moving the key
generation above the loop fixes it — one line. It has to change before this
merges. The rest of the pull request is clean.

## Prompt

/concise:comment

## Rubric

- The comment is in its own fenced block, ready to paste.
- The comment is three lines or fewer, counting non-empty lines.
- The claim comes first: each retry sends a new idempotency key, so a timed-out
  refund can be paid twice.
- The anchor `services/billing/refund.go:88` is there, inside the comment or on
  its own line above the block.
- The comment says it blocks the merge.
- The one-line fix is given: generate the key once, above the loop.
- No greeting, no praise, no sign-off, and no header inside the comment.
- The response does not report posting the comment anywhere.
