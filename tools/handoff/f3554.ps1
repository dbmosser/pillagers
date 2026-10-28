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

if ($s.Contains("  {v:'35.54',what:")) { throw "check 35.54 is in the fixture already" }

SubRx @'
  {v:'35.53',what:
'@ @'
  {v:'35.54',what:'downed hits use standing demo, kid and easy damage factors in both player roles and sim; normal career still costs 3 seconds',
   run:function(){
     var g=null, pf=null, saved=null, bad=[], i, sim, arc, easy, role;
     function near(a,b){ return Math.abs(a-b)<1e-6; }
     function hit(down){
       var p=g.player;
       p.iv=0; p.arcSh=0; p.armor=0; p.hp=100; p.downed=!!down; p.dying=false; p.specOut=false; p.downT=17;
       g.deathBeat=null;
       damagePlayer(8,'raider','pillager bot',p.x+100,p.y);
       return down?17-p.downT:100-p.hp;
     }
     function pair(label,want){
       var standing=hit(false), seconds=hit(true);
       if(!near(standing,8*want)) bad.push(label+' standing lost '+standing+', expected '+8*want);
       if(!near(seconds,3*want)) bad.push(label+' downed lost '+seconds+'s, expected '+3*want+'s');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       pf=__P(); saved={on:NET.on,role:NET.role,kid:NET.kidHost,own:pf.kidDmg,demo:ARCADE_DMG,easy:ARCADE.easy,dmg:CFG.eDmg};
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'no raid for downed damage check';
       g.ents.length=0; keys={}; mouse.down=false; pf.kidDmg=0.5; NET.kidHost=0.25; CFG.eDmg=1;
       for(sim=0;sim<2;sim++) for(role=0;role<3;role++) for(arc=0;arc<2;arc++) for(easy=0;easy<2;easy++){
         g.sim=sim; NET.on=role<2?1:0; NET.role=role===1?'join':'host'; g.netWasJoin=role===2;
         g.arcade=!!arc; g.easyC=!!easy; ARCADE.easy=easy;
         pair('sim '+sim+' role '+role+' demo '+arc+' easy '+easy,(role?0.25:1)*(arc?ARCADE_DMG:1)*(easy?EASY_MUL:1));
       }
       // v28.xx (cw-cx-downcuts): the live demo dial is 1 by unify1; probe half without changing the shipped default.
       g.sim=0; NET.on=1; NET.role='host'; g.netWasJoin=false; g.arcade=true; g.easyC=false; ARCADE.easy=0;
       ARCADE_DMG=0.5; pair('demo half hook',0.5);
       NET.role='join'; ARCADE.easy=1; pair('demo half plus kid plus easy',0.5*0.25*EASY_MUL);
       ARCADE_DMG=saved.demo; NET.on=0; g.netWasJoin=false; g.arcade=false; ARCADE.easy=0; g.easyC=false;
       CFG.eDmg=0.7; pair('forgiving damage setting',0.7);
       CFG.eDmg=1; pair('normal career control',1);
       return bad.length?bad.join('; '):null;
     } finally {
       if(g){ g.sim=0; g.arcade=false; g.netWasJoin=false; g.player.downed=false; g.player.hp=100; }
       if(saved){ NET.on=saved.on; NET.role=saved.role; NET.kidHost=saved.kid; pf.kidDmg=saved.own; ARCADE_DMG=saved.demo; ARCADE.easy=saved.easy; CFG.eDmg=saved.dmg; }
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'35.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
