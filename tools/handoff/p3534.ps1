$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# NOTHING BEHIND THE TITLE, NO ROBOTS IN THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!HB&&titleOn()) titleSceneReady();   // v17.83: the floor under the title
'@ @'
    // v35.xx (cw-titleplain), HIS ORDER (2026-10-27): "get rid of the graphics behind the title screen -- they make no sens,e, there are robots inside the
    // undercroft??? that should never happen". v17.83 built the Undercroft floor while the title was up and drew it under the title glass, people milling
    // and, since cw-title-fight, a pillager and a sentry fighting each side of the menu. The title now sits on a plain dark backdrop (titlePlainBack): no
    // floor is built for it and none is drawn under it. A floor that already exists (the title called back from the floor, a party still linked) keeps its
    // update here as before; only its drawing stops. ENTER THE UNDERCROFT builds and draws the floor as it always has (showScreen).
    if(titleOn()){ if(HB){ try{ updateHubWorld(dt); }catch(_tpu){} } if(wc&&W>0) titlePlainBack(); return; }
'@

SubRx @'
  try{ HB=buildHub(); if(!hubGround) hubGround=bakeHubGround(); }catch(_ts){ HB=null; }
  return !!HB;
}
'@ @'
  try{ HB=buildHub(); if(!hubGround) hubGround=bakeHubGround(); }catch(_ts){ HB=null; }
  return !!HB;
}
// v35.xx (cw-titleplain), his order (2026-10-27): the title's own backdrop. The world canvas is one flat menu colour (--ui-bg, #111315) under the
// title glass and the HUD canvas holds nothing, so no floor, no figure and no machine shows behind the title. titleSceneReady above stays for a
// crate a teammate drops before this window has a floor (v18.58); the title no longer calls it.
function titlePlainBack(){
  try{ wc.save(); wc.setTransform(1,0,0,1,0,0); wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; wc.fillStyle='#111315'; wc.fillRect(0,0,wc.canvas.width,wc.canvas.height); wc.restore(); }catch(_tpw){}
  try{ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.clearRect(0,0,ctx.canvas.width,ctx.canvas.height); ctx.restore(); }catch(_tph){}
}
'@

SubRx @'
  // v28.xx (cw-title-fight), Q52/Q54: the fights under the title and the attract pages, sorted with everything else.
  if(tskOn()){ try{ if(!TSK) tskInit(); tskStep(dt); for(i=0;i<TSK.ents.length;i++) DR.push({k:TSK.ents[i].y,tk:TSK.ents[i]}); DR.push({k:99999,tk:{kind:'fx'}}); }catch(_tk){} }

'@ @'
  // v35.xx (cw-titleplain), HIS ORDER (2026-10-27): "there are robots inside the undercroft??? that should never happen". The title fight (cw-title-fight,
  // a pillager and a sentry each side of the menu, also on the floor behind the arcade attract pages) is no longer put on the floor: no machine is drawn here.

'@

SubRx @'
    } else if(it.tk){ try{ tskDraw(it.tk); }catch(_td){ try{ wc.restore(); }catch(_tr){} }
    } else if(it.np){
'@ @'
    } else if(it.np){
'@

SubRx @'
var TSK=null;
'@ @'
// v35.xx (cw-titleplain), his order 2026-10-27: the fight is off the floor (no robots in the Undercroft) and nothing calls tskInit, tskStep or tskDraw
// now; tskOn still keeps the floor labels and the belt off under the title and the attract pages.
var TSK=null;
'@

SubRx @'
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.crowd===0) continue; (byKind[c.kind]=byKind[c.kind]||[]).push(c.id); }
'@ @'
    // v35.xx (cw-titleplain), HIS ORDER (2026-10-27): "there are robots inside the undercroft??? that should never happen". Nobody in the crowd wears
    // The Machine (outrobot), the one outfit that is a robot; it stays on the rack for him, and The Android and The Trooper (people) still roll.
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.crowd===0||c.id==='outrobot') continue; (byKind[c.kind]=byKind[c.kind]||[]).push(c.id); }
'@

SubRx @'
var VER='35.33';
'@ @'
var VER='35.34';
'@

$pat = "(?m)^  now:'v35\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.34: the title sits on a plain dark backdrop; no sentry fight on the floor and nobody in the crowd wears The Machine Check 35.34 fails on v35.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
