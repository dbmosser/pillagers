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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'cw-cx-levelbar: every career SP source fills the living pillager through successive levels, extraction bonus once, cap 20, HUD and head name/level, no demo or sim progression; old save reload preserves possessions and progression',
   run:function(){
     if(typeof pilSPAdd!=='function'||typeof pilLevelHud!=='function') return 'no survival level bar';
     var saved=P, oldSave=saveProfile, oldStore=storeSet, co=CAREER_ON, ao=ARCADE.on, b=bar, ht=hudText, wf=wc.fillText, net0=NET, fast=netSendFast, g, snap, before, bad=[], rec=[], texts=[], heads=[], k;
     function need(ok,s){if(!ok) bad.push(s);}
     function kept(){var o={}; ['credits','stash','weapons','equipped','contracts','forged','gear','worn','hall','pil','pilGen','acctName','lifeEarn'].forEach(function(k){o[k]=P[k];}); return JSON.stringify(o);}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       saveProfile=function(){}; storeSet=function(){}; CAREER_ON=1; ARCADE.on=false;
       applyLoadedProfile({value:JSON.stringify(P)});
       P.pil=pilMake('ozzrik',1); P.pil.lsp=550; P.credits=1234; P.stash=['scrap','core','frag']; P.weapons=['pistol','smg']; P.equipped='smg'; P.forged={smg:{fk:2,el:'shock'}};
       snap=JSON.parse(JSON.stringify(P)); snap.cfg=JSON.parse(JSON.stringify(CFG)); snap.cfgv=18;
       before=kept(); applyLoadedProfile({value:JSON.stringify(snap)}); need(kept()===before,'old save changed belongings or pillager');
       applyLoadedProfile({value:JSON.stringify(P)}); need(kept()===before,'second reload changed old save');
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state();
       need(g&&g.career&&g.cs,'no career staging'); if(!g||!g.cs) return bad.join('; ');
       P.pil=pilMake('ozzrik',1); g.cs.s=0; g.cs.b={};
       var r=careerKill('crawler',0,false,g.player.x,g.player.y), n=P.pil.lsp;
       need(n===g.cs.s&&n>=r&&r>0,'kill or its style SP missing');
       var s=g.cs.s; scoreBonus(100,g.player.x,g.player.y,''); need(P.pil.lsp-n===g.cs.s-s,'style SP missing');
       n=P.pil.lsp; s=g.cs.s; arcadeVaultPay({}); need(P.pil.lsp-n===g.cs.s-s&&P.pil.lsp>n,'vault SP missing');
       ['bounty','strong','kill','style','vault'].forEach(function(cat){var a=P.pil.lsp; csTally(cat,17); need(P.pil.lsp===a+17,cat+' tally missing');});
       P.pil.lsp=0; P.pil.lvl=1; pilSPAdd(3050); need(P.pil.lvl===3,'early surviving raid is not two levels');
       pilSPAdd(10000); need(P.pil.lvl===pilLevelOf(13050)&&P.pil.lsp===13050,'multi-level award lost remainder');
       bar=function(x,y,w,h,f,c){rec.push({h:h,f:f});}; hudText=function(s){texts.push(String(s));};
       need(pilLevelHud(16,H-107,300),'career bar hidden'); need(rec.length===1&&rec[0].h===6&&rec[0].f>0&&rec[0].f<1,'bar does not show partial next level');
       need(texts.indexOf('pillager survival level')>=0&&texts.indexOf(String(P.pil.lvl))>=0,'label or level missing');
       wc.fillText=function(s){heads.push(String(s));}; need(pilLevelTag()&&heads.join('|')==='ozzrik  '+P.pil.lvl,'head is not name and level only'); wc.fillText=wf;
       var msg={}; netPnPut(msg,10); need(msg.pl===P.pil.lvl,'state packet omits head level');
       var forwarded=[], peer={state:'in',seat:1}, receiver={state:'in',seat:2};
       NET=Object.assign({},net0,{on:false,role:'host',seat:0,max:3,up:[],floor:[],pn:{},roster:[{seat:0,name:'host'},{seat:1,name:'partner'},{seat:2,name:'third'}],peers:[peer,receiver]});
       netSendFast=function(p,m){forwarded.push(m);};
       netOnState(peer,{x:100,y:100,k:'r',pl:7,pn:'partner',sd:4242});
       need(NET.up[1]&&NET.up[1].pl===7&&forwarded[0]&&forwarded[0].pl===7,'received or relayed level missing');
       netOnState(peer,{x:100,y:100,k:'r',pl:99,pn:'partner',sd:4242}); need(NET.up[1].pl===0,'invalid level accepted');
       NET=net0; netSendFast=fast;
       snap=JSON.parse(JSON.stringify(P)); before=kept(); applyLoadedProfile({value:JSON.stringify(snap)}); need(kept()===before,'earned SP lost on reload');
       applyLoadedProfile({value:JSON.stringify(P)}); need(kept()===before,'earned SP moved on second reload');
       P.pil.lsp=0; P.pil.lvl=1; g.cs.s=1000; delete g.careerPaid;
       var fin=Math.round(2000*raidConditionMul()); careerSettle('extract',[]); n=P.pil.lsp; need(n===Math.max(0,fin-1000),'extraction SP bonus missing');
       careerSettle('extract',[]); need(P.pil.lsp===n,'extraction bonus paid twice');
       P.pil.lsp=0; P.pil.lvl=1; for(k=0;k<15;k++) pilSPAdd(3050); need(P.pil.lvl===20&&P.pil.lsp===44650,'15 median surviving raids did not cap at 20');
       pilSPAdd(1e8); need(P.pil.lvl===20&&P.pil.lsp===44650,'level cap overflow');
       rec=[]; texts=[]; pilLevelHud(16,H-107,300); need(rec[0]&&rec[0].f===1,'cap bar not full');
       n=P.pil.lsp; ARCADE.on=true; rec=[]; need(!pilLevelHud(16,H-107,300)&&rec.length===0&&!pilLevelTag(),'demo displays career progression');
       need(pilSPAdd(500)===0&&P.pil.lsp===n,'demo earned survival SP'); ARCADE.on=false;
       g.sim=true; need(pilSPAdd(500)===0&&!pilLevelHud(16,H-107,300),'sim earns or displays levels'); g.sim=false;
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       bar=b; hudText=ht; wc.fillText=wf; NET=net0; netSendFast=fast;
       try{if(g) g.sim=false; __endRaid('abandon');}catch(e){} __topClear();
       P=saved; saveProfile=oldSave; storeSet=oldStore; CAREER_ON=co; ARCADE.on=ao;
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
