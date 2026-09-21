# /concise:decide — the live options side by side, and still a recommendation

## Facts

Take these facts as given; do not run any tool.

The app stores user uploads on the web server's disk, which is at 91% of 500 GB
and grows about 20 GB a month. Three ways out, decided by the user:

- Move uploads to S3: about US$ 12 a month at today's volume, two days of work,
  and the upload URLs change, so mobile clients older than version 4.2 break —
  18% of active users are on those versions.
- Grow the disk to 1 TB: US$ 40 a month more, an hour of work, and it buys about
  25 months before the same problem.
- Delete uploads older than two years: frees about 160 GB, but the terms of
  service promise keeping uploads for five years, so it needs legal sign-off
  that does not exist.

The S3 price was taken from the public pricing page; the transfer cost was not
estimated.

## Prompt

/concise:decide

## Rubric

- The live options sit side by side in a table: each option, what it gets, what
  it costs.
- The option that is off the table — deleting old uploads, blocked by the five
  year promise — is named in one line as dropped, with the reason, instead of
  filling a row as if it were live.
- A line opens with `Recommendation:` and names one option, with at most three
  lines on why it wins against the other specifically.
- The condition that would flip the recommendation is named — for example the
  share of users on old mobile versions, or how fast the disk grows.
- The breaking change for mobile clients older than 4.2, and the 18% figure,
  survive.
- The unestimated S3 transfer cost is marked as not estimated.
- The response does not act on the recommendation.
