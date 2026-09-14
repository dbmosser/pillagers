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

# IN-RAID AUDIT OF 2026-09-14, finding 3: SWITCHING TO THE GUN WHILE COOKING A GRENADE FIRED THE
# GUN AND FROZE THE FUSE. The cook timer only ran inside the throwable branch of the trigger,
# and the gun branch never looked at p.cooking. Cook a Frag, press 1 or a bumper, keep holding:
# the rifle fired with a live grenade in his hand, the fuse stopped counting, and letting go
# threw it with the time it had when he switched. G while cooking also threw a second grenade.
# While a grenade is cooking the fuse now burns whatever cell is selected, the gun does not
# fire, and a throw key waits for the grenade in hand.
SubRx @'
  var hotGun=(!HSC||HSC.kind==='gun'||HSC.kind==='item');
'@ @'
  // v13.62, in-raid audit: A COOKED GRENADE KEEPS BURNING WHATEVER IS SELECTED. The fuse
  // only ran in the throwable branch, so switching cells mid-cook stopped it dead.
  if(p.cooking&&mouse.down&&!(HSC&&HSC.kind==='throw')){
    p.cookT=(p.cookT||0)+dt;
    if(p.cookKind==='frag'&&p.cookT>=FRAG_FUSE) cookOff();
  }
  var hotGun=(!HSC||HSC.kind==='gun'||HSC.kind==='item');
'@
SubRx @'
  else if(mouse.down&&!p.trigYield&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){
'@ @'
  else if(mouse.down&&!p.trigYield&&!p.cooking&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){   // v13.62: no shot with a live grenade in hand
'@
SubRx @'
  var tk=THROWKEYS[G.tsel];
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return; }
  G.pouch[tk]--; G.tel.thr[tk]++;
  throwFrom(tk,0);
'@ @'
  if(p.cooking){ if(!G.sim) say('Throw the one in your hand first.'); return; }   // v13.62: one grenade at a time
  var tk=THROWKEYS[G.tsel];
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return; }
  G.pouch[tk]--; G.tel.thr[tk]++;
  throwFrom(tk,0);
'@
SubRx @'
var VER='13.61';
'@ @'
var VER='13.62';
'@

$pat = "(?m)^  now:'v13\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.62: A COOKED GRENADE OWNS THE HAND UNTIL IT IS THROWN. In-raid audit of 2026-09-14, finding 3: the cook timer only ran in the throwable branch of the trigger and the gun branch never checked p.cooking, so switching to the gun mid-cook fired the gun with a live grenade in hand and froze the fuse, and G while cooking threw a second grenade. The fuse now burns whatever cell is selected, the gun does not fire while a grenade is cooking, and a throw key says to throw the one in hand first. Check 13.62 cooks a Frag, switches to an automatic gun and holds the trigger, and requires no shot and the fuse still counting, and G to throw nothing extra, with the gun firing normally as the control; it fails on v13.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
