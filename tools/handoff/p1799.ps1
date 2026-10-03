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

# A SETTINGS CHANGE KEEPS ITS PLACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function renderSettings(){
  var host=document.getElementById('setlist');
'@ @'
// v17.99, HIS REPORT (2026-10-03): A SETTINGS CHANGE THREW HIM BACK TO THE TOP. Every row click rebuilds the list, and the rebuild
// lost the scroll and the focused control, so a controller walking down the page went back to the first row after each change.
// The scroll of the list and of anything above it, the focused button and the pad highlight are kept across the rebuild, by id.
function setKeep(host){
  var sc=[], e=host, a=document.activeElement, pf=(typeof PAD==='object'&&PAD&&PAD.focus)?PAD.focus:null;
  while(e&&e!==document.body){ if(e.scrollTop>0) sc.push([e,e.scrollTop]); e=e.parentNode; }
  return {sc:sc,id:(a&&a.id)||'',pf:(pf&&pf.id)||''};
}
function setRestore(k){
  var i, f;
  if(!k) return;
  for(i=0;i<k.sc.length;i++){ try{ k.sc[i][0].scrollTop=k.sc[i][1]; }catch(_s){} }
  if(k.id){ f=document.getElementById(k.id); if(f&&f.focus){ try{ f.focus({preventScroll:true}); }catch(_f){ try{ f.focus(); }catch(_f2){} } } }
  if(k.pf){ f=document.getElementById(k.pf); if(f&&typeof padSetFocus==='function'&&(!PAD.focus||!PAD.focus.isConnected)){ try{ padSetFocus(f); }catch(_p){} } }
  for(i=0;i<k.sc.length;i++){ try{ k.sc[i][0].scrollTop=k.sc[i][1]; }catch(_s2){} }
}
function renderSettings(){
  var host=document.getElementById('setlist'), _keep=setKeep(host);
  try{ renderSettingsInner(host); }finally{ setRestore(_keep); }
}
function renderSettingsInner(host){
'@

SubRx @'
var VER='17.98';
'@ @'
var VER='17.99';
'@

$pat = "(?m)^  now:'v17\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.99: Changing a setting no longer throws you back to the top of the menu. Check 17.99 fails on v17.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
