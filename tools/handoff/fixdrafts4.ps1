$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to 1194 to 1198 from the second read-only review (workflow
# wf_0c8f925a-511). Blocks from line arrays; line breaks match \r?\n;
# idempotent.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($file + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}

# 1194: the keyboard half is not true (Tab is swallowed on the floor), so the
# card and DEVNOW say what works; the check restores the stash and the BUY pane.
RepRx 'p1194.ps1' "  'A CONTROLLER OR THE KEYBOARD CAN CRAFT AGAIN. The hold is the mouse way; a pad press or Enter on the button crafts at once.'," "  'A CONTROLLER CAN CRAFT AGAIN. The hold is the mouse way; a pad press on the button crafts at once.'," 1
RepRx 'p1194.ps1' "Check 11.94 crafts through a synthetic click and through Enter, requires a detail-1 click to spend nothing" "Check 11.94 crafts through a synthetic click (the pad press), requires a detail-1 click to spend nothing" 1
RepRx 'p1194.ps1' "now:'v11.94: from the read-only review of the shipped v11.75, the hold-to-craft build deleted the only way a controller (synthetic click) or the keyboard (Enter) could press CRAFT." "now:'v11.94: from the read-only review of the shipped v11.75, the hold-to-craft build deleted the only way a controller (a synthetic click from the pad) could press CRAFT." 1
RepRx 'f1194.ps1' "     var bad=[], P=__P(), md=document.getElementById('tradermodal');" "     var bad=[], P=__P(), md=document.getElementById('tradermodal'), keepStash=(P.stash||[]).slice();" 1
RepRx 'f1194.ps1' "     finally{ try{ if(md) md.style.display=''; craftHoldCancel(); var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); }catch(_c){} __topClear(); __cleanProfile(); }" "     finally{ try{ if(md) md.style.display=''; craftHoldCancel(); try{ openTrader('buy'); }catch(_ob){} var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); P.stash=keepStash; saveProfile(); }catch(_c){} __topClear(); __cleanProfile(); }" 1
RepRx 'f1194.ps1' "what:'the bench detail button crafts on a synthetic click (a pad press or Enter) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)'" "what:'the bench detail button crafts on a synthetic click (a pad press) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)'" 1
RepRx 'f1195.ps1' "what:'the bench detail button crafts on a synthetic click (a pad press or Enter) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)'" "what:'the bench detail button crafts on a synthetic click (a pad press) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)'" 2

# 1195: the 11.79 what-line follows its assertion; the shop line names all four;
# two comments say what the recipes actually eat.
RepRx 'f1195.ps1' (L @(
  "     if(green<1||blue<1) bad.push('the bench holds '+green+' green and '+blue+' blue gun recipes, not at least one of each');   // v11.95: the Carbine is blue by dispR",
  "'@")) (L @(
  "     if(green<1||blue<1) bad.push('the bench holds '+green+' green and '+blue+' blue gun recipes, not at least one of each');   // v11.95: the Carbine is blue by dispR",
  "'@",
  "SubRx @'",
  "  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',",
  "'@ @'",
  "  {v:'11.79',what:'four guns are on the crafting bench, one green and three blue by the rarity every screen shows, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',",
  "'@")) 1
RepRx 'p1195.ps1' "    h+='<div class=""vdesc"">The Carbine, the Scattergun and the Auto Rifle can also be built at the crafting bench.</div>';" "    h+='<div class=""vdesc"">The Compact SMG, the Burst Carbine, the Riot Scattergun and the Auto Rifle can all be built at the crafting bench.</div>';" 1
RepRx 'p1195.ps1' (L @(
  '    // v11.95: three of those can be built now (v11.79); a separate line, because',
  '    // the sentence above is a key for his own rewording of it.')) (L @(
  '    // v11.95: two of those, plus the SMG and the Auto Rifle, can be built now',
  "    // (v11.79); a separate line, because the sentence above is a key for his",
  '    // own rewording of it.')) 1
RepRx 'p1195.ps1' (L @(
  '  // v11.95: it is back, and the optic with it, because the four gun recipes of',
  '  // v11.79 eat both; SELL ALL keeps them and the stash says what for.')) (L @(
  '  // v11.95: it is back, and the optic with it, because the four gun recipes of',
  '  // v11.79 eat the servo and one of them the optic; SELL ALL keeps them and',
  '  // the stash says what for.')) 1

# 1196: the valid tab is buy; the pane and the menu zoom are pinned before
# measuring, as check 11.78 does; the card gets its line.
RepRx 'f1196.ps1' "       openTrader('shop');" "       openTrader('buy');" 1
RepRx 'f1196.ps1' (L @(
  '       __topClear(); __cleanProfile();',
  "       G=null; keys={}; __showScreen('hub'); __hubEnter(); saveProfile();",
  "       openTrader('buy');")) (L @(
  '       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();',
  '       try{ if(window.__forceSize) __forceSize(1920,1080); }catch(_fs){}   // the modal zoom follows the pane; pinned so the control means the same on every run',
  "       G=null; keys={}; __showScreen('hub'); __hubEnter(); saveProfile();",
  "       openTrader('buy');")) 1
RepRx 'p1196.ps1' (L @(
  "SubRx @'",
  "var WHATSNEW_VER='11.95';",
  "'@ @'",
  "var WHATSNEW_VER='11.96';",
  "'@")) (L @(
  "SubRx @'",
  "var WHATSNEW_VER='11.95';",
  "'@ @'",
  "var WHATSNEW_VER='11.96';",
  "'@",
  "SubRx @'",
  "  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',",
  "'@ @'",
  "  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',",
  "  'THE STATION WINDOWS NO LONGER REPEAT YOUR BALANCE IN THEIR HEADING. The corner readout has it, at all times.',",
  "'@")) 1

# 1197: the near edge also covers the thrower's own body, and never climbs
# above his reach, so a short-ranged pillager keeps his throw.
RepRx 'p1197.ps1' (L @(
  '  // v11.97: the near edge of the band follows the blast radius (it was 180',
  '  // against a 150 blast; at 190 he stood in his own charge), plus the scatter',
  '  // of the aim point below.',
  "  var _fR=(CFG.fragR===undefined?190:CFG.fragR);",
  '  if(fd<_fR+40||fd>520) return false;')) (L @(
  '  // v11.97: the near edge of the band follows the blast radius (it was 180',
  '  // against a 150 blast; at 190 he stood in his own charge), plus the scatter',
  '  // of the aim point below and his own body; and never above his reach, or a',
  '  // short-ranged pillager could never throw at all.',
  "  var _fR=(CFG.fragR===undefined?190:CFG.fragR);",
  '  if(fd<Math.min(_fR+52,(e.rng||520)-1)||fd>520) return false;')) 1
RepRx 'p1197.ps1' "the pillager throw band near edge (180, inside a 190 blast) now follows the radius plus 40;" "the pillager throw band near edge (180, inside a 190 blast) now follows the radius plus 52 (scatter and body), floored at his reach;" 1
RepRx 'f1197.ps1' "what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 40 (230 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)'" "what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 52 (242 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)'" 1
RepRx 'f1198.ps1' "what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 40 (230 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)'" "what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 52 (242 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)'" 2
RepRx 'f1197.ps1' "         e.bag=['frag']; e.thrT=0; e.smkT=99; e.hp=e.maxhp||100; e.downed=false;" "         e.bag=['frag']; e.thrT=0; e.smkT=99; e.hp=e.maxhp||100; e.downed=false; e.rng=Math.max(e.rng||0,520);   // a long-armed pillager, so the reach floor is not what stops him" 1

# 1198: the banner's exact words (with the mark), the v11.74 comment names
# the map's copy, and check 11.85's filter follows the wording.
RepRx 'p1198.ps1' "      else if(_zHold) _zSub='EXTRACT NOW  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v11.98: the same words as the banner (v11.74), the letter is the line above" "      else if(_zHold) _zSub='EXTRACT NOW!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v11.98: the banner's words (v11.74); the letter is the line above" 1
RepRx 'f1198.ps1' "       if(!subs.some(function(t){ return t.indexOf(newWords)===0&&/12S LEFT/.test(t); })) bad.push('the map does not say '+newWords+' with the seconds left (drew: '+subs.join(' | ').slice(0,80)+')');" (L @(
  "       if(!subs.some(function(t){ return t.indexOf(newWords)===0&&/12S LEFT/.test(t); })) bad.push('the map does not say '+newWords+' with the seconds left (drew: '+subs.join(' | ').slice(0,80)+')');",
  "       if(!subs.some(function(t){ return t.indexOf(newWords+'!')===0; })) bad.push('the map line lacks the banner mark');")) 1
RepRx 'f1198.ps1' (L @(
  "# v11.98 CHECK, inserted before the v11.97 entry. A ring is put into the",
  "# hold state and the map overlay drawn with the canvas text call recorded.")) (L @(
  "# CHECK 11.85's line filter follows the new wording, so the landed-hold line",
  "# stays under its label-face floor.",
  "SubRx @'",
  "       var subs=rec.filter(function(r){ return /^(closes in |STAYS OPEN|CLOSED|CALLED |OPEN TO EXTRACT)/.test(r.t); });",
  "'@ @'",
  "       var subs=rec.filter(function(r){ return /^(closes in |STAYS OPEN|CLOSED|CALLED |EXTRACT NOW)/.test(r.t); });",
  "'@",
  "",
  "# v11.98 CHECK, inserted before the v11.97 entry. A ring is put into the",
  "# hold state and the map overlay drawn with the canvas text call recorded.")) 1
