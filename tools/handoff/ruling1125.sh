#!/bin/bash
# Append the "lift it" option and its measured result to the v11.23 ruling block in AUDIT.md.
set -e
cd "/c/claudecode/dark raiders"
awk '
/Say "leave it", "peace", or "fewer waves"\.$/ && !done {
  print $0;
  print "";
  print "ADDED at v11.25, and it is NOT a fourth option after all. The audit after v11.24 found";
  print "that every place a pillager may shoot a machine or a rival is gated to 600 units of YOU,";
  print "on a comment that stopped being true long ago (the wall cache covers the whole map). The";
  print "machines hunt pillagers with no such gate, so out of your sight a pillager never fires";
  print "back: zero rounds in a whole raid against 88 from the machines. v11.25 makes the gate a";
  print "dial, engageNear, 600 as shipped, and MEASURED the lifted gate on six full raids: the";
  print "pillagers fire 1,668 rounds instead of 0, and still 294 of 318 die and 0 get out, against";
  print "252 of 281 dead and 3 out with the gate. Giving them their guns back keeps them in the";
  print "fight instead of looting and leaving. So the killing ground is the war plus the floor,";
  print "not the gate, and the three words above are still the choice. The dial stays at 600.";
  done=1; next }
{ print }' AUDIT.md > AUDIT.md.new && mv AUDIT.md.new AUDIT.md
grep -n 'ADDED at v11.25, and it is NOT a fourth option' AUDIT.md | cut -c1-80
