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

# RAID HUD CORNERS GO QUIET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function extBanFont(t){
'@ @'
// v28.xx (cw-hudquiet), the critic on screens 21, 19, 37, 61 ('the corners compete with the ammo hero'): the quiet lines on the gun card (the item count and the backpack cue) are 16 px on screen at 1080p, the guide label size, not 20 and 24. 0.8 of the micro face, so the player's text scale still applies.
function hudFineFS(){ return FS(TYPE.micro).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*0.8).toFixed(1)+'px'; }); }
function extBanFont(t){
'@

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1';
  // A cost you cannot see
'@ @'
  ctx.font=hudFineFS(); ctx.fillStyle='#8a96a1';   // v28.xx (cw-hudquiet): the item count is a quiet 16 px line
  // A cost you cannot see
'@

SubRx @'
ctx.font=FS(TYPE.label); ctx.fillStyle='#aaa498';   // v28.xx (cw-hudhero)
'@ @'
ctx.font=hudFineFS(); ctx.fillStyle='#aaa498';   // v28.xx (cw-hudquiet): the backpack cue is the same quiet 16 px as the item count. v28.xx (cw-hudhero)
'@

SubRx @'
  ctx.font=FS(TYPE.micro);
  ctx.fillStyle='#ffc04a';
  ctx.fillText('CURRENT PILLAGER BOTS  '+live,PADX,y0-LH(2));
'@ @'
  ctx.font=FS(TYPE.micro);
  ctx.fillStyle=HUDC.text;   // v28.xx (cw-hudquiet), the critic: the board title was amber while the run info title is cream; one title colour, amber stays for focus and warnings
  ctx.fillText('CURRENT PILLAGER BOTS  '+live,PADX,y0-LH(2));
'@

SubRx @'
ctx.font=hudFS(TYPE.head);   // v19.22: grows with the screen, as the weapon panel under it does
'@ @'
ctx.font=hudFS(TYPE.label);   // v28.xx (cw-hudquiet), the critic: the hidden chip was louder (22 px amber) than the info plates; it is label size now. v19.22: grows with the screen, as the weapon panel under it does
'@

SubRx @'
cw2+16*_cr2,LH(20)*_cr2,0.78,1)
'@ @'
cw2+16*_cr2,LH(20)*_cr2,0.88,1)
'@

SubRx @'
var VER='34.25';
'@ @'
var VER='34.26';
'@

$pat = "(?m)^  now:'v34\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.26: The item count and backpack hint on the ammo card are smaller. The pillager board title is cream. The hidden chip is smaller. Check 34.26 fails on v34.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
