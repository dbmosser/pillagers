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

if ($s.Contains("  {v:'28.23',what:")) { throw "check 28.23 is in the fixture already" }

SubRx @'
  {v:'28.22',what:
'@ @'
  {v:'28.23',what:'the leaderboard column heads sit over their columns: each head shares its edge (left for rank, outcome and sector, right for score, time and date) with the figures under it',
   run:function(){
     if(typeof careerBoardView!=='function') return 'the CAREER board is not in this build';
     var bad=[], host=document.createElement('div'), b0=P.careerBoard, hb=('careerBoard' in P), r0=P.careerRuns, hr=('careerRuns' in P), a0=P.careerAll, ha=('careerAll' in P), hd, r1, i, a, c, e, rt=[0,1,0,0,1,1], nm=['RANK','SCORE','OUTCOME','SECTOR','TIME','DATE'];
     try{
       P.careerBoard=[{s:9800,k:3,m:0,t:Date.now()-86400000,n:'X',o:'x',d:300},{s:80,k:1,m:1,t:Date.now(),n:'X',o:'k',d:95}]; P.careerRuns=2; P.careerAll=[9800,80];
       host.style.cssText='position:fixed;left:0;top:0;width:760px;visibility:hidden;pointer-events:none;z-index:-1';
       document.body.appendChild(host);
       careerBoardView(host,{});
       hd=host.querySelector('.lbh'); r1=host.querySelectorAll('.apr')[1];
       if(!hd||!r1||hd.children.length!==6||r1.children.length!==6) return 'the board has no head row and a figures row';
       for(i=0;i<6;i++){
         a=hd.children[i].getBoundingClientRect(); c=r1.children[i].getBoundingClientRect();
         e=rt[i]?Math.abs(a.right-c.right):Math.abs(a.left-c.left);
         if(!(e<=1.5)) bad.push(nm[i]+' head is '+Math.round(e)+'px off its column ('+(rt[i]?'right':'left')+' edge)');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ document.body.removeChild(host); }catch(_h){}
       try{ if(hb) P.careerBoard=b0; else delete P.careerBoard; if(hr) P.careerRuns=r0; else delete P.careerRuns; if(ha) P.careerAll=a0; else delete P.careerAll; }catch(_b){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
