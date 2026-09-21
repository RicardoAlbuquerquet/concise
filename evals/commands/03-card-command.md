# /concise:card — a card that stands alone, with the missing value named

## Facts

Take these facts as given; do not run any tool.

On the mobile web checkout, tapping "Pay" twice quickly charges the card twice.
You reproduced it on an Android phone in Chrome: add any item, open checkout,
tap "Pay" twice within half a second, and two charges of the same amount appear
in the payment provider's dashboard. The button has no disabled state while the
first request is in flight. The desktop checkout was not tried. The board holds
several areas; this one belongs to Checkout. Nobody recorded the Chrome
version.

## Prompt

/concise:card

## Rubric

- The title is on the first line, outside the fence, opens with the area
  (`Checkout: …`) and says what changes or what is broken.
- The body is delivered in a fenced block, ready to paste.
- The body states the current behaviour and the expected behaviour.
- The reproduction is given as numbered steps.
- The open question is named: whether the desktop checkout does the same.
- A done criterion appears: what has to be true to close the card.
- The missing Chrome version is named as a hole rather than invented.
- The body has no `##` headers and nothing that only makes sense to a reader of
  this conversation ("as discussed", "the bug above").
- The card is not reported as created anywhere, since no destination was named.
