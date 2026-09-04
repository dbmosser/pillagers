$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== I PUT THE HELPER INSIDE drawHUD. `var by=H-34` is a local of that
# ==== function, not file scope, so the helper became a local too. It WORKS,
# ==== because both call sites are inside drawHUD and a function declaration
# ==== hoists within its own scope, but nothing outside can see it, and the check
# ==== that asks whether the game has a dodge at all correctly reported that it
# ==== does not. A helper only its own function can reach is not a rule the rest
# ==== of the file can follow, so it moves to real file scope beside drawHUD.
SubRx @'
// v10.90, HIS NOTE: keep a world label out of the corner the HUD owns. Given a
// label centred at sx,sy with a half width and a height, and how far a second
// line hangs below it, this returns the y to draw at: unchanged when there is no
// overlap, and lifted just above the corner box when there is. It LIFTS rather
// than hides, because a marker you cannot see is a worse answer than one an inch
// higher, and it never pushes a label off the top of the screen.
function hudDodge(sx,sy,halfW,hgt,tail){
  var B=G&&G.cornerBox; if(!B) return sy;
  var l=sx-halfW, r=sx+halfW, t=sy-hgt, b=sy+(tail||0)+4;
  if(r<B.x||l>B.x+B.w||b<B.y||t>B.y+B.h) return sy;
  var lift=b-B.y+6;
  var out=sy-lift;
  return (out-hgt<4)?sy:out;
}
var by=H-34;
'@ @'
var by=H-34;
'@
SubRx @'
function drawHUD(){
'@ @'
// v10.90, HIS NOTE: keep a world label out of the corner the HUD owns. Given a
// label centred at sx,sy with a half width and a height, and how far a second
// line hangs below it, this returns the y to draw at: unchanged when there is no
// overlap, and lifted just above the corner box when there is. It LIFTS rather
// than hides, because a marker you cannot see is a worse answer than one an inch
// higher, and it never pushes a label off the top of the screen.
// AT FILE SCOPE ON PURPOSE. My first cut put it inside drawHUD, next to the
// local it reads, where it worked and was invisible to everything else.
function hudDodge(sx,sy,halfW,hgt,tail){
  var B=G&&G.cornerBox; if(!B) return sy;
  var l=sx-halfW, r=sx+halfW, t=sy-hgt, b=sy+(tail||0)+4;
  if(r<B.x||l>B.x+B.w||b<B.y||t>B.y+B.h) return sy;
  var lift=b-B.y+6;
  var out=sy-lift;
  return (out-hgt<4)?sy:out;
}
function drawHUD(){
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
