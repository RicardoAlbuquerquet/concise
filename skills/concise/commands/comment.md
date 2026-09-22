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
3. Write it as a message to the person: short plain sentences, one idea
   each, about 40 words in all. A second review opens with what the last one
   asked. Then the claim as the user of the app sees it, its cause after
   "because", the code named by what it does, and whether it blocks in plain
   words. A reply answers in the first sentence; a one-line fix arrives as the
   line itself.
4. Cut it once more: drop every word the reader can act without, keeping the
   anchor and the exact value. Past three lines, the reasoning moves to the
   card or the PR.

Output each comment in its own fenced block, ready to paste. Use four
backticks when the comment contains a fence. Put the anchor above each block,
e.g. `api/src/auth/retry.ts:88`: it says where the comment goes, so the text
inside can say "this search".

Afterward, include only unresolved information as `Missing: ...`, one per
line.

Draft only by default. If a reachable destination is provided, show the
draft and exact target. Post only after explicit user approval in this
conversation.
