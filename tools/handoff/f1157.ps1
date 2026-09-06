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

# v11.57 CHECK, inserted before the v11.56 entry.
SubRx @'
  {v:'11.56',what:'no storm strike point lands inside a building (his note of 2026-09-05); the storm still strikes',
'@ @'
  {v:'11.57',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',
   run:function(){
     if(typeof strikeLabel!=='function') return 'the strike warning ring says nothing; there is no label to read';
     if(typeof render2D!=='function') return 'SKIP: no world draw in this build';
     var bad=[];
     var a=String(strikeLabel({t:1.6})), b=String(strikeLabel({t:0.3}));
     if(a.indexOf('LIGHTNING INCOMING')<0) bad.push('at 1.6 s the label reads "'+a+'"');
     if(a.indexOf('2S')<0) bad.push('at 1.6 s the label does not round to 2S: "'+a+'"');
     if(b.indexOf('LIGHTNING INCOMING')<0||b.indexOf('1S')<0) bad.push('at 0.3 s the label reads "'+b+'" and not LIGHTNING INCOMING 1S');
     var src=''; try{ src=render2D.toString(); }catch(_s){}
     if(src.indexOf('strikeLabel(')<0) bad.push('control: the world draw does not read strikeLabel, so the words are never at the circle');
     return bad.length?bad.join('; '):null; }},
  {v:'11.56',what:'no storm strike point lands inside a building (his note of 2026-09-05); the storm still strikes',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
