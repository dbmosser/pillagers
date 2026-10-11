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

if ($s.Contains("  {v:'23.07',what:")) { throw "check 23.07 is in the fixture already" }

SubRx @'
  {v:'23.06',what:
'@ @'
  {v:'23.07',what:'people lines in caps: the three hire orders, a hail with nobody near, a revive by a teammate, a survivor who wants ammunition you cannot spare, a gift a downed teammate cannot take and a teammate searching your box each say a caps headline of at most 34 with any detail of at most 48, and no line says Order:, slab or pulls you up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof raidKey!=='function'||typeof netRevApply!=='function'||typeof strayGive!=='function'||typeof mkStray!=='function'||typeof netGiftTake!=='function'||typeof doEmote!=='function'||typeof EMOTES==='undefined') return 'SKIP: no hire orders, revives, survivors, gifts or emotes here';
     var bad=[], g=null, p=null, i, hx=-1, said=[], realSay=say, realWF=sayWhenFree, all=[], keepN={on:NET.on,seat:NET.seat,roster:NET.roster,up:NET.up,role:NET.role,peers:NET.peers},
         OLD=['Order'+':','sl'+'ab','pulls '+'you up'], hire, e, r0=null;
     function need(tag,n0){ if(said.length<=n0) bad.push(tag+' said nothing'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false; p.roll=0; p.ads=false; p.iv=99; g.paused=false;
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); return realSay.apply(this,arguments); };
       sayWhenFree=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); };
       // ONE: the hire orders
       hire={kind:'raider',merc:1,downed:0,name:'Zqxhire',x:p.x+60,y:p.y,hp:100,maxhp:100,bag:[],state:'follow'};
       g.ents.length=0; g.ents.push(hire);
       for(i=0;i<3;i++){ var n0=said.length; raidKey('KeyO',false); need('hire order '+(i+1),n0); }
       g.ents.length=0;
       // TWO: a hail with nobody near
       for(i=0;i<EMOTES.length;i++) if(EMOTES[i].k==='hail') hx=i;
       if(hx>=0){ g.emoteCd=0; var n1=said.length; doEmote(hx); need('a hail with nobody near',n1); }
       // THREE: a revive by a teammate
       NET.roster=[{seat:0,name:'Host'},{seat:1,name:'Zqxkid'}]; NET.up=[]; NET.up[1]={x:p.x+10,y:p.y,seat:1}; NET.role='join'; NET.peers=[];
       p.downed=true; g.deathBeat=null; var n2=said.length; r0=netRevApply(1); p.downed=false;
       if(r0!=='not down'&&r0!=='far'&&r0!=='no raid') need('a revive by a teammate',n2);
       // FOUR: a survivor who wants ammunition you cannot spare
       e=mkStray(p.x+40,p.y); e.want='ammobox'; e.helped=0; p.reserve=0;
       for(i=g.bag.length-1;i>=0;i--) if(g.bag[i]==='ammobox') g.bag.splice(i,1);
       var n3=said.length; strayGive(e); need('a survivor who wants ammunition',n3);
       // FIVE: a gift a downed teammate cannot take
       g.giftOut={id:'zqx54',k:'bandage',to:1,t:g.t};
       netGiftTake({state:'in',seat:1,name:'Zqxkid'},{t:'gift',op:'no',id:'zqx54',why:'down'});
       g.giftOut=null;
       // every line said
       for(i=0;i<said.length;i++){
         var l=said[i], s=l.m+' '+l.sub;
         if(l.m!==l.m.toUpperCase()||l.m.length>34||(/[.!?,;:]$/).test(l.m)) bad.push(JSON.stringify(l.m)+' is not a caps headline of at most 34');
         if(l.sub.length>48) bad.push(JSON.stringify(l.m)+' has a detail of '+l.sub.length+' characters');
         for(var q=0;q<OLD.length;q++) if(s.indexOf(OLD[q])>=0) bad.push(JSON.stringify(s)+' still says '+OLD[q]);
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; sayWhenFree=realWF; NET.on=keepN.on; NET.seat=keepN.seat; NET.roster=keepN.roster; NET.up=keepN.up; NET.role=keepN.role; NET.peers=keepN.peers; keys={};
       try{ var g2=__state(); if(g2){ g2.ents.length=0; g2.giftOut=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
