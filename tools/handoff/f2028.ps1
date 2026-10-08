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

if ($s.Contains("  {v:'20.28',what:")) { throw "check 20.28 is in the fixture already" }

SubRx @'
  {v:'20.27',what:
'@ @'
  {v:'20.28',what:'a man sent after a new target searches there: one with a search point from an old chase builds a new one when he is sent after a spot far away, and keeps it for the same spot',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof searchSector!=='function') return 'SKIP: no search sectors here';
     var bad=[], g, e=null, i, s1x, s1y, s2x;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: no pillager';
       delete e.searchX; delete e.searchY; delete e.searchArc; delete e.searchFx; delete e.searchFy;
       e.tx=e.x+300; e.ty=e.y; searchSector(e); s1x=e.searchX; s1y=e.searchY;
       if(s1x===undefined) return 'SKIP: no search point was built';
       searchSector(e);
       if(e.searchX!==s1x||e.searchY!==s1y) bad.push('the same target rebuilt the search point');
       e.tx=e.x-600; e.ty=e.y+400; searchSector(e); s2x=e.searchX;
       if(s2x===s1x&&e.searchY===s1y) bad.push('a new target 700 units away kept the old search point');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
