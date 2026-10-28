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

if ($s.Contains("  {v:'35.82',what:")) { throw "check 35.82 is in the fixture already" }

SubRx @'
  {v:'35.81',what:
'@ @'
  {v:'35.82',what:'cw-pillagersword, his HUD orders of 2026-10-28 (HUD Improver chat): "pillagers should always be referred to as pillagers never pillager bots", and a line never says machine without telling which machine: the kind words, the contract and goal words, the event names, the settings rows say pillager; the alarm line names the machine nearest the sound (and says nothing when no machine raised it); the locked on line names the machine that has you, counting a crowd of one kind in the plural',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof kindWord!=='function'||typeof alarmOk!=='function'||typeof say!=='function'||typeof XF_ROWS!=='object'||typeof GAMEOPTS!=='object'||typeof GOALS!=='object') return 'SKIP: no word tables here';
     var bad=[], g, p, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, oSay=say, said=[], i, e, s, sen=null, oEnts=null, oAL, ox, oy, w;
     function WB(t){ return /pillager bots?\b/i.test(String(t)); }
     function MA(t){ return /\bmachines?\b/i.test(String(t)); }
     try{
       // ONE: the tables say pillager
       if(kindWord('raider')!=='PILLAGER') bad.push('the kind word is '+JSON.stringify(kindWord('raider')));
       if(UNITPLURAL.raider!=='pillagers'||UNITNAME.raider!=='pillager') bad.push('the contract words are '+UNITNAME.raider+' / '+UNITPLURAL.raider);
       if(WB(GOALS.pill3&&GOALS.pill3.t)) bad.push('the goal reads '+GOALS.pill3.t);
       if(EVENTS.bounty&&WB(EVENTS.bounty.name)) bad.push('the bounty event reads '+EVENTS.bounty.name);
       if(EVENTS.convoy&&MA(EVENTS.convoy.name)) bad.push('the convoy event reads '+EVENTS.convoy.name);
       if(typeof goldDownName==='function'&&WB(goldDownName('raider'))) bad.push('the golden kill reads '+goldDownName('raider'));
       for(i=0;i<XF_ROWS.length;i++){ w=XF_ROWS[i]; if(w&&w.length>2&&(WB(w[1])||WB(w[2])||MA(w[1])||MA(w[2]))) bad.push('the settings row reads '+JSON.stringify(w[1]+' / '+w[2])); }
       for(i=0;i<GAMEOPTS.length;i++){ w=GAMEOPTS[i]; if(w&&(WB(w.label)||WB(w.hint)||MA(w.label)||MA(w.hint))) bad.push('the raid setup row reads '+JSON.stringify(w.label)); }
       if(typeof machWord!=='function'||typeof machSightSub!=='function'){ bad.push('no machine word for the alert lines'); return bad.join('; '); }
       if(machWord({kind:'warden',boss:1})!=='OVERSEER') bad.push('the Overseer is called '+machWord({kind:'warden',boss:1}));
       // TWO: a career raid; the alarm line names the machine nearest the sound
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player;
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e&&e.kind==='sentry'&&e.hp>0){ sen=e; break; } }
       if(!sen) return 'SKIP: staging: no sentry';
       ox=sen.x; oy=sen.y; oAL=ALARM_LAST;
       say=function(m,k,o){ said.push({m:String(m),o:o||null}); };
       sen.x=p.x+120; sen.y=p.y;
       ALARM_LAST=-99; said=[]; alarmOk(sen.x,sen.y);
       s=said.map(function(r){ return r.m; }).join(' | ');
       if(!/^SENTRY ALERT$/.test(s)) bad.push('a sentry raises the alarm and the line reads '+JSON.stringify(s));
       oEnts=g.ents; g.ents=[];
       ALARM_LAST=-99; said=[]; alarmOk(p.x,p.y);
       if(said.length) bad.push('with no machine near the alarm still says '+JSON.stringify(said[0].m));
       g.ents=oEnts; oEnts=null;
       // THREE: locked on names the machine; one kind in a crowd counts in the plural
       if(machSightSub(sen,1)!=='SENTRY HAS YOU IN SIGHT') bad.push('locked on reads '+JSON.stringify(machSightSub(sen,1)));
       if(machSightSub({kind:'warden',boss:1},1)!=='OVERSEER HAS YOU IN SIGHT') bad.push('locked on by the Overseer reads '+JSON.stringify(machSightSub({kind:'warden',boss:1},1)));
       var s2={kind:'sentry',hp:1,sirenOn:1}, c2={kind:'crawler',hp:1,sirenOn:1};
       oEnts=g.ents; g.ents=[sen,s2]; sen.sirenOn=1;
       if(machSightSub(sen,2)!=='2 SENTRIES HAVE YOU IN SIGHT') bad.push('two sentries read '+JSON.stringify(machSightSub(sen,2)));
       g.ents=[sen,c2];
       if(machSightSub(sen,2)!=='SENTRY +1 HAVE YOU IN SIGHT') bad.push('a sentry and a crawler read '+JSON.stringify(machSightSub(sen,2)));
       g.ents=oEnts; oEnts=null; sen.sirenOn=0;
       // FOUR: the board title and the goals say pillager on screen
       if(MA(machSightSub(sen,1))||WB(machSightSub(sen,1))) bad.push('the sight line still says machine');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=oSay; CAREER_ON=c0;
       try{ var g2=__state(); if(oEnts&&g2) g2.ents=oEnts; if(sen){ sen.x=ox; sen.y=oy; sen.sirenOn=0; } if(oAL!==undefined) ALARM_LAST=oAL; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
