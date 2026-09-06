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

# v12.14 CHECK, inserted before the v12.13 entry. A raid is deployed and the
# player is hit to zero twice through the real damage path: first with the
# self-revive already spent, then fresh. The toast is read through the
# fixture's say capture.
SubRx @'
  {v:'12.13',what:'the sector map says EXTRACT NOW with the seconds left under a landed ring, the banner wording, instead of OPEN TO EXTRACT (2026-09-06 review of v11.74)',
'@ @'
  {v:'12.14',what:'the going-down toast tells the truth on the second down: it no longer sends you to F once the one self-revive is spent, and still does on the first (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof damagePlayer!=='function') return 'SKIP: no damagePlayer in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, en=null;
       for(var i=0;i<g.ents.length&&!en;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed) en=g.ents[i];
       // ARM ONE: the second down, the revive already spent.
       p.downed=false; p.revived=true; p.hp=5; p.armor=0; p.iv=0; window.__lastSay=null;
       damagePlayer(40,en,en?en.kind:'crawler',p.x+20,p.y);
       var s1=String(window.__lastSay||'');
       if(!p.downed) bad.push('control: the hit did not put him down (hp '+p.hp+')');
       if(/F to get back up/.test(s1)) bad.push('the second down still says F gets him up: "'+s1+'"');
       if(!/spent/.test(s1)) bad.push('the second down does not say the revive is spent: "'+s1+'"');
       // ARM TWO: the first down still points at F.
       p.downed=false; p.revived=false; p.hp=5; p.armor=0; p.iv=0; window.__lastSay=null;
       damagePlayer(40,en,en?en.kind:'crawler',p.x+20,p.y);
       var s2=String(window.__lastSay||'');
       if(!/F to get back up/.test(s2)) bad.push('control: the first down no longer says F gets him up: "'+s2+'"');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.hp=100; g2.player.revived=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.13',what:'the sector map says EXTRACT NOW with the seconds left under a landed ring, the banner wording, instead of OPEN TO EXTRACT (2026-09-06 review of v11.74)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
