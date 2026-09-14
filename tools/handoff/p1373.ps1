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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 3: THE STALL STAYED OPEN AND WORKING WHILE
# YOU WERE DOWN. The one line that shuts the stall when you go down sits on the standing path of
# updatePlayer, below the downed return, and going down cleared the prep, the heal, the pull and
# the cook but not the stall. The panel stayed over the DOWN screen for the whole bleed-out:
# the number keys still bought with banked Credits, saved at once, into a backpack about to
# die; 1 sold the backpack into stall money lost on death; and on a pad A bought the marked
# row. Going down now shuts the stall, and neither verb trades from the floor.
SubRx @'
    // hits still do not; being SHOT TO THE FLOOR is not an ordinary hit.
    p.healQ=0; p.healRate=0; p.healCap=undefined;
'@ @'
    // hits still do not; being SHOT TO THE FLOOR is not an ordinary hit.
    p.healQ=0; p.healRate=0; p.healCap=undefined;
    // v13.73, downed audit: and the stall shuts. Its only closer is on the standing path, so
    // it stayed open and trading over the DOWN screen for the whole bleed-out.
    if(G.trade){ G.trade=null; G.pedLock=1; }
'@
SubRx @'
function pedBuy(ix){
  if(!G||!G.trade) return;
'@ @'
function pedBuy(ix){
  if(!G||!G.trade) return;
  if(!G.sim&&G.player&&G.player.downed) return;   // v13.73: nothing is traded from the floor
'@
SubRx @'
  if(!G||(!G.trade&&!G.sim)) return;
'@ @'
  if(!G||(!G.trade&&!G.sim)) return;
  if(!G.sim&&G.player&&G.player.downed) return;   // v13.73: nothing is traded from the floor
'@
SubRx @'
var VER='13.72';
'@ @'
var VER='13.73';
'@

$pat = "(?m)^  now:'v13\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.73: GOING DOWN SHUTS THE STALL. Downed and extraction audit of 2026-09-14, finding 3: the only line that closes the stall when you go down is on the standing path below the downed return, so the stall stayed open over the DOWN screen, the number keys bought with banked Credits into a backpack about to die, and 1 sold the backpack into stall money lost on death. damagePlayer now shuts the stall as it clears the heal, and pedBuy and pedSellAll refuse from the floor. Check 13.73 downs the player with the stall open and requires it shut and a buy refused with the Credits kept, with the same buy standing as the control; it fails on v13.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
