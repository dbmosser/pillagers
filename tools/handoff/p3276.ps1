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

# PAD RECONNECT ACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padLostStart(ix){
'@ @'
// v28.xx (cw-cx-o07-reconnect): J8 and the disconnect critic: the existing action says reconnect while its pad is absent.
function padLostUi(on,ready){
  if(!on&&!PAD.lossUi) return;
  var b=document.getElementById('resumebtn'); if(!b) return;
  if(on){
    if(!PAD.lossUi) PAD.lossUi={text:b.textContent,disabled:b.disabled};
    b.textContent=ready?'resume':'reconnect'; b.disabled=!ready;
  }else{
    var kept=PAD.lossUi; PAD.lossUi=null;
    if(kept){ b.textContent=kept.text; b.disabled=kept.disabled; }
  }
}
function padLostStart(ix){
'@

SubRx @'
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent='pad lost';
'@ @'
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent='pad lost';
  padLostUi(true,false);
'@

SubRx @'
  if(!live||PAD.lossRaid!==G){ PAD.lost=null; lost=null; PAD.lossRaid=live?G:null; PAD.lossIx=-1; }
'@ @'
  if(!live||PAD.lossRaid!==G){ padLostUi(false,false); PAD.lost=null; lost=null; PAD.lossRaid=live?G:null; PAD.lossIx=-1; }
'@

SubRx @'
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent=ready?'press a':'pad lost';
'@ @'
  var h=document.querySelector('#pausebox h3'); if(h) h.textContent=ready?'press a':'pad lost';
  padLostUi(true,ready);
'@

SubRx @'
    indevPadTick(gp); padBodyCls(); togglePauseBox(false);
'@ @'
    padLostUi(false,false); indevPadTick(gp); padBodyCls(); togglePauseBox(false);
'@

SubRx @'
document.getElementById('resumebtn').onclick=function(){
'@ @'
document.getElementById('resumebtn').onclick=function(){
  // v28.xx (cw-cx-o07-reconnect): one existing resume action, available only after the reserved pad returns.
  if(PAD.lost){ if(!PAD.lost.ready) return; PAD.lost=null; padLostUi(false,false); }
'@

SubRx @'
var VER='32.75';
'@ @'
var VER='32.76';
'@

$pat = "(?m)^  now:'v32\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.76: The existing action says reconnect and stays disabled until the reserved pad returns. A resumes as before and restores the normal pause action. The returned pad also permits a click on that same action. Check 32.76 fails on v32.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
