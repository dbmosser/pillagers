#!/bin/bash
# genP.sh N : write mk-card-autoPN.ps1, a What's New card refresh with a generic true line (POLISH PASS N), from the A3 template.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"; n=$1
sed -e "s/draft-card-autoA3.json/draft-card-autoP$n.json/" \
    -e "s|^\$Line='.*'\$|\$Line='POLISH PASS $n. More fixes to the screens, the sounds and two player play.'|" \
    -e "s|indexOf('MORE'+' POLISH.')|indexOf('POLISH'+' PASS $n.')|" \
    -e "s|title='THE WHAT IS NEW CARD NAMES THE POLISH PASS'|title='THE WHAT IS NEW CARD NAMES POLISH PASS $n'|" \
    -e "s|now='The what is new card names the polish pass.'|now='The what is new card names polish pass $n.'|" \
    "$S/mk-card-autoA3.ps1" > "$S/mk-card-autoP$n.ps1"
