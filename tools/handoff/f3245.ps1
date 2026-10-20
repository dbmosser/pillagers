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

if ($s.Contains("  {v:'32.45',what:")) { throw "check 32.45 is in the fixture already" }

SubRx @'
  {v:'32.44',what:
'@ @'
  {v:'32.45',what:'rewards intro hidden and bar 28px, bar flavour and wallet lines hidden, ingest ghost when idle',
   run:function(){
     var bad=[];
     try{
       var rw=document.getElementById('opane_rew'), m=rw.querySelector(':scope > .msub:not(#roadmaphead)');
       if(m&&getComputedStyle(m).display!=='none') bad.push('rewards intro shows');
       if(getComputedStyle(document.getElementById('seasonbar')).height!=='28px') bad.push('bar h '+getComputedStyle(document.getElementById('seasonbar')).height);
       if(getComputedStyle(rw).maxWidth!=='1400px') bad.push('rew maxw '+getComputedStyle(rw).maxWidth);
       if(getComputedStyle(document.getElementById('bar_line')).display!=='none') bad.push('bar_line shows');
       if(getComputedStyle(document.getElementById('wallet_bar')).display!=='none') bad.push('wallet_bar shows');
       renderBar();
       var bt=document.querySelector('#barlist [data-bz]');
       if(bt&&!bt.disabled){ var bg=getComputedStyle(bt).backgroundColor; if(bg!=='rgba(0, 0, 0, 0)') bad.push('ingest filled '+bg); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
