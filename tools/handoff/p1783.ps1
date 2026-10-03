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

# THE UNDERCROFT SHOWS THROUGH THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .screen.on { display:flex; }
'@ @'
  .screen.on { display:flex; }
   #title.on { background:rgba(9,15,40,.80); }   /* v17.83: the Undercroft shows through the title */
'@

SubRx @'
var state='hub',lastTs=0;
'@ @'
var state='hub',lastTs=0;
// v17.83, THE VISUAL PASS (2026-10-02): THE UNDERCROFT SHOWS THROUGH THE TITLE. The title sat on a flat gradient with nothing
// behind it. The floor is built while the title is up and drawn beneath it, people milling, the way a AAA title shows its
// world; the title keeps a dark glass over it (the CSS rule on #title.on). The floor's own belt and backpack stay off until
// the title goes. Nothing the title does changes: ENTER THE UNDERCROFT still runs its own go().
function titleOn(){ var t=document.getElementById('title'); return !!(t&&t.classList.contains('on')); }
function titleSceneReady(){
  if(HB) return true;
  try{ HB=buildHub(); if(!hubGround) hubGround=bakeHubGround(); }catch(_ts){ HB=null; }
  return !!HB;
}
'@

SubRx @'
  if(state==='hub'){
    try{ craftHoldStep(dt); }catch(_ch){}   // v11.75: the craft hold fills here
'@ @'
  if(state==='hub'){
    try{ craftHoldStep(dt); }catch(_ch){}   // v11.75: the craft hold fills here
    if(!HB&&titleOn()) titleSceneReady();   // v17.83: the floor under the title
'@

SubRx @'
        if(hubBagOpen) drawHubBag(); else drawHubBelt();
'@ @'
        if(!titleOn()){ if(hubBagOpen) drawHubBag(); else drawHubBelt(); }   // v17.83: not under the title
'@

SubRx @'
var VER='17.82';
'@ @'
var VER='17.83';
'@

$pat = "(?m)^  now:'v17\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.83: The title screen now has the Undercroft behind it, under dark glass. Check 17.83 fails on v17.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
