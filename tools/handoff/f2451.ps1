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

if ($s.Contains("  {v:'24.51',what:")) { throw "check 24.51 is in the fixture already" }

SubRx @'
  {v:'24.50',what:
'@ @'
  {v:'24.51',what:'his answer 34 b: a pillager whose round lands on you taunts you with a hurt line, through the one-at-a-time taunt gate; a machine round draws no taunt',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateBullets!=='function'||typeof taunt!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, R=null, S=null, i, calls=[], rt=taunt, own=false, kp=null, ks=null;
     function shot(o){ G.bullets.length=0; G.bullets.push({x:p.x,y:p.y,vx:0.01,vy:0,dmg:1,life:0.5,player:false,owner:o,tint:'#ffffff',thru:0}); updateBullets(0.001); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(!e||!(e.hp>0)) continue; if(!R&&e.kind==='raider'&&!e.merc) R=e; if(!S&&e.kind==='sentry') S=e; }
       if(!R) return 'SKIP: no pillager on this map';
       kp={x:R.x,y:R.y}; R.x=p.x+220; R.y=p.y;
       if(S){ ks={x:S.x,y:S.y}; S.x=p.x-220; S.y=p.y; }
       taunt=function(e,k){ calls.push((e&&e.kind)+':'+k); return rt.apply(this,arguments); }; own=true;
       p.iv=0; p.hp=100; p.downed=false; g.tauntAt=-99;
       shot(R);
       if(calls.indexOf('raider:hurt')<0) bad.push('a pillager round that hit him drew no hurt taunt ('+(calls.join(',')||'none')+')');
       if(!(g.tauntAt===g.t)) bad.push('the hurt taunt did not take the taunt gate (tauntAt '+g.tauntAt+', t '+g.t+')');
       var n0=calls.length; p.iv=0; p.hp=100; shot(R);
       var gated=(g.tauntAt===g.t);
       if(S){ calls.length=0; p.iv=0; p.hp=100; g.tauntAt=-99; shot(S); if(calls.some(function(c){ return c.indexOf(':hurt')>0; })) bad.push('a machine round drew a taunt ('+calls.join(',')+')'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) taunt=rt; try{ if(R&&kp){ R.x=kp.x; R.y=kp.y; } if(S&&ks){ S.x=ks.x; S.y=ks.y; } var g2=__state(); if(g2&&!g2.over){ g2.bullets.length=0; g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
