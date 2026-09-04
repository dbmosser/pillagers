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

SubRx @'
  {v:'11.06',what:'the 23 jersey reads as a jersey
'@ @'
  {v:'11.07',what:'a crawler close enough to bite you has found you, however well hidden you are',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents)) return 'SKIP: this fixture cannot step the machines';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, craw=null, i;
     for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ craw=g.ents[i]; break; }
     if(!craw) return 'SKIP: no crawler on this map to test';
     g.ents.length=0; g.ents.push(craw);
     p.hp=100000; p.maxhp=100000; p.downed=false;
     // HIS CASE, EXACTLY: standing still, well hidden, with one of them right
     // next to him. The crawler is pinned where it starts so this measures the
     // BITE and not the walk, and the player is pinned so nothing drifts out of
     // reach while the clock runs.
     var REACH=(craw.r+(p.r||11))+10;      // its own reach, from the entity
     function run(pcon,gap,frames){
       craw.x=p.x+gap; craw.y=p.y; craw.hp=craw.maxhp; craw.cd=0; craw.alert=0;
       craw.state='patrol'; craw.face=Math.PI;
       var hp0=p.hp, px=p.x, py=p.y, states={};
       for(var f=0;f<frames;f++){
         g.pConceal=pcon;
         __ents(0.05);
         states[craw.state]=(states[craw.state]||0)+1;
         craw.x=px+gap; craw.y=py; p.x=px; p.y=py;
       }
       return {dmg:hp0-p.hp,states:states};
     }
     // 1. THE FINDING. Measured on v11.06 at 30 units, which is inside a reach of
     //    36: 65 damage at concealment 0.35 and ZERO at 0.25 and below, sitting
     //    in patrol for the whole three seconds.
     var near=Math.round(REACH*0.85);
     var hidden=run(0.05,near,60);
     if(hidden.dmg<=0)
       bad.push('a crawler '+near+' units away, with a reach of '+REACH+', did nothing at all in three seconds while he stood still and hidden, which is his note');
     // 2. AND IT IS THE TOUCH THAT FOUND HIM, NOT BLANKET SIGHT. The same
     //    concealment at twice the reach must still hide him, or this fix has
     //    quietly made hiding useless.
     var far=Math.round(REACH*2.2);
     var farHid=run(0.05,far,60);
     if(farHid.dmg>0)
       bad.push('control: the same hidden man is attacked from '+far+' units, well outside a reach of '+REACH+', so concealment has stopped meaning anything');
     // 3. AND THE OPEN CASE IS UNTOUCHED. Standing in plain view has always
     //    worked and must still.
     var open=run(1,near,60);
     if(open.dmg<=0) bad.push('control: a crawler does not bite a man standing in plain view either, so this check is measuring the wrong thing');
     // 4. AND THE DIAL PUTS IT BACK, which is how the old behaviour stays
     //    measurable rather than being deleted.
     if(typeof __cfg==='function'){
       __cfg({touchSees:0});
       var off=run(0.05,near,60);
       __cfg({touchSees:1});
       if(off.dmg>0) bad.push('control: turning touchSees off changes nothing, so the fix is not the thing being tested');
       var back=run(0.05,near,60);
       if(back.dmg<=0) bad.push('control: turning touchSees back on did not restore the bite');
     }
     __resetCfg(); __pinDefaults(0);
     return bad.length?bad.join('; '):null; }},
  {v:'11.06',what:'the 23 jersey reads as a jersey
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
