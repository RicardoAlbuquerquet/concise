---
description: Draft a comment or message — short, and written like one
argument-hint: "[subject, optionally destination]"
---

Draft one comment or message. First read
`${CLAUDE_PLUGIN_ROOT}/references/comment.md`; it defines the writing rules.

Use the argument as the subject. If empty, use the most recent relevant
context.

$ARGUMENTS

Process:

1. Read the exact thing being commented on: line, thread, card, or message.
   If the relevant context is unavailable, say so and stop.
2. Determine the kind: review comment, thread reply, card note, or direct
   message. If unclear, assume review comment and state the assumption.
3. Write it as a message to the person: one or two plain sentences, under 40
   words, the claim first with its one piece of evidence, the anchor, and
   whether it blocks in plain words. A reply answers in the first sentence; a
   one-line fix arrives as the line itself.
4. Cut it once more: drop every word the reader can act without, keeping the
   anchor and the exact value. Past three lines, the reasoning moves to the
   card or the PR.

Output each comment in its own fenced block, ready to paste. Use four
backticks when the comment contains a fence. For multiple comments, put the
anchor above each block, e.g. `api/src/auth/retry.ts:88`.

Afterward, include only unresolved information as `Missing: ...`, one per
line.

Draft only by default. If a reachable destination is provided, show the
draft and exact target. Post only after explicit user approval in this
conversation.
