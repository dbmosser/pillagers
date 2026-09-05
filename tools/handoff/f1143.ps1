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

# v11.43 CHECK, before the v11.42 entry: the baked set is his LATEST (71), and the
# new title-screen lift line, added after the v11.42 snapshot, renders.
SubRx @'
  {v:'11.42',what:'his in-game text edits are baked in: TX rewrites his edited strings to his wording with the editor off, exact and number-pattern lines alike, and leaves unrelated text alone',
'@ @'
  {v:'11.43',what:'the baked text edits are his latest set (71), including the title-screen and tutorial lines he rewrote after the v11.42 snapshot',
   run:function(){
     if(!(window.__tx&&__tx.get&&__tx.ship)) return 'SKIP: this build cannot read the shipped text map';
     var bad=[], o=__tx.ship(), n=0, liftKey=null;
     for(var k in o){ n++; if(k.indexOf('Take the lift up with whatever you dare carry')>=0) liftKey=k; }
     if(n<71) bad.push('only '+n+' edits are baked, expected his latest set of 71');
     if(!liftKey) bad.push('the new title-screen lift line he rewrote is not in the baked set');
     else if(__tx.get(liftKey)!==o[liftKey]) bad.push('the new lift line does not render his wording through TX');
     return bad.length?bad.join('; '):null; }},
  {v:'11.42',what:'his in-game text edits are baked in: TX rewrites his edited strings to his wording with the editor off, exact and number-pattern lines alike, and leaves unrelated text alone',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
