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

if ($s.Contains("  {v:'31.43',what:")) { throw "check 31.43 is in the fixture already" }

SubRx @'
  {v:'31.42',what:
'@ @'
  {v:'31.43',what:'the party cards (how to play, board, run over) are 97 percent panel and the run over title is tx-1 with a tx-2 second line, not lime (critic 52 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade here';
     var d, wasDisp, pg, ov, h1, h2, probe, t1, t2, got, a, m, res=null;
     function alpha(c){ m=/\/\s*([\d.]+)\s*\)\s*$/.exec(c)||/,\s*([\d.]+)\s*\)\s*$/.exec(c); return m?parseFloat(m[1]):1; }
     function col(v){ probe=document.createElement('i'); probe.style.color=v; document.body.appendChild(probe); var r=getComputedStyle(probe).color; probe.remove(); return r; }
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       pg=arcadeAttEl('arcpage'); pg.style.display='block';
       ov=arcadeAttEl('arcover'); ov.textContent=''; ov.style.display='block';
       h1=document.createElement('div'); h1.className='aoh'; h1.textContent='run over'; ov.appendChild(h1);
       h2=document.createElement('div'); h2.className='aoh'; h2.textContent='ended early -50%'; ov.appendChild(h2);
       a=alpha(getComputedStyle(pg).backgroundColor);
       if(a<0.95) return 'the board and how to play card fill is '+a+' opaque, under 0.95';
       a=alpha(getComputedStyle(ov).backgroundColor);
       if(a<0.95) return 'the run over card fill is '+a+' opaque, under 0.95';
       t1=getComputedStyle(h1).color; if(t1!==col('var(--tx-1)')) return 'the run over title is '+t1+', not tx-1';
       t2=getComputedStyle(h2).color; if(t2===col('var(--acc)')) return 'the run over second line is still the lime accent';
       return res;
     } finally {
       try{ ov.textContent=''; ov.style.display='none'; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
       __topClear();
     } }},
  {v:'31.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
