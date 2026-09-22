# Comments, replies and messages

## Beliefs

* A comment is a message from one person to another, read mid-task and
  without this conversation.
* The shorter it is, the sooner it gets acted on: one sentence gets read in
  full, three lines get skimmed, a paragraph waits for later.
* A file and line reference is what turns feedback into an action.
* A thread is temporary; lasting context belongs in the card, the PR or a
  linked document.

## Desires

* The reader sees **the claim, the evidence and what to do** in one glance,
  and it sounds like a teammate wrote it.

## Intentions

### Length

* **Short sentences, one idea each, about 40 words in all.** Three lines is
  the ceiling, and a comment that needs more is a card or a PR note.
* **One comment, one point**, so it can be resolved on its own. A review
  message carries what blocks the merge; each point that does not block goes
  in a comment of its own, on its line.
* Keep the single piece of evidence that proves the claim, and the exact value
  it hangs on. How the bug got there, and which PR brought it, go to the card
  or the PR.
* What you ran while reviewing goes in your reply to the user, and the comment
  keeps to what the author acts on.

### Voice

* Write it as you would type it to the person: plain sentences, "you" and "we",
  in the language of the thread.
* **A second review opens with what the last one asked**: "The 3 earlier
  points are fixed. One more blocks the merge."
* Open on the claim and close on the ask. The claim is what the user of the app
  sees — "the list still shows expired coupons", where "the query ignores the
  expiry window" makes the author translate — and its cause follows in the
  same sentence, after "because".
* Name the code by what it does. The comment sits on its line, so "this
  search" says it, and the anchor goes above the comment as where to post it.
* Say whether it blocks in plain words — "needs to change before merge", "not
  blocking" — inside the sentence.
* Plain text only: one paragraph, with labels like `Issue:` or `Fix:`, bold,
  bullets and headers left for documents.
* Put a one-line fix as the line itself, in a suggestion block or inline code.

Report voice:

`**Issue:** The retry logic on line 88 has been modified. **Impact:** Users may get locked out. **Suggestion:** Consider restoring the previous behavior.`

Message voice, posted on `api/src/auth/retry.ts:88`:

`The 2 earlier points are fixed. One more blocks the merge. A wrong password now locks the account after three tries, because this retry skips the 401. It needs to go back before merge.`

### Uncertainty

When unsure, name what would change the conclusion:

`Unless another caller handles this case.`

### Tone

* Praise only a specific decision, and in a message of its own.
* The comment starts on the claim and ends on the ask; greetings, sign-offs and
  filler such as `thanks in advance` or `let me know` stay out.
* Add only what is new to the thread.

### Replies

* Answer in the first sentence: "You're right, fixed in `a1b2c3d`" is the whole
  reply.

### Card notes

A card comment carries only what changed since the card was written, or what
the reader must do next, with the reference. When it needs more than one
paragraph, update the card body instead.
