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

if ($s.Contains("  {v:'28.40',what:")) { throw "check 28.40 is in the fixture already" }

SubRx @'
  {v:'28.39',what:
'@ @'
  {v:'28.40',what:'cloud-coop-search-cones-built: a body that player 2 window built itself with the raid (no net flag, no AI of its own there) shows the search cone when a host row says it is searching, as it does on the host; a body the row says is not searching shows none, and a solo raid decides searching as before',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof searching!=='function'||typeof searchCone!=='function'||typeof netEntsApply!=='function'||typeof netEntRow!=='function'||typeof netEntsPeer!=='function') return 'SKIP: no search cone or linked bodies in this fixture';
     var bad=[], g=null, NK={}, k, oSF=netSendFast, oS=netSend, h={seat:0,state:'in'}, staged=false, all=null, s=null, c=null, c2=null, row, row2, r, hc, oC, rs=say, own=false;
     function copyOf(b,id){ var q={}, kk; for(kk in b) q[kk]=b[kk]; delete q.net; delete q.searchX; delete q.searchY; q.searchLvl=0; q.srch=undefined; q.nid=id; q.nIn=1; q.state='patrol'; return q; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       all=g.ents.slice(); oC=g.pCrouch; g.pCrouch=false;
       say=function(){}; own=true;
       s=all.filter(function(x){ return x&&x.kind==='sentry'&&!x.boss&&!x.net&&x.hp>0; })[0];
       if(!s) return 'SKIP: no sentry on map 0 seed 4242';
       // the host body, searching
       s.state='chase'; s.searchX=s.x+100; s.searchY=s.y; s.sirenSeeT=-99; s.searchLvl=2;
       hc=searchCone(s);
       if(!hc) bad.push('the host body set up to search draws no cone on the host');
       row=JSON.parse(JSON.stringify(netEntRow(s))); row[0]=9101;
       // SOLO: no link, a body with no search point is not searching whatever its srch says
       c2=copyOf(s,9102); c2.srch=1; c2.state='chase';
       if(searching(c2)) bad.push('SOLO: a body with no search point counted as searching in a raid with no link');
       if(!searching(s)) bad.push('SOLO: the searching host body did not count as searching');
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; NET.entLast=0; NET.entGone={};
       netSendFast=function(){ return true; }; netSend=function(){ return true; };
       if(!netEntsPeer()) return 'SKIP: the staged player 2 window is not linked up top';
       c=copyOf(s,9101); c2=copyOf(s,9102);
       NET.entMap={}; NET.entMap[9101]=c; NET.entMap[9102]=c2;
       // the row of a body that is not searching
       s.state='patrol'; delete s.searchX; delete s.searchY;
       row2=JSON.parse(JSON.stringify(netEntRow(s))); row2[0]=9102;
       r=netEntsApply(h,{sd:g.seed>>>0,n:1,e:[row,row2]});
       if(r!=='ents') bad.push('the host rows were not applied ('+r+')');
       if(!(c.srch===1)) bad.push('the row did not set the search flag on the built body ('+c.srch+')');
       if(!searching(c)) bad.push('player 2 built body the host says is searching does not count as searching');
       if(!searchCone(c)) bad.push('player 2 sees no search cone on a built body the host shows one on');
       else if(searchCone(c).lvl!==1) bad.push('player 2 built body draws search ring '+searchCone(c).lvl+', not the middle ring a linked window draws');
       if(searching(c2)||searchCone(c2)) bad.push('a built body the host says is not searching shows a cone in player 2 window');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&all){ g.ents=all; g.pCrouch=oC; } }catch(_r){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
