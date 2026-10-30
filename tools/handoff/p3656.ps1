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

# ONLINE PARTY CODE MANUAL COPY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(g('partycode').value!==code) g('partycode').value=code;
'@ @'
  if(g('partycode').value!==code) g('partycode').value=code;
  // v28.xx (cw-cx-onlinecopy): itch can block both clipboard paths; keep the manual copy label for this code.
  g('partycopy').textContent=(code&&NET.copyHand===code)?'copy by hand':'copy code';
'@

SubRx @'
function netCopy(){
  var t=document.getElementById('partycode');
  if(!t||!t.value) return;
  var done=function(ok){ NET.status=ok?'Copied. Paste it to your friend.':'Select the code and copy it by hand.'; renderParty(); };
  try{ if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(t.value).then(function(){ done(true); },function(){ netCopyOld(t,done); }); return; } }catch(e){}
  netCopyOld(t,done);
}
function netCopyOld(t,done){
  var ok=false;
  try{ t.select(); ok=document.execCommand('copy'); t.blur(); }catch(e){ ok=false; }
  done(ok);
}
'@ @'
function netCopy(){
  var t=document.getElementById('partycode');
  if(!t||!t.value) return;
  // v28.xx (cw-cx-onlinecopy), his 10-30 order: the guest must be able to copy a reply inside the itch frame.
  var code=t.value, done=function(ok){
    if(t.value!==code) return;
    NET.copyHand=ok?'':code;
    NET.status=ok?'code copied':'copy by hand';
    renderParty();
    if(!ok){ try{ t.focus(); t.select(); }catch(_cf){} }
  };
  try{ if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(code).then(function(){ done(true); },function(){ if(t.value===code) netCopyOld(t,done); }); return; } }catch(e){}
  netCopyOld(t,done);
}
function netCopyOld(t,done){
  var ok=false;
  try{ t.focus(); t.select(); ok=document.execCommand('copy'); if(ok) t.blur(); }catch(e){ ok=false; }
  done(ok);
}
'@

SubRx @'
var VER='36.55';
'@ @'
var VER='36.56';
'@

$pat = "(?m)^  now:'v36\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.56: A blocked copy keeps the exact code selected and focused. The button says copy by hand until that code copies successfully. Check 36.56 fails on v36.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
