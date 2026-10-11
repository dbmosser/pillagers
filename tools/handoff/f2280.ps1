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

if ($s.Contains("  {v:'22.80',what:")) { throw "check 22.80 is in the fixture already" }

SubRx @'
  {v:'22.79',what:
'@ @'
  {v:'22.80',what:'backpack and offer lines are caps callouts: a gun key whose gun left the backpack says NOT IN BACKPACK with the gun as the detail, an offer that ran out says OFFER EXPIRED and one nobody took says NAME DID NOT TAKE IT, each with the rest as the detail, the offer key with nobody near says NO TEAMMATE IN RANGE and with the highlight on the belt MOVE IT TO THE BACKPACK FIRST; every one is caps, at most 34 characters, with no end punctuation',
   run:function(){
     if(typeof giftTick!=='function'||typeof netGiftKey!=='function'||typeof bagBeltNo!=='function'||typeof setHot!=='function') return 'SKIP: no offers or belt keys here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot deploy';
     var bad=[], oSay=say, oHS=hotbarSlots, oSend=netSend, said=[], g=null, p=null, k, gk=null, lk=null, hot0=0, keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster};
     function voice(what,want,sub){
       var l=said.length?said[0]:null;
       if(!l){ bad.push(what+' said nothing'); return; }
       if(l.m!==l.m.toUpperCase()||l.m.length>34||/[.!?,;:]$/.test(l.m)) bad.push(what+' said '+JSON.stringify(l.m)+', not a caps callout');
       else if(want&&l.m!==want) bad.push(what+' said '+JSON.stringify(l.m)+', not '+want);
       else if(sub&&!(l.o&&String(l.o.sub||'').toUpperCase().indexOf(sub)>=0)) bad.push(what+' has no detail naming '+sub);
     }
     for(k in ITEMS) if(ITEMS[k]&&ITEMS[k].use==='gun'&&ITEMS[k].name){ if(!gk) gk=k; if(!lk||ITEMS[k].name.length>ITEMS[lk].name.length) lk=k; }
     if(!gk) return 'SKIP: no gun item here';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; p.downed=false; hot0=g.hot;
       say=function(m,kd,o){ said.push({m:String(m),k:kd,o:o||null}); };
       netSend=function(){ return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       // an offer to him that ran out, and one of his nobody took (the longest gun name)
       g.giftIn={id:'zq1',from:1,k:'bandage',t:(g.t||0)-GIFT_T-1}; g.giftOut=null; said.length=0; giftTick();
       voice('an offer that ran out','OFFER EXPIRED','ZQX MATE');
       g.giftIn=null; g.giftOut={id:'zq2',k:lk,to:1,t:(g.t||0)-GIFT_T-6}; said.length=0; giftTick();
       voice('an offer of the '+ITEMS[lk].name+' nobody took','ZQX MATE DID NOT TAKE IT',String(ITEMS[lk].name).toUpperCase());
       g.giftOut=null;
       // the offer key, backpack open, nobody near
       g.bag=['bandage']; g.bagOpen=true; g.bagBelt=false; g.bagSel=0; said.length=0; netGiftKey();
       voice('the offer key with nobody near','NO TEAMMATE IN RANGE');
       g.giftOut=null;
       g.bagBelt=true; said.length=0; netGiftKey();
       voice('the offer key with the highlight on the belt','MOVE IT TO THE BACKPACK FIRST');
       g.bagOpen=false; g.bagBelt=false;
       // a gun key whose gun is not in the backpack
       g.bag=[]; g.hot=0;
       hotbarSlots=function(){ return [{kind:'gun',k:'gunA',inHand:true,equipped:true,name:'ZQX'},{kind:'gun',k:'hzq',itemKey:gk,name:ITEMS[gk].name,assigned:true}]; };
       said.length=0; try{ setHot(1); }catch(_h){}
       voice('a gun key whose gun left the backpack','NOT IN BACKPACK',String(ITEMS[gk].name).toUpperCase());
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; hotbarSlots=oHS; netSend=oSend; keys={};
       for(k in keep) NET[k]=keep[k];
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; g2.bagOpen=false; g2.bagBelt=false; g2.hot=hot0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
