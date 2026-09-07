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

# v12.23 CHECK, inserted before the v12.22 entry. A frag is cooked for half a
# second and a real hit puts him down; the grenade must leave his hand as one
# throw carrying that half second, nothing may be left cooking, the frame and
# the HUD may not paint a COOKING clock over him, and the self-revive must
# stand him up empty-handed. Control: the same hit with nothing in hand throws
# nothing.
SubRx @'
  {v:'12.22',what:'P resumes a paused raid as the pause box legend says: opening the box no longer hands the keyboard to its note, and while the box is up no other key reaches the raid (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.23',what:'going down lets go of a cooking grenade: the throw leaves the hand with the fuse it has burned, no COOKING clock is painted over the man on the floor, and the self-revive does not stand him up holding a live cook (2026-09-06 in-raid audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace&&window.__frame)) return 'SKIP: this fixture cannot deploy and trace';
     if(typeof damagePlayer!=='function'||typeof startCook!=='function'||typeof selfRevive!=='function'||typeof drawHUD!=='function'||typeof THROWKEYS==='undefined') return 'SKIP: no cook, down or HUD path in this build';
     var bad=[], word='COOK'+'ING';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, en=null;
       for(var i=0;i<g.ents.length&&!en;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed) en=g.ents[i];
       // A frag in the pouch and selected, the aim 200 units east; the pin comes out and half a second burns.
       g.pouch.frag=(g.pouch.frag||0)+1; g.tsel=THROWKEYS.indexOf('frag');
       p.downed=false; p.revived=false; p.roll=0; p.iv=0; p.armor=0; p.hp=5; p.cooking=0; p.cookT=0; p.cookKind=null;
       mouse.x=innerWidth/2+200; mouse.y=innerHeight/2;
       var before=g.throws.length;
       if(!startCook()) bad.push('control: the pin did not come out');
       p.cookT=0.5;
       if(!p.cooking) bad.push('control: nothing is cooking');
       damagePlayer(40,en,en?en.kind:'crawler',p.x+20,p.y);
       if(!p.downed) bad.push('control: the hit did not put him down (hp '+p.hp+')');
       if(p.cooking) bad.push('he went down still holding a live cook (cookT '+p.cookT+')');
       var th=g.throws.slice(before);
       if(th.length!==1) bad.push('the grenade did not leave his hand: '+th.length+' throws left it (wanted 1)');
       else{
         if(th[0].kind!=='frag') bad.push('what left his hand was a '+th[0].kind);
         if(Math.abs((th[0].cook||0)-0.5)>0.01) bad.push('the throw forgot the fuse it had burned (cook '+th[0].cook+')');
       }
       var tr=__textTrace(function(){ __frame(0.016); drawHUD(); });
       if(tr.some(function(r){ return r.t.indexOf(word)===0; })) bad.push('a '+word+' clock is still painted over a man on the floor');
       // The one self-revive brings him up empty-handed.
       if(!selfRevive()) bad.push('control: the self-revive was refused');
       if(p.cooking) bad.push('he got up holding the cook he went down with');
       // CONTROL: the same hit with nothing in hand throws nothing.
       p.downed=false; p.revived=false; p.hp=5; p.iv=0; p.roll=0; p.cooking=0; p.cookT=0; p.cookKind=null;
       var before2=g.throws.length;
       damagePlayer(40,en,en?en.kind:'crawler',p.x+20,p.y);
       if(!p.downed) bad.push('control: the second hit did not put him down');
       if(g.throws.length!==before2) bad.push('control: a hit with nothing in hand threw something');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2){ var p2=g2.player; p2.cooking=0; p2.cookT=0; p2.cookKind=null; p2.downed=false; p2.hp=100; g2.throws.length=0; if(!g2.over) __endRaid('extract'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.22',what:'P resumes a paused raid as the pause box legend says: opening the box no longer hands the keyboard to its note, and while the box is up no other key reaches the raid (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
