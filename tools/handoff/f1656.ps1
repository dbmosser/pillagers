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

if ($s.Contains("  {v:'16.56',what:")) { throw "check 16.56 is in the fixture already" }

SubRx @'
  {v:'16.55',what:
'@ @'
  {v:'16.56',what:'a host who left the raid and is spectating has no body in it: an enemy round passes where he stood instead of stopping there',
   run:function(){
     if(typeof updateBullets!=='function'||typeof damagePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no rounds to test';
     var bad=[], p=null, own=null, oDP=damagePlayer, hits=0;
     function shot(){ G.bullets.length=0; G.bullets.push({x:p.x,y:p.y,vx:0.01,vy:0,dmg:5,life:0.5,player:false,owner:own,tint:'#ffffff',thru:0}); updateBullets(0.001); return G.bullets.length===0; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; own=G.ents[0]||null;
       if(!own) return 'SKIP: staging: no enemy to fire the round';
       damagePlayer=function(){ hits++; };
       p.specOut=1;
       if(shot()||hits) bad.push('a round stopped on the body of a host who left the raid ('+hits+' hits)');
       p.specOut=0; hits=0;
       if(!shot()||!hits) return 'SKIP: staging: a round on a player in the raid did not hit him, so this cannot measure a pass';
     } finally { damagePlayer=oDP; try{ if(p) p.specOut=0; G.bullets.length=0; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.55',what:
'@

# v16.54 retargeted three loaner needles; the sector page (13.31) and the card (13.34) still say Equip as your gun.
SubRx @'
     var needle=['Equip','your','own','gun'].join(' ');
     var idx=-1;
'@ @'
     var needle=['Equip','as','your','gun'].join(' ');
     var idx=-1;
'@
SubRx @'
     var needle=['Equip','your','own','gun'].join(' ');
     function boxText(){ try{ renderSector(); }catch(_s){} return String(K.textContent||''); }
'@ @'
     var needle=['Equip','as','your','gun'].join(' ');
     function boxText(){ try{ renderSector(); }catch(_s){} return String(K.textContent||''); }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
