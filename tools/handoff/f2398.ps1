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

if ($s.Contains("  {v:'23.98',what:")) { throw "check 23.98 is in the fixture already" }

SubRx @'
  {v:'23.97',what:
'@ @'
  {v:'23.98',what:'gfx30, his order 2026-10-12 (the graphics program, item 13, bigger explosions): a frag burst records one explosion with 8 or more pieces of debris, its baked fireball is drawn at +0.1 s and its baked smoke at +1.5 s, it is gone by +5 s, and a bot raid records none',
   run:function(){
     var bad=[], g=null, p, hp0, t0=null, b, m, nF, nS, n0, sim0=false, simSet=false;
     var cnt=function(img){ var c=0, orig=wc.drawImage; wc.drawImage=function(im){ if(im===img) c++; return orig.apply(wc,arguments); }; try{ __frame(0.016); } finally { delete wc.drawImage; } return c; };
     try{
       if(!(window.__gfxStage&&window.__frame&&window.__state&&window.__endRaid)) return 'SKIP: this fixture has no gfx stage';
       g=__gfxStage({frames:2});
       if(!g) return 'SKIP: __gfxStage built no raid';
       if(g.sim) return 'SKIP: the staged raid is a sim raid';
       if(typeof BOOMS==='undefined'||typeof gfxESprites!=='function') return 'no explosion module: no BOOMS list';
       GFX.bypass=0; G.shake=0; p=g.player; hp0=p.hp; t0=G.t;
       BOOMS.length=0;
       explodeFrag({x:p.x+260,y:p.y+30,by:{name:'ZQX',kind:'raider'}});
       p.hp=hp0;
       if(BOOMS.length!==1) bad.push('one frag burst recorded '+BOOMS.length+' explosions');
       b=BOOMS[BOOMS.length-1];
       if(b&&!(b.deb&&b.deb.length>=8)) bad.push('the burst threw '+(b.deb?b.deb.length:0)+' pieces of debris');
       m=gfxESprites();
       G.t=t0+0.1; nF=cnt(m.fire);
       if(!(nF>=1)) bad.push('the fireball sprite was drawn '+nF+' times at +0.1 s');
       G.t=t0+1.5; nS=cnt(m.smoke);
       if(!(nS>=1)) bad.push('the smoke sprite was drawn '+nS+' times at +1.5 s');
       if(cnt(m.fire)!==0) bad.push('the fireball still burns at +1.5 s');
       G.t=t0+5; cnt(m.smoke);
       if(BOOMS.length!==0) bad.push(BOOMS.length+' explosions left at +5 s');
       G.t=t0;
       n0=BOOMS.length; sim0=G.sim; G.sim=true; simSet=true;
       boomFx(p.x,p.y,1,'frag');
       G.sim=sim0; simSet=false;
       if(BOOMS.length!==n0) bad.push('a bot raid recorded an explosion');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(simSet) G.sim=sim0; }catch(_ss){}
       try{ if(t0!==null&&G) G.t=t0; }catch(_tt){}
       try{ if(typeof BOOMS!=='undefined') BOOMS.length=0; }catch(_bl){}
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over&&!g2.sim) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
