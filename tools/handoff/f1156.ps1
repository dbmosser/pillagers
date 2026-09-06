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

# v11.56 CHECK, inserted before the v11.55 entry. The player stands in the
# middle of a building under a forced storm so the roll lands indoors often;
# the strike clock is forced to zero each call so every call spawns one point.
SubRx @'
  {v:'11.55',what:'a cooked frag shouts COOKED GRENADE! THROW GRENADE NOW for its last second in hand, nothing else in hand shouts, and the HUD draws the shout (his notes of 2026-09-05)',
'@ @'
  {v:'11.56',what:'no storm strike point lands inside a building (his note of 2026-09-05); the storm still strikes',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof strikeTick!=='function'||typeof buildingAtPt!=='function') return 'SKIP: no storm strikes in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, B=(g.map&&g.map.buildings)||[];
       if(!B.length) return 'SKIP: this map has no buildings to stand in';
       // wx() hands back G.wx itself, so the storm has to BE the weather.
       var storm=null;
       for(var wi=0;wi<WEATHER.length;wi++) if(WEATHER[wi].lightning){ storm=WEATHER[wi]; break; }
       if(!storm) return 'SKIP: no weather in this build carries lightning';
       g.wx=storm; g.wxNext=null; g.wxT=0;
       // Stand in the middle of the largest building, so rolls of 180 to 800 units land indoors often.
       var big=B[0]; for(var i=1;i<B.length;i++) if(B[i].w*B[i].h>big.w*big.h) big=B[i];
       p.x=big.x+big.w/2; p.y=big.y+big.h/2; p.downed=false; g.over=false; g.paused=false;
       var spawned=0, inside=0, sample=null;
       for(var k=0;k<60;k++){
         g.strikes=[]; g.strikeAt=0;
         strikeTick(0.05);
         for(var j=0;j<g.strikes.length;j++){
           spawned++;
           var S=g.strikes[j], bb=buildingAtPt(g.map,S.x,S.y);
           if(bb){ inside++; if(!sample) sample=Math.round(S.x)+','+Math.round(S.y); }
         }
       }
       if(spawned<20) bad.push('control: the storm spawned only '+spawned+' strike points in sixty tries, so nothing was measured');
       if(inside>0) bad.push(inside+' of '+spawned+' strike points landed inside a building (first at '+sample+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2){ g2.strikes=[]; g2.strikeAt=8; } }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.55',what:'a cooked frag shouts COOKED GRENADE! THROW GRENADE NOW for its last second in hand, nothing else in hand shouts, and the HUD draws the shout (his notes of 2026-09-05)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
