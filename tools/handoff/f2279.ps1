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

if ($s.Contains("  {v:'22.79',what:")) { throw "check 22.79 is in the fixture already" }

SubRx @'
  {v:'22.78',what:
'@ @'
  {v:'22.79',what:'heal and plate lines are caps callouts: the heal verb says HEALTH FULL at full, BANDAGES STOP AT 85 with a detail, NO MEDICAL SUPPLIES and ALREADY APPLYING; a plate landing says ARMOUR PLATE SLOTTED; patching up a teammate says NAME ARMOUR FULL, NAME DOES NOT NEED IT, NO BANDAGE LEFT and SELECT A HEAL; every one is caps, at most 34 characters, with no end punctuation',
   run:function(){
     if(typeof useMedical!=='function'||typeof netAidStart!=='function'||typeof netAidHold!=='function'||typeof tickPrepSlot!=='function'||typeof healCeil!=='function') return 'SKIP: no heal verb or teammate aid here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof NET!=='object'||!NET||!ITEMS.plate||!ITEMS.bandage) return 'SKIP: this fixture cannot deploy';
     var bad=[], oSay=say, said=[], g=null, p=null, cap, l, s, k, keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster};
     function first(){ return said.length?said[0]:null; }
     function voice(what,want){
       var l=first();
       if(!l){ bad.push(what+' said nothing'); return null; }
       if(l.m!==l.m.toUpperCase()||l.m.length>34||/[.!?,;:]$/.test(l.m)) bad.push(what+' said '+JSON.stringify(l.m)+', not a caps callout');
       else if(want&&l.m.indexOf(want)!==0) bad.push(what+' said '+JSON.stringify(l.m)+', not '+want);
       return l;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; p.downed=false; p.dying=false; p.prep=null; p.prepA=null; p.healQ=0; p.healCap=undefined;
       say=function(m,kd,o){ said.push({m:String(m),k:kd,o:o||null}); };
       cap=Math.round(healCeil(ITEMS.bandage));
       g.bag=['medkit']; p.hp=p.maxhp; said.length=0; useMedical(); voice('the heal verb at full health with a Medkit','HEALTH FULL');
       if(cap<p.maxhp){
         g.bag=['bandage','bandage']; p.hp=cap; said.length=0; useMedical();
         l=voice('the heal verb at '+cap+' with only Bandages','BANDAGES STOP AT '+cap);
         if(l&&l.m.indexOf('BANDAGES STOP')===0&&!(l.o&&l.o.sub)) bad.push('the Bandage ceiling line has no detail naming the Medkit');
       }
       g.bag=[]; p.hp=50; said.length=0; useMedical(); voice('the heal verb with nothing to heal with','NO MEDICAL SUPPLIES');
       g.bag=['bandage']; p.hp=40; p.prep={t:0,max:99,kind:'heal',key:'bandage'}; said.length=0; useMedical(); voice('the heal verb while a Bandage goes on','ALREADY APPLYING');
       p.prep=null;
       p.armor=0; p.prepA={t:0,max:0.01,kind:'armor',key:'plate'}; said.length=0; tickPrepSlot(p,'prepA',1);
       voice('a plate landing',(ITEMS.plate.name+' slotted').toUpperCase());
       p.prepA=null;
       // a teammate beside him
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:1}];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       NET.up=[]; NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,tx:p.x+30,ty:p.y,tf:0,n:5,age:0,dn:0,hp:100,mh:100,ar:50,ac:50,sd:NET.upSeed>>>0};
       g.bag=['plate']; said.length=0; netAidStart(1,'plate'); voice('a plate for a teammate with full armour','ZQX MATE ARMOUR FULL');
       g.bag=['bandage']; said.length=0; netAidStart(1,'bandage'); voice('a Bandage for a teammate at full health','ZQX MATE DOES NOT NEED IT');
       NET.up[1].hp=40; g.bag=[]; said.length=0; netAidStart(1,'bandage'); voice('a Bandage for a hurt teammate with none left',('No '+ITEMS.bandage.name+' left').toUpperCase());
       p.prep=null; p.prepA=null;
       s=-1; try{ s=netAidTarget(p,true); }catch(_t){}
       if(s===1){
         g.bag=[]; g.hotAssign={}; g.hotAuto={};
         for(k=0;k<hotbarSlots().length;k++){ var hs=hotbarSlots()[k]; if(!hs||(hs.kind!=='heal'&&hs.kind!=='armor')){ g.hot=k; break; } }
         said.length=0; netAidHold(false); voice('the aid key with no heal selected','SELECT A HEAL');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; keys={};
       for(k in keep) NET[k]=keep[k];
       try{ var g2=__state(); if(g2){ g2.player.prep=null; g2.player.prepA=null; g2.player.healQ=0; g2.player.healCap=undefined; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
