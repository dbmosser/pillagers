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

if ($s.Contains("  {v:'35.01',what:")) { throw "check 35.01 is in the fixture already" }

SubRx @'
  {v:'35.00',what:
'@ @'
  {v:'35.01',what:'cw-walletonce, his note (text collisions on the menu thing): the page text in the top right corner stays hidden while the canvas rows are drawn, even when the loop is driven with a frame time ahead of the real clock (the camera staging), so the cash figure is named once',
   run:function(){
     if(typeof trHide!=='function'||typeof TRG!=='object') return 'SKIP: no corner hide here';
     var cl=document.body.classList, had=cl.contains('trcol'), h0=TRG.hid, t0=TRG.t, bad=null;
     try{
       cl.remove('trcol'); TRG.hid=0; TRG.t=performance.now();
       trHide(performance.now()+5000);
       if(!cl.contains('trcol')) bad='the page text came back over the canvas rows when the loop ran 5 s ahead of the real clock';
     } finally { TRG.hid=h0; TRG.t=t0; if(had) cl.add('trcol'); else cl.remove('trcol'); }
     return bad; }},
  {v:'35.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
