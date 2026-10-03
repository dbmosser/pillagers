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

# THE NEW-IN CARD IS A CARD, NOT A WALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.65';
'@ @'
var WHATSNEW_VER='17.65';
// v17.77, THE VISUAL PASS (2026-10-02): THE NEW-IN CARD IS A CARD, NOT A WALL. It drew every note in full, six paragraphs over the
// whole floor. It now shows the newest WN_SHOW notes, each as its headline sentence and the start of what follows. The notes
// themselves are unchanged.
var WN_SHOW=5, WN_TAIL=150;
function wnShort(s){
  var t=String(s||''), i=t.indexOf('. '), head, rest, cut;
  if(i<0||i>140) return (t.length>WN_TAIL+60)?(t.slice(0,WN_TAIL+60).replace(/\s+\S*$/,'')+'...'):t;
  head=t.slice(0,i+1); rest=t.slice(i+2);
  if(rest.length<=WN_TAIL) return head+' '+rest;
  cut=rest.slice(0,WN_TAIL).replace(/\s+\S*$/,'');
  return head+' '+cut+'...';
}
'@

SubRx @'
      for(var wm=0;wm<WHATSNEW.length;wm++){
        var wWords=((wm+1)+'. '+WHATSNEW[wm]).split(' '),wLine='',wFirst=1;
'@ @'
      for(var wm=0;wm<Math.min(WN_SHOW,WHATSNEW.length);wm++){
        var wWords=((wm+1)+'. '+wnShort(WHATSNEW[wm])).split(' '),wLine='',wFirst=1;
'@

SubRx @'
if the host leaves the party, the run ends as abandoned for everyone.
'@ @'
if the host window closes, player 2 keeps the raid and runs it alone.
'@

SubRx @'
var VER='17.76';
'@ @'
var VER='17.77';
'@

$pat = "(?m)^  now:'v17\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.77: The NEW IN card is shorter: the newest five notes, each as a headline and a line. Check 17.77 fails on v17.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
