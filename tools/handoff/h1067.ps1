$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== THE HARNESS POISONED ITSELF, TWICE, AND IT COST ME TWO FULL CORPUS RUNS.
# ==== Run one failed v9.25 and v10.50; run two of the same corpus on the same
# ==== build failed neither and failed v8.72 instead. Both runs green when the
# ==== named check is run on its own.
# ====
# ==== CAUSE ONE, measured: six checks end a raid and none of them closes the
# ==== extraction card afterwards, and showScreen cannot clear it because it is
# ==== not a modal. v8.72 drags an item off the belt, and with the card up the
# ==== release lands on the card, so the item stays put and the check reports
# ==== his old symptom. Proved by hand: v8.72 failed four times running with the
# ==== card up and passed the moment the card was closed, nothing else touched.
# ==== This is the v9.82 lesson in a second place.
# ====
# ==== CAUSE TWO: neither runner pinned the ruler or cleaned the saved profile
# ==== before it started, so the corpus inherited whatever the previous work in
# ==== that tab had left in the profile. Run one inherited a deployed raid and
# ==== the cosmetics from a hand probe, which is what "the fullbeard paints
# ==== nothing" was reading.
SubRx @'
window.__regress=function(){
  var res={pass:true,checked:0,fail:[],skipped:[]};
  for(var i=0;i<__REGRESS.length;i++){
    var t=__REGRESS[i], r=null;
    res.checked++;
'@ @'
// v10.67: the extraction card is not a modal, so showScreen cannot clear it and
// six checks that end a raid leave it lying on top of the page. Any later check
// that aims at the DOM then hits the card instead of what it meant to hit, which
// is how the same corpus on the same build failed three different checks across
// two runs. Nothing depends on the card being open at entry: the only two checks
// that read it open it themselves. So every check starts with it shut.
window.__topClear=function(){
  var oc=document.getElementById('outcome'), n=0;
  if(oc&&oc.classList.contains('on')){ oc.classList.remove('on'); n++; }
  return n;
};
// And the ruler is pinned and the saved profile cleaned before the corpus runs,
// rather than inheriting whatever the last hand probe in this tab left behind.
window.__runPrep=function(){
  try{ if(window.__pinDPR) __pinDPR(1); }catch(e){}
  try{ if(window.__cleanProfile) __cleanProfile(); }catch(e){}
};
window.__regress=function(){
  var res={pass:true,checked:0,fail:[],skipped:[],cleared:0};
  __runPrep();
  for(var i=0;i<__REGRESS.length;i++){
    var t=__REGRESS[i], r=null;
    res.cleared+=__topClear();
    res.checked++;
'@

SubRx @'
window.__regressBg=function(){
  var res={pass:true,checked:0,fail:[],skipped:[]}, i=0;
  window.__PROG={done:0,total:__REGRESS.length,cur:'',finished:false,res:null};
'@ @'
window.__regressBg=function(){
  var res={pass:true,checked:0,fail:[],skipped:[],cleared:0}, i=0;
  __runPrep();
  window.__PROG={done:0,total:__REGRESS.length,cur:'',finished:false,res:null};
'@

SubRx @'
    var t=__REGRESS[i], r=null;
    __PROG.cur='v'+t.v; res.checked++;
'@ @'
    var t=__REGRESS[i], r=null;
    res.cleared+=__topClear();
    __PROG.cur='v'+t.v; res.checked++;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
