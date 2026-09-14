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

SubRx @'
  {v:'14.93',what:
'@ @'
  {v:'14.94',what:'the what is new card is current again: its version is within fifteen builds of the build and it names the belt key news of v14.84, still opening with the alpha line',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[];
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0;
     var vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';
     if(vNow-vCard>0.15) bad.push('the card is at v'+wn.ver+' against a build at v'+wn.build+', more than fifteen builds behind');
     var all=L.join(' ').toUpperCase();
     var NEWS=['a heal on a key','no longer stops medical'].join(' ').toUpperCase();
     if(all.indexOf(NEWS)<0) bad.push('the card does not mention the belt key news of v14.84');
     if(L[0]&&String(L[0]).toUpperCase().indexOf('ALPHA')<0) bad.push('the card no longer opens with what an alpha is');
     return bad.length?bad.join('; '):null; }},
  {v:'14.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
