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

if ($s.Contains("  {v:'26.17',what:")) { throw "check 26.17 is in the fixture already" }

SubRx @'
  {v:'26.16',what:
'@ @'
  {v:'26.17',what:'his order (2026-10-14): a kit never issues a loaner: with no gun anywhere TOP GEAR, RANDOM FROM STASH, MY LOADOUT and the quick ascent go up with the Scav Pistol in hand (not issued, not from the armoury), an extraction banks it into an empty armoury and adds no second one to the stash, a death bills nothing for it, and with a gun owned only that gun goes up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)||typeof askKit!=='function'||typeof kitExtraHide!=='function'||typeof STARTERS==='undefined'||typeof saveProfile!=='function'||!WEAPONS.pistol||!WEAPONS.smg) return 'SKIP: this fixture cannot ask the kit question and deploy';
     var md=document.getElementById('askmodal'), bT=document.getElementById('asktop'), bR=document.getElementById('askrand'), bY=document.getElementById('askyes');
     if(!md||!bT||!bR||!bY) return 'SKIP: no kit card in this page';
     var bad=[], P2=__P(), i, why, g, p, txt, oc, n0, r;
     var KEYS=['weapons','equipped','equippedSec','stash','kit','kitChosen','freeKit','forged','runs','ext','died','best','credits','xp','kills','log','notExt','notoriety','mapIx'];
     function snap(v){ var o,k; if(v&&v.slice) return v.slice(); if(v&&typeof v==='object'){ o={}; for(k in v) o[k]=v[k]; return o; } return v; }
     var keep={}; for(i=0;i<KEYS.length;i++) keep[KEYS[i]]=snap(P2[KEYS[i]]);
     function loaners(tag){ var q=__state().player, o=[];
       if(q.wepIssued||q.secIssued) o.push(tag+': a hand is flagged issued');
       if(STARTERS.indexOf(q.wep&&q.wep.id)>=0||STARTERS.indexOf(q.sec&&q.sec.id)>=0) o.push(tag+': a loaner starter ('+(q.wep&&q.wep.id)+' / '+(q.sec&&q.sec.id)+') is in a hand');
       if(__state().bag.some(function(k){ return /^gun_/.test(k); })) o.push(tag+': a gun was put in the backpack');
       return o; }
     function up(btn,weapons,equipped){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.weapons=weapons.slice(); P2.equipped=equipped; P2.equippedSec='none'; P2.kit=[]; P2.stash=[]; P2.freeKit=0; P2.kitChosen=0; P2.forged={};
       if(btn){
         askKit(function(){},true);
         if(!md.classList.contains('on')) return 'the kit card did not open';
         btn.click();
       }
       __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var q=__state(); if(!q||q.over||q.sim||!q.player) return 'no live raid';
       return null; }
     function card(){ var el=document.getElementById('outcome'), t=''; try{ t=((el&&el.innerText)||'').replace(/\s+/g,' '); }catch(_t){} try{ if(el) el.classList.remove('on'); }catch(_o){} return t; }
     try{
       // ONE: no gun anywhere. Every way up takes the Scav Pistol in hand and nothing else.
       var routes=[['TOP GEAR',bT],['RANDOM FROM STASH',bR],['MY LOADOUT',bY],['the quick ascent',null]];
       for(i=0;i<routes.length;i++){
         why=up(routes[i][1],[],'fists'); if(why) return 'SKIP: staging: '+why+' ('+routes[i][0]+')';
         g=__state(); p=g.player;
         if(!(p.wep&&p.wep.id==='pistol')) bad.push(routes[i][0]+' with no gun anywhere went up holding '+(p.wep&&p.wep.id)+', not the Scav Pistol');
         else if(p.wepIssued||p.wepFromArmory) bad.push(routes[i][0]+' with no gun anywhere put an '+(p.wepIssued?'issued':'armoury')+' pistol in hand, not the free pistol the freebie kit hands out');
         if(!(p.sec&&p.sec.id==='fists')) bad.push(routes[i][0]+' with no gun anywhere filled gun 2 with '+(p.sec&&p.sec.id));
         bad=bad.concat(loaners(routes[i][0]));
         __endRaid('abandon'); __topClear();
       }
       // TWO: one gun of his own in the armoury. That gun goes up and nothing is added beside it.
       var routes2=[['TOP GEAR',bT,'fists'],['RANDOM FROM STASH',bR,'fists'],['MY LOADOUT',bY,'smg']];
       for(i=0;i<routes2.length;i++){
         why=up(routes2[i][1],['smg'],routes2[i][2]); if(why) return 'SKIP: staging: '+why+' ('+routes2[i][0]+')';
         g=__state(); p=g.player;
         if(!(p.wep&&p.wep.id==='smg'&&p.wepFromArmory&&!p.wepIssued)) bad.push(routes2[i][0]+' with only the Compact SMG owned went up holding '+(p.wep&&p.wep.id)+' (armoury '+(p.wepFromArmory)+', issued '+(p.wepIssued)+')');
         if(!(p.sec&&p.sec.id==='fists')) bad.push(routes2[i][0]+' with only the Compact SMG owned filled gun 2 with '+(p.sec&&p.sec.id)+', a gun added beside his own');
         bad=bad.concat(loaners(routes2[i][0]));
         __endRaid('abandon'); __topClear();
       }
       // THREE: the free pistol follows the pistol rules. Extracted, it is banked into an armoury that has none; a death bills nothing.
       why=up(bT,[],'fists'); if(why) return 'SKIP: staging: '+why+' (extraction)';
       g=__state(); p=g.player; g.bag=[]; p.downed=false; p.hp=100;
       __endRaid('extract');
       if(P2.weapons.indexOf('pistol')<0) bad.push('extracting with the free Scav Pistol in hand banked nothing (the armoury holds ['+P2.weapons.join(',')+']), as if it were still a loaner');
       __topClear();
       why=up(bT,[],'fists'); if(why) return 'SKIP: staging: '+why+' (death)';
       g=__state(); p=g.player; p.downed=false;
       __endRaid('dead');
       txt=card();
       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');
       if(/and 1 gun/.test(txt)) bad.push('the death card bills the free Scav Pistol as a gun he lost');
       if(P2.weapons.length) bad.push('dying with the free Scav Pistol left ['+P2.weapons.join(',')+'] in an armoury that was empty');
       __topClear();
       // FOUR: with the armoury pistol every save starts with at home and nothing in gun 1, the free pistol is not a second one for the stash,
       // and dying with it does not take the one he owns.
       why=up(null,['pistol'],'fists'); if(why) return 'SKIP: staging: '+why+' (armoury pistol, extraction)';
       g=__state(); p=g.player;
       if(!(p.wep&&p.wep.id==='pistol'&&!p.wepIssued&&!p.wepFromArmory)) bad.push('with only the armoury pistol and bare hands equipped he went up holding '+(p.wep&&p.wep.id)+' (armoury '+(p.wepFromArmory)+', issued '+(p.wepIssued)+'), not the free Scav Pistol');
       g.bag=[]; p.downed=false; p.hp=100;
       __endRaid('extract');
       if(P2.stash.indexOf('gun_pistol')>=0) bad.push('extracting with the free Scav Pistol put a second Scav Pistol in the stash');
       if(P2.weapons.indexOf('pistol')<0) bad.push('extracting with the free Scav Pistol took the armoury pistol out of the armoury');
       __topClear();
       why=up(null,['pistol'],'fists'); if(why) return 'SKIP: staging: '+why+' (armoury pistol, death)';
       g=__state(); p=g.player; p.downed=false;
       __endRaid('dead');
       txt=card();
       if(P2.weapons.indexOf('pistol')<0) bad.push('dying with the free Scav Pistol deleted the armoury pistol he owns');
       if(/and 1 gun/.test(txt)) bad.push('the death card bills the free Scav Pistol as a gun he lost when he owns the armoury pistol');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; g3.bag=[]; __endRaid('abandon'); } }catch(_e){}
       try{ md.classList.remove('on'); kitExtraHide(); ASKYES=null; ASKALT=null; }catch(_m){}
       for(i=0;i<KEYS.length;i++) P2[KEYS[i]]=keep[KEYS[i]];
       try{ saveProfile(); }catch(_s2){}
       try{ card(); }catch(_c0){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'26.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
