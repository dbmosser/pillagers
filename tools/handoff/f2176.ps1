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

if ($s.Contains("  {v:'21.76',what:")) { throw "check 21.76 is in the fixture already" }

SubRx @'
  {v:'21.75',what:
'@ @'
  {v:'21.76',what:'his notes: a hit that lands closes the map and the backpack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof damagePlayer!=='function') return 'SKIP: no raid here';
     var bad=[], g, p;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       p.iv=0; p.hp=100; G.mapOpen=true; G.bagOpen=false;
       damagePlayer(5,'test','Test');
       if(G.mapOpen) bad.push('the map stays open after a hit');
       p.iv=0; p.hp=100; G.bagOpen=true; G.drag={key:'bandage',px:0,py:0};
       damagePlayer(5,'test','Test');
       if(G.bagOpen) bad.push('the backpack stays open after a hit');
       if(G.drag) bad.push('a drag survives the backpack closing');
       p.iv=5; p.hp=100; G.mapOpen=true;
       damagePlayer(5,'test','Test');
       if(!G.mapOpen) bad.push('a hit that did not land (invulnerable) still closed the map');
       G.mapOpen=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ G.mapOpen=false; G.bagOpen=false; G.drag=null; var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
