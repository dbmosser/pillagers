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

if ($s.Contains("  {v:'18.81',what:")) { throw "check 18.81 is in the fixture already" }

SubRx @'
  {v:'18.80',what:
'@ @'
  {v:'18.81',what:'the FASHION racks fill their panel: the racks list reaches the bottom of the window grid and scrolls on its own, and the grid itself does not scroll',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, pk, gr, R, G2;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mirror','KeyE');
       pk=document.getElementById('appavatarpicker'); gr=pk&&pk.closest('.hubgrid');
       if(!pk||!gr||!document.getElementById('appearmodal').classList.contains('on')) return 'SKIP: FASHION did not open';
       R=pk.getBoundingClientRect(); G2=gr.getBoundingClientRect();
       if(R.bottom<G2.bottom-40) bad.push('the racks stop at '+Math.round(R.bottom)+', short of the grid bottom '+Math.round(G2.bottom));
       if(gr.scrollHeight>gr.clientHeight+4) bad.push('the whole grid scrolls ('+gr.scrollHeight+' in '+gr.clientHeight+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
