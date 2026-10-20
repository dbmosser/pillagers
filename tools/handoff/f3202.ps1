$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'32.02',what:")) { throw "check 32.02 is in the fixture already" }

SubRx @'
  {v:'32.01',what:
'@ @'
  {v:'32.02',what:'the codex tiles fill the card: 150px tall tiles, 24px names, 96px art',
   run:function(){
     var bad=[];
     try{
       codexOpen();
       var t=document.querySelector('#codexmodal .cxt'), n=t&&t.querySelector('.cxn'), i=t&&t.querySelector('.cxi');
       if(!t) bad.push('no tile'); else {
         if(t.offsetHeight<149) bad.push('tile is '+t.offsetHeight+'px tall');
         if(parseFloat(getComputedStyle(n).fontSize)<23.5) bad.push('name is '+getComputedStyle(n).fontSize);
         if(i.offsetWidth<96) bad.push('art box is '+i.offsetWidth+'px wide'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
