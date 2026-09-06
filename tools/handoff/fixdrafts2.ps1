$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to p1184, p1185, p1190, p1191, p1192 from the 2026-09-06 read-only
# review (workflow wf_27344e1d-0ec). Blocks are built from line arrays (a
# here-string cannot hold the drafts' own '@ lines); line breaks match \r?\n.
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
$STAMPS83 = L @('# STAMPS.', "SubRx @'", "var VER='11.83';")
$STAMPS84 = L @('# STAMPS.', "SubRx @'", "var VER='11.84';")
$STAMPS89 = L @('# STAMPS.', "SubRx @'", "var VER='11.89';")
$STAMPS90 = L @('# STAMPS.', "SubRx @'", "var VER='11.90';")
$STAMPS91 = L @('# STAMPS.', "SubRx @'", "var VER='11.91';")

# p1184: a piercing round is one shot and must be one hit, or accuracy passes
# 100 percent, the exact thing the pellet rule guards.
RepRx 'p1184.ps1' $STAMPS83 (L @(
  '# ONE SHOT, ONE HIT: a round that passes through two crawlers is still one hit',
  "# against its one shot, or the run report's accuracy climbs past 100 percent",
  '# (the pellet rule in fireWeapon exists for exactly this).',
  "SubRx @'",
  '              G.tel.hits++;',
  '              // Hit feedback at the reticle. The sprite flash and spark happen out',
  "'@ @'",
  '              if(!b._hitTold){ b._hitTold=1; G.tel.hits++; }   // v11.84: one hit per round, however many it passes through',
  '              // Hit feedback at the reticle. The sprite flash and spark happen out',
  "'@",
  '',
  $STAMPS83)) 1

# p1185: the font-count comment above drawMapOverlay and the DEVNOW figure.
RepRx 'p1185.ps1' $STAMPS84 (L @(
  '# The comment that counts the font calls in drawMapOverlay counts one more now.',
  "SubRx @'",
  '  // Declared here so it shadows the global for this function only. All fourteen',
  "'@ @'",
  '  // Declared here so it shadows the global for this function only. All fifteen',
  "'@",
  "SubRx @'",
  '  // fourteen. hudRes() is exactly 1 at 1920x1080, so that screen is unchanged.',
  "'@ @'",
  '  // fifteen. hudRes() is exactly 1 at 1920x1080, so that screen is unchanged.',
  "'@",
  '',
  $STAMPS84)) 1
RepRx 'p1185.ps1' "fails on v11.84 at 13px.'" "fails on v11.84, which drew both in the micro face (15.6px at 1080p, 13px at the text floor).'" 1
RepRx 'p1185.ps1' 'Check 11.85 records every fillText the map overlay makes and requires the EXTRACT names at 18px or more and their countdown lines at 15px or more, with at least one of each drawn;' 'Check 11.85 records every fillText the map overlay makes and requires the EXTRACT names in the callout face and their countdown lines in the label face, measured against the fixture type table, with at least one of each drawn;' 1

# p1190: the highlight stays on the pressed cell (the derived gun cell is
# blanked by the dedupe once the gun is in hand, so pointing G.hot at it read
# EMPTY and killed the trigger); an empty Medical cell cannot be dragged (it
# shows a bandage it does not hold); the Undercroft belt drags derived cells too.
RepRx 'p1190.ps1' (L @(
  '      if(_gk&&G.player.wep.id!==_gk&&G.player.sec&&G.player.sec.id===_gk) swapGuns();',
  '      G.hot=G.player.swapped?1:0;',
  '    }')) (L @(
  '      if(_gk&&G.player.wep.id!==_gk&&G.player.sec&&G.player.sec.id===_gk) swapGuns();',
  '      // The highlight stays on the pressed cell: once the gun is in hand the',
  '      // derived gun cell is blanked by the dedupe, so pointing at it read EMPTY.',
  '    }')) 1
