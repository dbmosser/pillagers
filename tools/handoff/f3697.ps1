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

if ($s.Contains("  {v:'36.97',what:")) { throw "check 36.97 is in the fixture already" }

SubRx @'
  {v:'36.96',what:
'@ @'
  {v:'36.97',what:'his order 10-31: a Forge upgrade raises no weapon card (G.gunCard stays null); the card still shows when the mouse rests on the gun on the hotbar',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof forgeOpen!=='function'||typeof beltHoverHud!=='function'||typeof hotbarSlots!=='function'||typeof beltHovGun!=='function') return 'SKIP: no raid or hotbar here';
     var keep=JSON.stringify(P), mine=ARCADE.mine, g=null, p=null, i, c=null, S, box, mx, my;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player) return 'no live raid';
       p=g.player; g.ents=[]; P.credits=10000; g.cs={s:0,k:0,b:{}}; ARCADE.mine=0; g.gunCard=null;
       p.wep=Object.assign({},WEAPONS.rifle); p.downed=false;
       if(!forgeOpen()||g.forgeUI||p.wep.fk!==1) return 'the MK II purchase did not go through';
       if(g.gunCard) return 'a forge upgrade popped the weapon card';
       __frame(0); __frame(0);
       if(g.gunCard) return 'a forge upgrade popped the weapon card after a frame';
       S=hotbarSlots();
       for(i=0;i<(g.hotCells||[]).length;i++){ if(S[g.hotCells[i].i]&&beltHovGun(S[g.hotCells[i].i])){ c=g.hotCells[i]; break; } }
       if(!c) return 'no gun key on the hotbar';
       mx=mouse.x; my=mouse.y; mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; mouse.down=false;
       BELTHOV.i=-1; beltHoverHud(); BELTHOV.at-=5; box=beltHoverHud();
       mouse.x=mx; mouse.y=my;
       if(!box||box.kind!=='gun') return 'resting the mouse on the gun on the hotbar shows no weapon card';
       return null;
     } finally {
       try{ if(typeof BELTHOV!=='undefined'){ BELTHOV.box=null; BELTHOV.i=-1; } }catch(_b){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       ARCADE.mine=mine; __topClear(); __applyLoaded(JSON.parse(keep)); saveProfile();
     } }},
  {v:'36.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
