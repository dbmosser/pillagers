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

# THE RESTORE CODE WAS BLANK FOR ANY NAME ABOVE U+00FF. btoa takes Latin-1
# only; a name with an emoji, a CJK character or a curly quote made it throw,
# the catch returned '', and the run report carried an empty restore code for
# exactly the friend most likely to have typed one. The name box accepts any
# sixteen characters. The code is UTF-8 now; the reader tries the UTF-8 read
# first and falls back to the old plain read, so every code written before
# this build still reads.
SubRx @'
  try{ return 'PIL1'+btoa(JSON.stringify(restoreMake())).replace(/=+$/,''); }
  catch(e){ return ''; }
'@ @'
  // v11.67: UTF-8 through btoa, so a name above U+00FF makes a code at all.
  try{ return 'PIL1'+btoa(unescape(encodeURIComponent(JSON.stringify(restoreMake())))).replace(/=+$/,''); }
  catch(e){ return ''; }
'@
SubRx @'
    while(b.length%4) b+='=';
    var o=JSON.parse(atob(b));
'@ @'
    while(b.length%4) b+='=';
    var raw=atob(b), js;
    // v11.67: the code is UTF-8 from this build on; an older one is plain
    // Latin-1 and reads as itself when the UTF-8 read refuses it.
    try{ js=decodeURIComponent(escape(raw)); }catch(_u){ js=raw; }
    var o=JSON.parse(js);
'@

# STAMPS.
SubRx @'
var VER='11.66';
'@ @'
var VER='11.67';
'@
SubRx @'
var WHATSNEW_VER='11.66';
'@ @'
var WHATSNEW_VER='11.67';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A NAME WITH AN EMOJI OR A CURLY QUOTE GETS A RESTORE CODE. Before this the code at the bottom of the run report came out blank for any such name, and the friend it belonged to could not be restored. Old codes still read.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.66:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.66 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.66:[^']*'",{ param($m) "now:'v11.67: the restore code was blank for any name above U+00FF. btoa takes Latin-1 only, so an emoji, a CJK character or a curly quote in the name made it throw and the catch returned an empty code, while the name box accepts any sixteen characters. The code is UTF-8 through btoa now and the reader tries the UTF-8 read first and falls back to the plain read, so every code written before this build still reads. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
