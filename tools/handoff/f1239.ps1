$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.39 CHECK, inserted before the v12.38 entry. Two guns no starter roll, no
# shop stock and no freebie kit can hand out, so the staging cannot be mistaken
# for anything the game does on its own. He dies carrying the second one, and
# the check then reads the profile slot and the last screen before the lift.
# The control puts the gun back in the armoury and requires that same screen to
# name it again, so a pass cannot come from a page that names nothing.
SubRx @'
  {v:'12.38',what:'extracting with a gun in each hand leaves a gun in each hand: banking the better one into gun 1 no longer leaves gun 2 naming the same gun, so the ascent check does not print it twice and the next raid still comes up with a second gun (2026-09-07 audit, gun-slot-reconcile)',
'@ @'
  {v:'12.39',what:'a death that takes the sidearm empties gun slot 2, and the ascent check stops naming a gun that is no longer in the armoury (2026-09-07 audit, dead-slot2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__runPrep&&window.__topClear&&window.__cleanProfile&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(!window.__renderStage) return 'SKIP: this fixture cannot render the ascent check';
     if(!document.getElementById('stagemodal')||!document.getElementById('stagesum')) return 'SKIP: this build has no ascent check summary line';
     if(!(WEAPONS&&WEAPONS.sniper&&WEAPONS.lance)) return 'SKIP: this build has no Longshot and no Meridian Lance to stage';
     var bad=[], P2=__P();
     // Assembled, never written whole, so a check that greps the page for the
     // empty-slot line cannot find it in this checks own source.
     var NONE2='no second '+'gun';
     var keep={weapons:(P2.weapons||[]).slice(),eq:P2.equipped,eq2:P2.equippedSec,
       stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),drop:(P2.dropKit||[]).slice(),
       hot:JSON.parse(JSON.stringify(P2.hotAssign||{})),wear:JSON.parse(JSON.stringify(P2.wear||{})),
       kills:JSON.parse(JSON.stringify(P2.kills||{})),chosen:P2.kitChosen,freeKit:P2.freeKit,
       kbf:P2.kitBeforeFree,kitSaved:P2.kitSaved,gunSlot:P2._gunSlot,
       merc:P2.merc,mapIx:P2.mapIx,runs:P2.runs,died:P2.died,ext:P2.ext,credits:P2.credits,
       xp:P2.xp,best:P2.best,notExt:P2.notExt};
     function sumText(){ var e=document.getElementById('stagesum'); return ((e&&e.textContent)||'').replace(/\s+/g,' '); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       P2=__P();
       // DISTINCTIVE: two guns no starter roll, no shop stock and no freebie kit can hand you.
       P2.weapons=['sniper','lance']; P2.equipped='sniper'; P2.equippedSec='lance';
       P2.wear={}; P2.merc=null;
       P2.kitBeforeFree=null; P2.kitSaved=null; P2._gunSlot=null;
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g) return 'staging: no raid to die in';
       var p=g.player;
       if(!p.sec||p.sec.id!=='lance') return 'staging: gun 2 went up as '+((p.sec&&p.sec.id)||'nothing')+' and not the Meridian Lance';
       if(!p.secFromArmory) return 'staging: gun 2 is not flagged as out of the armoury, so a death would not take it';
       g.bag.length=0; p.downed=false; g.over=false;
       __endRaid('dead');
       __topClear();
       P2=__P();
       var own=P2.weapons||[];
       if(own.indexOf('lance')>=0) return 'staging: the Meridian Lance survived the death, so there is nothing here to measure';
       if(P2.freeKit) return 'staging: the profile came out of the death on the freebie kit, which prints its own line';
       // THE FINDING, part one: the slot still points at the gun that died with him.
       var s2=P2.equippedSec;
       if(s2&&s2!=='none'&&s2!=='fists'&&own.indexOf(s2)<0)
         bad.push('after dying with it, gun slot 2 still names the '+((WEAPONS[s2]&&WEAPONS[s2].name)||s2)+', which is no longer in the armoury');
       // THE FINDING, part two: and the last screen before the lift tells him it is coming up.
       try{ __renderStage(); }catch(_r){ bad.push('the ascent check threw after the death: '+_r); }
       var txt=sumText();
       if(txt.indexOf('Meridian Lance')>=0)
         bad.push('the ascent check sends him up with a Meridian Lance he lost with his body ['+txt+']');
       if(txt.indexOf(NONE2)<0)
         bad.push('the ascent check does not say '+NONE2+' after the sidearm was lost ['+txt+']');
       // CONTROL: put the gun back in the armoury and the same page must name it again.
       P2.weapons=['sniper','lance']; P2.equipped='sniper'; P2.equippedSec='lance';
       try{ __renderStage(); }catch(_r2){ bad.push('control: the ascent check threw: '+_r2); }
       var ctl=sumText();
       if(ctl.indexOf('Meridian Lance')<0)
         bad.push('control: with the Meridian Lance back in the armoury the ascent check no longer names it as gun 2 ['+ctl+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz&&!gz.over){ gz.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ var sm=document.getElementById('stagemodal'); if(sm) sm.classList.remove('on');
            var sp=document.getElementById('stageplan'); if(sp) sp.innerHTML='';
            var sv=document.getElementById('stagesum'); if(sv) sv.innerHTML=''; }catch(_s){}
       try{ var Pz=__P();
         Pz.weapons=keep.weapons; Pz.equipped=keep.eq; Pz.equippedSec=keep.eq2;
         Pz.stash=keep.stash; Pz.kit=keep.kit; Pz.dropKit=keep.drop; Pz.hotAssign=keep.hot;
         Pz.wear=keep.wear; Pz.kills=keep.kills; Pz.kitChosen=keep.chosen; Pz.freeKit=keep.freeKit;
         Pz.kitBeforeFree=keep.kbf; Pz.kitSaved=keep.kitSaved; Pz._gunSlot=keep.gunSlot;
         Pz.merc=keep.merc; Pz.mapIx=keep.mapIx;
         Pz.runs=keep.runs; Pz.died=keep.died; Pz.ext=keep.ext; Pz.credits=keep.credits;
         Pz.xp=keep.xp; Pz.best=keep.best; Pz.notExt=keep.notExt;
         saveProfile(); }catch(_p){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.38',what:'extracting with a gun in each hand leaves a gun in each hand: banking the better one into gun 1 no longer leaves gun 2 naming the same gun, so the ascent check does not print it twice and the next raid still comes up with a second gun (2026-09-07 audit, gun-slot-reconcile)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
