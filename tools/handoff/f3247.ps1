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

if ($s.Contains("  {v:'32.47',what:")) { throw "check 32.47 is in the fixture already" }

SubRx @'
  {v:'32.46',what:
'@ @'
  {v:'32.47',what:'rewards list fills the card, bar rows scaled up (1400 wide, 120px rows, 56px buttons)',
   run:function(){
     var bad=[];
     try{
       var rw=document.getElementById('opane_rew');
       if(getComputedStyle(rw).maxWidth!=='none') bad.push('rew maxw '+getComputedStyle(rw).maxWidth);
       var pl=document.querySelector('#barmodal .plist');
       if(getComputedStyle(pl).maxWidth!=='1400px') bad.push('bar plist maxw '+getComputedStyle(pl).maxWidth);
       renderBar();
       var rowEl=document.querySelector('#barlist .row');
       if(!rowEl||parseFloat(getComputedStyle(rowEl).minHeight)<120) bad.push('bar row minh');
       var bt=document.querySelector('#barlist [data-bz]');
       if(!bt||parseFloat(getComputedStyle(bt).minHeight)<56) bad.push('bar button minh');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
