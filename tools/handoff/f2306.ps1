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

if ($s.Contains("  {v:'23.06',what:")) { throw "check 23.06 is in the fixture already" }

SubRx @'
  {v:'23.05',what:
'@ @'
  {v:'23.06',what:'objective lines in caps: a Warden destroyed one kill short of a kill contract says CONTRACT DONE as its own headline with his words after his colon as the detail (drawn as CONTRACT DONE, the dot, then his words), and WARDEN ... DESTROYED with It dropped a cache., and no line says is down. Its core; a door, the seal and the hot ground say caps headlines',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)||typeof mkWarden!=='function'||typeof contractKill!=='function'||typeof contractDesc!=='function'||typeof msgRowText!=='function'||typeof canSee!=='function') return 'SKIP: no Warden, contracts or feed rows here';
     var bad=[], P2=__P(), con0=P2.contracts, g=null, p=null, i, a, rr=null, e, c, said=[], realSay=say, realWF=sayWhenFree, hit=null, des=null, all, HIS, OLD='is down. Its '+'core';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false; p.iv=99;
       c={type:'kill',tgt:'warden',n:2,prog:1,desc:'Destroy 2 Wardens',reward:100,id:'zqx53'};
       P2.contracts=[c];
       HIS=contractDesc(c)+'. Complete contract at mainframe.';
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); return realSay.apply(this,arguments); };
       for(a=0;a<16&&!rr;a++){ var ang=a*Math.PI/8, tx=p.x+Math.cos(ang)*140, ty=p.y+Math.sin(ang)*140; p.face=ang; if(canSee(p.x,p.y,p.face,tx,ty,g.vseg)) rr={x:tx,y:ty}; }
       if(!rr) return 'SKIP: staging: no clear line of sight from the spawn';
       e=mkWarden(rr.x,rr.y); e.hp=0; e.byPlayer=1; e.state='patrol'; e.boss=0;
       g.ents.length=0; g.ents.push(e);
       said.length=0; __ents(0.016);
       if(c.prog<c.n) contractKill('warden');
       all=said.map(function(l){ return l.m+(l.sub?(' | '+l.sub):''); });
       for(i=0;i<said.length;i++){
         if(said[i].m.indexOf('CONTRACT DONE')===0) hit=said[i];
         if((/DESTROYED$/).test(said[i].m)) des=said[i];
         if((said[i].m+' '+said[i].sub).indexOf(OLD)>=0) bad.push('a Warden destroyed still says '+JSON.stringify(said[i].m));
       }
       if(!hit) bad.push('the contract finished with no CONTRACT DONE line (said: '+JSON.stringify(all)+')');
       else {
         if(hit.m!=='CONTRACT DONE') bad.push('CONTRACT DONE is not its own headline: '+JSON.stringify(hit.m));
         if(hit.sub!==HIS) bad.push('the CONTRACT DONE detail is '+JSON.stringify(hit.sub)+', not his words '+JSON.stringify(HIS));
         if(msgRowText({m:hit.m,sub:hit.sub}).indexOf('CONTRACT DONE  \u00b7  '+HIS)!==0) bad.push('the feed row does not draw CONTRACT DONE, the dot, then his words');
       }
       if(!des) bad.push('a Warden destroyed said no headline ending in DESTROYED (said: '+JSON.stringify(all)+')');
       else if(des.m!==des.m.toUpperCase()||des.m.length>34) bad.push('the Warden line '+JSON.stringify(des.m)+' is not a caps headline of at most 34');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; sayWhenFree=realWF; P2.contracts=con0; keys={};
       try{ var g2=__state(); if(g2){ g2.ents.length=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
