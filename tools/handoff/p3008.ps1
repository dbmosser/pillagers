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

# THE WHAT IS NEW CARD SHOWS THE POLISH LINE ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wnShort(s){

'@ @'
// v28.xx (cw-wnded), critic on screen 40 (What's New): "4 of 5 notes are the same Polish pass sentence". The card shows the newest generic
// polish line once and every other note once; the list itself is untouched (old checks read it by index).
function wnList(){
  var o=[], i, t, seen=0;
  for(i=0;i<WHATSNEW.length;i++){
    t=String(WHATSNEW[i]);
    if(/^POLISH PASS \d+\. MORE FIXES TO THE SCREENS/i.test(t)){ if(seen) continue; seen=1; }
    o.push(WHATSNEW[i]);
  }
  return o;
}
function wnShort(s){

'@

SubRx @'
      for(var wm=0;wm<Math.min(WN_SHOW,WHATSNEW.length);wm++){
        var wWords=TX((wm+1)+'. '+wnShort(WHATSNEW[wm])).split(' '),wLine='',wFirst=1;
'@ @'
      var wnL=wnList();   /* v28.xx (cw-wnded): the generic polish line once */
      for(var wm=0;wm<Math.min(WN_SHOW,wnL.length);wm++){
        var wWords=TX((wm+1)+'. '+wnShort(wnL[wm])).split(' '),wLine='',wFirst=1;
'@

SubRx @'
  n=Math.min(8,WHATSNEW.length);
  for(i=0;i<n;i++){ d=document.createElement('div'); d.style.cssText='margin:0 0 .7em'; d.textContent=TX((i+1)+'. '+wnShort(WHATSNEW[i])); L.appendChild(d); }
'@ @'
  var wnL2=wnList();   /* v28.xx (cw-wnded): the generic polish line once */
  n=Math.min(8,wnL2.length);
  for(i=0;i<n;i++){ d=document.createElement('div'); d.style.cssText='margin:0 0 .7em'; d.textContent=TX((i+1)+'. '+wnShort(wnL2[i])); L.appendChild(d); }
'@

SubRx @'
var VER='30.07';
'@ @'
var VER='30.08';
'@

$pat = "(?m)^  now:'v30\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.08: The What is New card no longer repeats the polish pass line. Check 30.08 fails on v30.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
