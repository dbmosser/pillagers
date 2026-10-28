# a03-sentence-callouts : 15 callouts are written as sentences
From the cloud audit of 2026-10-28 (tools/handoff/cloud/audit-2026-10-28.md, item 8). Text polish only.

His rule: short callouts, never an explaining sentence. These say() lines (line numbers on v35.39) are full sentences with periods:
  26876 Nothing to pick up. | 28890 Self-revive spent. One per raid. | 28899 Back on your feet. | 29534 Seal payout dropped.
  46193 and 62488 Check your map. | 54696 The mainframe wall is full. | 54697 Not enough parts. | 54761 Enter a name first.
  54769 That is not a Pillagers run report. | 54833 A core is already slotted for your next raid.
  54835 No Data Core in your stash. Find them in rare containers or on elite pillager bots. | 54847 Core slotted. Your next raid starts with intel.
  61427 Bandage, Medkit or Armour Plate. (the detail of SELECT A HEAL) | 72685 There is no profile to go back to.

Do: make each a short callout with no period (for example "self-revive spent" with "one per raid" as the detail). Never reword a
sentence that is a key in var TXSHIP (check each one against it first). Log each change in notes/ui/changes.md (his Q8 rule: say why).
One ship for the batch. TASK DONE when shipped and ON HIS PC.
