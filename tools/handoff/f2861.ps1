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

if ($s.Contains("  {v:'28.61',what:")) { throw "check 28.61 is in the fixture already" }

SubRx @'
  {v:'28.60',what:
'@ @'
  {v:'28.61',what:'cloud-raid-p2reach: player 2 copies of the bodies have the host sight reach, so a searcher scan cone is as long in his window as on the host',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof searchCone!=='function'||typeof mkSentry!=='function'||typeof netEntNewWord!=='function'||typeof netEntWord!=='function'||typeof netEntsApply!=='function') return 'SKIP: no search cones or party in this fixture';
     var g=null, p=null, e=null, mm=null, NK={}, k, staged=false, oKeys=null, peer={state:'in',seat:0}, nw, row, bad=[];
     function link(L){ var w=L.map(netEntNewWord), r=L.map(netEntRow); g.ents=[]; for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.entMap={}; NET.entLast=0;
       w.forEach(function(x){ netEntWord(peer,x); }); netEntsApply(peer,{t:'ents',sd:g.seed>>>0,e:r,n:5}); }
     var s, hc, pc;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; g.t=50; G.pCrouch=false;
       s=mkSentry(p.x+300,p.y); s.nid=950; s.state='chase'; s.searchX=s.x+50; s.searchY=s.y; s.sirenSeeT=0; s.searchLvl=1;
       hc=searchCone(s); if(!hc||!(hc.reach>0)) return 'SKIP: staging: the host sentry draws no scan cone';
       link([s]); mm=NET.entMap[950]; if(!mm) return 'SKIP: staging: the linked window made no copy';
       pc=searchCone(mm); if(!pc) return 'SKIP: staging: the copy draws no scan cone';
       if(Math.abs(pc.reach-hc.reach)>1) bad.push('the scan cone reaches '+Math.round(hc.reach)+' on the host and '+Math.round(pc.reach)+' in player 2 window (copy rng '+mm.rng+', host '+s.rng+')');
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; } try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
