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

# MINIMAP SIZE AND ZOOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings7), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): MINIMAP SIZE and MINIMAP ZOOM, in DISPLAY. The defaults are the
  // minimap as it was: 216 pixels at 1080p showing 1000 world units across. SIZE scales the plate (the HUD panels under it move down to make room);
  // ZOOM is how many world units the plate shows across, close (700) for a tight street, wide (1400) for the lie of the land.
  {k:'mmSize', label:'MINIMAP SIZE', sec:'DISPLAY',
   hint:'HOW BIG THE MINIMAP IS, TOP RIGHT. THE PANELS UNDER IT MOVE DOWN.',
   opts:[
     {n:'SMALL',    cfg:{mmSz:0.75}},
     {n:'STANDARD', cfg:{mmSz:1}},
     {n:'LARGE',    cfg:{mmSz:1.35}}
   ], def:1},
  {k:'mmZoom', label:'MINIMAP ZOOM', sec:'DISPLAY',
   hint:'HOW MUCH STREET IT SHOWS. CLOSE IS A TIGHT VIEW, WIDE IS THE LIE OF THE LAND.',
   opts:[
     {n:'CLOSE',    cfg:{mmSpan:700}},
     {n:'STANDARD', cfg:{mmSpan:1000}},
     {n:'WIDE',     cfg:{mmSpan:1400}}
   ], def:1},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
function mmRect(){
'@ @'
// v26.xx (settings7): the two rows. mmSizeK is the factor on the plate, mmSpan the world units it shows across; an unset or odd value is the usual.
function mmSizeK(){ var s=+CFG.mmSz; return (s>=0.5&&s<=2)?s:1; }
function mmSpan(){ var s=+CFG.mmSpan; return (s>=400&&s<=2500)?s:MMSPAN; }
function mmRect(){
'@

SubRx @'
var R=hudRes(), s=Math.round(216*R), T=G&&G.tel, top;
'@ @'
var R=hudRes(), s=Math.round(216*R*mmSizeK()), T=G&&G.tel, top;   // v26.xx (settings7): MINIMAP SIZE
'@

SubRx @'
r=mmRect(); R=hudRes(); sc=r.w/MMSPAN; cut=Math.round(10*R);
'@ @'
r=mmRect(); R=hudRes(); sc=r.w/mmSpan(); cut=Math.round(10*R);   // v26.xx (settings7): MINIMAP ZOOM
'@

SubRx @'
x0=p.x-MMSPAN/2; y0=p.y-MMSPAN/2;
'@ @'
x0=p.x-mmSpan()/2; y0=p.y-mmSpan()/2;
'@

SubRx @'
ax=Math.max(0,x0); ay=Math.max(0,y0); bx=Math.min(WORLD_W,x0+MMSPAN); by=Math.min(WORLD_H,y0+MMSPAN);
'@ @'
ax=Math.max(0,x0); ay=Math.max(0,y0); bx=Math.min(WORLD_W,x0+mmSpan()); by=Math.min(WORLD_H,y0+mmSpan());
'@

SubRx @'
var VER='26.47';
'@ @'
var VER='26.48';
'@

$pat = "(?m)^  now:'v26\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.48: Display has minimap size and zoom. Check 26.48 fails on v26.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
