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

if ($s.Contains("  {v:'23.17',what:")) { throw "check 23.17 is in the fixture already" }

SubRx @'
  {v:'23.16',what:
'@ @'
  {v:'23.17',what:'a pillager going down out of sight prints no DOWNED label through the walls, while one he can see still does',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)||typeof canSee!=='function') return 'SKIP: this fixture cannot deploy and step';
     var bad=[], g, p, all, e, n0, said=function(){ return (g.labels||[]).filter(function(l){ return / DOWNED$/.test(String(l.txt)); }).length; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; all=g.ents.slice();
       e=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&x.hp>0; })[0];
       if(!e) return 'SKIP: no pillager on this map';
       g.ents=[e]; g.labels=[];
       e.x=p.x+4000; e.y=p.y+4000; e.hp=0; e.downed=0; e.finished=0;
       if(canSee(p.x,p.y,p.face,e.x,e.y,g.vseg)) return 'SKIP: the far spot is in sight';
       n0=said(); __ents(0.05);
       if(!e.downed) return 'SKIP: the pillager did not go down (raiderDown off?)';
       if(said()>n0) bad.push('a pillager going down 5600 units away behind walls printed '+(e.name||'PILLAGER')+' DOWNED');
       var srcs=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd="'PICKED UP','#ffc04a',0,true); }   // v23"+".17";
       if(srcs.indexOf(nd)<0) bad.push('a crew pick-up label still prints without asking canSee');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
