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

if ($s.Contains("  {v:'29.94',what:")) { throw "check 29.94 is in the fixture already" }

SubRx @'
  {v:'29.93',what:
'@ @'
  {v:'29.94',what:'the run over card shows kills, extractions and deaths as cells (a 32px value over a 16px label, three in a row for one player, a row each for two) and hides the run-on text row, and the welcome pack never opens while the arcade is up (critic on v29.93: 55 = 3, and the pack showed through the backdrop; screens 52 55)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no arcade run over card here';
     if(typeof arcadeOverStats!=='function') return 'the run over card has no stat cells';
     var d, oc, wasDisp, z, res=null, was=ARCADE.solo, cells, labs, v, l, aor, m, wasOn, w0, r0, s0, wp0;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       oc=arcadeAttEl('arcover'); oc.textContent=''; oc.style.display='block';
       aor=document.createElement('div'); aor.className='aor'; aor.textContent='You 5 SP'; oc.appendChild(aor);
       ARCADE.solo=true; arcadeOverStats(oc,{p1:{s:1200,k:3,x:1,d:0},p2:null,team:1200});
       cells=oc.querySelectorAll('.aost .aosc');
       if(cells.length!==3) res='one player shows '+cells.length+' stat cells, not 3 (Kills, Extractions, Deaths)';
       else { labs=[].map.call(cells,function(c){ return c.querySelector('i').textContent; }).join(','); if(!/Kills,Extractions,Deaths/i.test(labs)) res='the cell labels are '+labs; }
       if(!res){
         v=getComputedStyle(cells[0].querySelector('b')).fontSize; l=getComputedStyle(cells[0].querySelector('i')).fontSize;
         if(Math.abs(parseFloat(v)-32*z)>0.5) res='a cell value is '+v+', not 32px x '+z;
         else if(Math.abs(parseFloat(l)-16*z)>0.5) res='a cell label is '+l+', not 16px x '+z;
         else if(getComputedStyle(aor).display!=='none') res='the run-on stats text is still showing';
       }
       if(res) return res;
       oc.querySelector('.aost').remove(); ARCADE.solo=false;
       arcadeOverStats(oc,{p1:{s:1200,k:3,x:1,d:0},p2:{s:800,k:2,x:0,d:1},team:2000});
       if(oc.querySelectorAll('.aost .aosr').length!==2) return 'two players show '+oc.querySelectorAll('.aost .aosr').length+' stat rows, not 2';
       m=document.getElementById('welcomemodal');
       if(m&&typeof firstRunNext==='function'&&typeof P==='object'&&P){
         wasOn=ARCADE.on; w0=P.welcomed; r0=P.runs; s0=P.stash; wp0=P.weapons;
         try{
           __topClear(); P.welcomed=0; P.runs=0; P.stash=[]; P.weapons=[];
           ARCADE.on=1; firstRunNext();
           if(m.classList.contains('on')) res='the welcome pack opened over the arcade';
         } finally { ARCADE.on=wasOn; P.welcomed=w0; P.runs=r0; P.stash=s0; P.weapons=wp0; try{ m.classList.remove('on'); }catch(_m){} }
       }
       return res;
     } finally {
       try{ ARCADE.solo=was; oc.textContent=''; oc.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
