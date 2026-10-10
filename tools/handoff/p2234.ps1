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

# THE PAD WALK NO LONGER DRAWS THE PACKED GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&sl[i].vacant)) break; }
  setHot(i);
}
'@ @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&sl[i].vacant)) break; }
  // v22.34, from the review of the four-gun belt (build 3): THE PAD WALK NO LONGER DRAWS EVERY PACKED GUN IT PASSES. setHot reads a
  // press on a key showing a gun in the backpack as an order to draw it, so RB from key 2 to Smoke on key 5 brought the gun on key
  // 3 up, then the gun on key 4, and he reached Smoke holding a gun he never chose, each draw cancelling a reload. The walk now only
  // moves the highlight onto such a key and names it; the trigger draws it (and fires nothing on that press), the way a number key
  // draws it at once.
  if(bagGunCell(sl[i])){
    G.hot=i;
    if(!G.sim) say(String(sl[i].name||'Gun').toUpperCase(),'info',{sub:padB('RT TO DRAW')});
    blip('pick');
    return;
  }
  setHot(i);
}
// v22.34: a belt cell showing a gun that is in the backpack, not in his hands (a gun key pin or a gun he bound). The Undercroft
// preview cells (floorGun) and vacant gun keys are not.
function bagGunCell(c){ return !!(c&&c.kind==='gun'&&c.itemKey&&!c.equipped&&!c.floorGun&&!c.vacant); }
'@

SubRx @'
  var hotGun=(!HSC||(HSC.kind==='gun'&&!HSC.vacant)||HSC.kind==='item');   // v21.93: a vacant gun key fires nothing; it says which key does
'@ @'
  var hotGun=(!HSC||(HSC.kind==='gun'&&!HSC.vacant&&!bagGunCell(HSC))||HSC.kind==='item');   // v21.93: a vacant gun key fires nothing; it says which key does   // v22.34: nor does a packed gun the pad walk highlighted
'@

SubRx @'
    if(HSC&&(HSC.kind==='empty'||HSC.vacant)){
'@ @'
    // v22.34, from the review of the four-gun belt (build 3): A PACKED GUN THE PAD WALK HIGHLIGHTED IS DRAWN BY THE TRIGGER. The press
    // brings it up through setHot (by the give-up rule) and fires nothing; the next press fires it. The highlight never names one
    // gun and fires another.
    if(bagGunCell(HSC)){
      if(!p.fired){ p.fired=true; setHot(hotSel()); }
    }
    else if(HSC&&(HSC.kind==='empty'||HSC.vacant)){
'@

SubRx @'
    if(hs&&hs.kind==='gun') e=afTarget(p);
'@ @'
    if(hs&&hs.kind==='gun'&&!bagGunCell(hs)) e=afTarget(p);   // v22.34: a packed gun the pad walk highlighted is not in his hands
'@

SubRx @'
var VER='22.33';
'@ @'
var VER='22.34';
'@

$pat = "(?m)^  now:'v22\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.34: On a controller the bumpers walk past the packed guns on keys 3 and 4 without drawing them; RT draws the one you stop on. Check 22.34 fails on v22.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
