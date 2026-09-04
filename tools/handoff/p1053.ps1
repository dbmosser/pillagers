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

# ============ HIS NOTE, 2026-09-03 about 19:40: "add something to the dev
# ============ cheat menu to unlock all cosmetics" and "make it toggleable so if
# ============ someone cuts it on they can cut it back off". One flag on the
# ============ profile, P.cosAll, read by cosOwned ahead of every earning rule.
# ============ The earned counters and the bought list are untouched, so cutting
# ============ it off returns exactly the racks he had earned; a worn piece he no
# ============ longer owns falls back the way cosWorn always has.

# 1. The button, under TAKE $100,000.
SubRx @'
  <button class="deploy ghost" id="cheat100k" style="margin:10px 0;padding:9px 18px;width:100%">TAKE $100,000</button>
'@ @'
  <button class="deploy ghost" id="cheat100k" style="margin:10px 0;padding:9px 18px;width:100%">TAKE $100,000</button>
  <button class="deploy ghost" id="cheatcos" style="margin:0 0 10px;padding:9px 18px;width:100%">ALL COSMETICS: OFF</button>
'@

# 2. The rule: with the flag on, every rack is owned.
SubRx @'
  if(typeof P==='undefined'||!P) return false;
  var bits=String(c.how).split(':'),k=bits[0],v=+bits[1];
'@ @'
  if(typeof P==='undefined'||!P) return false;
  if(P.cosAll) return true;   // v10.53, his note: the cheat box unlocks every rack, and can lock them again
  var bits=String(c.how).split(':'),k=bits[0],v=+bits[1];
'@

# 3. The wiring: a toggle that says which way it is.
SubRx @'
  var cb=document.getElementById('cheat100k');
'@ @'
  // v10.53, his note: every rack, on or off. The flag is the only thing that
  // changes; what he earned and bought stays as it was under it.
  var cc=document.getElementById('cheatcos');
  if(cc){
    cc.textContent='ALL COSMETICS: '+(P.cosAll?'ON':'OFF');
    cc.onclick=function(){
      P.cosAll=!P.cosAll; saveProfile(); renderHub();
      cc.textContent='ALL COSMETICS: '+(P.cosAll?'ON':'OFF');
      var _tk3=document.getElementById('cheattook');
      if(_tk3) _tk3.textContent=P.cosAll?'Every rack in the Depot is open. Cut it off here to keep only what you earned.':'The racks are back to what you earned.';
      say2(P.cosAll?'Every cosmetic unlocked. No judgment.':'Cosmetics back to what you earned.'); blip('pick');
    };
  }
  var cb=document.getElementById('cheat100k');
'@

SubRx @'
var VER='10.52';
'@ @'
var VER='10.53';
'@
SubRx @'
  now:'v10.52: the prompt over a crate and the "1 item left" count under the search bar are bigger. The count was the smallest type in the game, on the one line you read while deciding whether one more pull is worth the time.',
'@ @'
  now:'v10.53: the DEV CHEAT BOX has an ALL COSMETICS switch. On, every rack in the Depot is open; off, you are back to exactly what you earned and bought.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