RepRx 'p1190.ps1' "        var _dk=_hs2?(_hs2.itemKey||((_hs2.kind==='heal'||_hs2.kind==='armor'||_hs2.kind==='throw')&&_hs2.icon&&ITEMS[_hs2.icon]?_hs2.icon:null)):null;" "        var _dk=_hs2?(_hs2.itemKey||((_hs2.kind==='heal'||_hs2.kind==='armor'||_hs2.kind==='throw')&&_hs2.icon&&ITEMS[_hs2.icon]&&(_hs2.kind!=='heal'||_hs2.count>0)?_hs2.icon:null)):null;   // an empty Medical cell shows a bandage it does not hold" 1
RepRx 'p1190.ps1' $STAMPS89 (L @(
  '# AND THE UNDERCROFT BELT, which had the same fault: only an assigned cell dragged.',
  "SubRx @'",
  '          var _sl=hotbarSlots()[_H.i];',
  "          if(_sl&&_sl.itemKey){ G.drag={key:_sl.itemKey,fromHot:_H.i}; blip('pick'); }",
  "'@ @'",
  '          var _sl=hotbarSlots()[_H.i];',
  "          // v11.90, HIS NOTE: the floor's belt drags derived cells by the item they show too.",
  "          var _sdk=_sl?(_sl.itemKey||((_sl.kind==='heal'||_sl.kind==='armor'||_sl.kind==='throw')&&_sl.icon&&ITEMS[_sl.icon]&&(_sl.kind!=='heal'||_sl.count>0)?_sl.icon:null)):null;",
  "          if(_sl&&_sl.kind!=='gun'&&_sdk){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }",
  "'@",
  '',
  $STAMPS89)) 1

# p1191: the hub keydown branch keeps its own copy of the gate; fold _titleUp
# into it (SPACE, H, TAB and I), and give the bumped card its line.
RepRx 'p1191.ps1' $STAMPS90 (L @(
  '# The keydown branch keeps its own hand-written copy of the same gate; the',
  '# already-computed flag folds into it, so SPACE, H, TAB and I stop too.',
  "SubRx @'",
  "    var _hubBusy=!!(document.querySelector('.modal.on')||document.querySelector('.imenu')||",
  "'@ @'",
  "    var _hubBusy=!!(_titleUp||document.querySelector('.modal.on')||document.querySelector('.imenu')||   // v11.91: the character screen counts here too",
  "'@",
  "SubRx @'",
  "      if(document.querySelector('.imenu')) _anyModal=true;",
  '      if(!_anyModal){',
  "'@ @'",
  "      if(document.querySelector('.imenu')) _anyModal=true;",
  '      if(_titleUp) _anyModal=true;   // v11.91',
  '      if(!_anyModal){',
  "'@",
  '',
  $STAMPS90)) 1
RepRx 'p1191.ps1' (L @(
  "SubRx @'",
  "var WHATSNEW_VER='11.90';",
  "'@ @'",
  "var WHATSNEW_VER='11.91';",
  "'@")) (L @(
  "SubRx @'",
  "var WHATSNEW_VER='11.90';",
  "'@ @'",
  "var WHATSNEW_VER='11.91';",
  "'@",
  "SubRx @'",
  "  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',",
  "'@ @'",
  "  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',",
  "  'THE CHARACTER SCREEN NO LONGER LETS KEYS THROUGH TO THE FLOOR BEHIND IT. E, R, F and T reached the stations under it, and R at the lift started a raid.',",
  "'@")) 1

# p1192: the right-click menu stops offering the pocket for what it now
# refuses, and the refusal names the class (smoke and decoy are not grenades).
RepRx 'p1192.ps1' "  if(k&&ITEMS[k].use==='throw') return 'A grenade rides in the pouch, not a pocket. It cannot come home from there.';" "  if(k&&ITEMS[k].use==='throw') return 'A throwable rides in the pouch, not a pocket. It cannot come home from there.';" 1
RepRx 'p1192.ps1' "  'THE SAFE POCKET REFUSES A GRENADE OR AN AMMO BOX. Neither rides in the backpack, so neither could ever come home from it; the pocket said 1/1 anyway.'," "  'THE SAFE POCKET REFUSES A THROWABLE OR AN AMMO BOX. Neither rides in the backpack, so neither could ever come home from it; the pocket said 1/1 anyway.'," 1
RepRx 'p1192.ps1' $STAMPS91 (L @(
  '# The right-click menu offered the pocket for the same items; a verb the game',
  '# cannot perform is the rule that file states twelve lines above the row.',
  "SubRx @'",
  "  if(it.use!=='gun'){",
  '    var _isSafe=(P.safe===key);',
  "'@ @'",
  "  if(it.use!=='gun'&&it.use!=='throw'&&it.use!=='ammo'){   // v11.92: the pocket refuses these, so the menu does not offer it",
  '    var _isSafe=(P.safe===key);',
  "'@",
  '',
  $STAMPS91)) 1
