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

if ($s.Contains("  {v:'23.04',what:")) { throw "check 23.04 is in the fixture already" }

SubRx @'
  {v:'23.03',what:
'@ @'
  {v:'23.04',what:'heal and armour lines in caps: full health, a Bandage over time (silent, the status icon shows it), a Bandage at once, no stim, a stim and its wearing off, the self-revive, a teammate heal kept, a heal and a plate from a teammate and a heal sent back all say a caps headline of at most 34 characters with any detail of at most 48 and no ellipsis, and the stim detail takes its seconds from STIM_SEC',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof useMedical!=='function'||typeof useStim!=='function'||typeof selfRevive!=='function'||typeof tickPrepSlot!=='function'||typeof netAidFinish!=='function'||typeof netAidApply!=='function'||typeof netAidKept!=='function'||typeof STIM_SEC==='undefined'||!ITEMS.stim||!ITEMS.bandage) return 'SKIP: no heal, stim, self-revive or teammate aid here';
     var bad=[], g=null, p=null, i, said=[], realSay=say, hot0=CFG.healOverTime, keepN={on:NET.on,seat:NET.seat,roster:NET.roster,up:NET.up,role:NET.role,peers:NET.peers}, stimL=null, n0;
     function voice(what,need){
       if(!said.length){ if(need) bad.push(what+' said nothing'); return; }
       for(var k=0;k<said.length;k++){
         var l=said[k], m=String(l.m), s=String(l.sub||'');
         if(m!==m.toUpperCase()||m.length>34||(/[.!?,;:]$/).test(m)) bad.push(what+' said '+JSON.stringify(m)+', not a caps headline of at most 34');
         if(s.length>48) bad.push(what+' has a detail of '+s.length+' characters: '+JSON.stringify(s));
         if((m+s).indexOf('...')>=0) bad.push(what+' has an ellipsis: '+JSON.stringify(m+' '+s));
       }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false; p.roll=0;
       say=function(m,k,o){ said.push({m:String(m),k:k,sub:(o&&o.sub)||''}); return realSay.apply(this,arguments); };
       // full health
       p.hp=p.maxhp; p.healQ=0; p.prep=null; said.length=0; useMedical(); voice('the heal verb at full health',true);
       // a Bandage over time lands silent; at once it says PATCHED UP
       p.hp=50; p.healQ=0; p.prep={t:9,max:1,kind:'heal',key:'bandage'}; said.length=0; tickPrepSlot(p,'prep',0.016);
       voice('a Bandage landing over time',false);
       if(said.length) bad.push('a Bandage landing over time still says '+JSON.stringify(said[0].m)+', which the status icon shows');
       CFG.healOverTime=0; p.hp=50; p.healQ=0; p.prep={t:9,max:1,kind:'heal',key:'bandage'}; said.length=0; tickPrepSlot(p,'prep',0.016);
       voice('a Bandage landing at once',true); CFG.healOverTime=hot0;
       // the stim: none, one, and its end
       for(i=g.bag.length-1;i>=0;i--) if(g.bag[i]==='stim') g.bag.splice(i,1);
       said.length=0; useStim(); voice('a stim with none left',true);
       g.bag.push('stim'); said.length=0; useStim(); voice('a stim',true);
       for(i=0;i<said.length;i++) if(said[i].sub) stimL=said[i].sub;
       if(!stimL||stimL.indexOf(STIM_SEC+'s')!==0) bad.push('the stim detail does not give its '+STIM_SEC+'s from STIM_SEC: '+JSON.stringify(stimL));
       p.stimT=0.01; said.length=0; n0=0;
       for(i=0;i<5&&p.stimT>0;i++) __sim(0.05);
       said=said.filter(function(l){ return String(l.m).toUpperCase().indexOf('STIM')>=0||String(l.m).toLowerCase().indexOf('stim')>=0; });
       voice('the stim wearing off',true);
       // the self-revive
       p.downed=true; p.revived=false; said.length=0; selfRevive(); voice('the self-revive',true); p.downed=false;
       // teammate aid
       NET.roster=[{seat:0,name:'Host'},{seat:1,name:'Zqxkidwithalongnm'.slice(0,16)}]; NET.up=[]; NET.role='join'; NET.peers=[];
       said.length=0; netAidFinish({aid:1,key:'bandage'}); voice('a heal for a teammate who moved away',true);
       p.hp=50; p.healQ=0; p.prep=null; said.length=0; netAidApply(1,'bandage',0); voice('a heal from a teammate',true);
       p.armor=0; said.length=0; netAidApply(1,'plate',0); voice('a plate from a teammate',true);
       said.length=0; netAidKept(1,'bandage','full',0); voice('a heal sent back from a teammate already healing',true);
       said.length=0; netAidKept(1,'bandage','down',0); voice('a heal sent back from a teammate who could not take it',true);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; CFG.healOverTime=hot0; NET.on=keepN.on; NET.seat=keepN.seat; NET.roster=keepN.roster; NET.up=keepN.up; NET.role=keepN.role; NET.peers=keepN.peers; keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.prep=null; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
