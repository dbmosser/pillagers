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

# KID MODE SET IN ONE WINDOW SHOWS IN THE OTHER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function kbCycle(){ P.kidBack=kbOwn()?0:1; saveProfile(); return P.kidBack; }
'@ @'
function kbCycle(){ P.kidBack=kbOwn()?0:1; saveProfile(); kidShare(); return P.kidBack; }
// v18.00, HIS ORDER (2026-10-03): KID MODE SET IN ONE WINDOW SHOWS IN THE OTHER. The three kid rows lived on each window's own
// save, so a change made in player 1's Settings never showed in player 2's. The two windows share this browser's storage, so a
// change is written there with a time stamp as well; the other window takes it on the spot (the storage event), or when its
// Settings next open, and never lets an older stamp undo a newer one. The host still carries the live values into the raid.
var KID_SHARE_KEY='salvagerun:kid';
function kidShare(){
  var at=Date.now();
  P.kidAt=at;
  try{ localStorage.setItem(KID_SHARE_KEY,JSON.stringify({kd:kidMulOwn(),af:afOwn()?1:0,kb:kbOwn()?1:0,at:at})); }catch(_ks){}
}
function kidSync(raw){
  var o=null;
  try{ o=JSON.parse(raw!==undefined&&raw!==null?raw:localStorage.getItem(KID_SHARE_KEY)); }catch(_kp){ o=null; }
  if(!o||typeof o.at!=='number'||!(o.at>(P.kidAt||0))) return false;
  if(typeof o.kd==='number'&&isFinite(o.kd)&&o.kd>=KID_MIN&&o.kd<=1) P.kidDmg=o.kd;
  P.p2Auto=o.af?1:0; P.kidBack=o.kb?1:0; P.kidAt=o.at;
  try{ saveProfile(); }catch(_kv){}
  return true;
}
try{ window.addEventListener('storage',function(ev){ if(!ev||ev.key!==KID_SHARE_KEY||!kidSync(ev.newValue)) return; try{ var _sm=document.getElementById('settingsmodal'); if(_sm&&_sm.classList.contains('on')) renderSettings(); }catch(_kr){} }); }catch(_kse){}
'@

SubRx @'
function afCycle(){ P.p2Auto=afOwn()?0:1; saveProfile(); return P.p2Auto; }
'@ @'
function afCycle(){ P.p2Auto=afOwn()?0:1; saveProfile(); kidShare(); return P.p2Auto; }   // v18.00: shared with the other window
'@

SubRx @'
  P.kidDmg=KID_OPTS[(ix+1)%KID_OPTS.length][0];
  saveProfile();
  return P.kidDmg;
'@ @'
  P.kidDmg=KID_OPTS[(ix+1)%KID_OPTS.length][0];
  saveProfile(); kidShare();   // v18.00: shared with the other window
  return P.kidDmg;
'@

SubRx @'
  var host=document.getElementById('setlist'), _keep=setKeep(host);
'@ @'
  var host=document.getElementById('setlist'), _keep=setKeep(host);
  try{ kidSync(); }catch(_kq){}   // v18.00: the kid rows as the other window last set them
'@

SubRx @'
var VER='17.99';
'@ @'
var VER='18.00';
'@

$pat = "(?m)^  now:'v17\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.00: Kid mode rows changed in one window now show, and apply, in the other window too. Check 18.00 fails on v17.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
