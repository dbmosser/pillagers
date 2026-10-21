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

if ($s.Contains("  {v:'33.31',what:")) { throw "check 33.31 is in the fixture already" }

SubRx @'
  {v:'33.30',what:
'@ @'
  {v:'33.31',what:'his order 10-20: looting a gun raises no stat card (G.gunCard stays null, nothing drawn); the gun card itself still draws for the belt hover and backpack',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof drawHUD!=='function'||typeof grantLoot!=='function'||typeof gunCardDraw!=='function'||typeof gunCompare!=='function') return 'SKIP: no raid or HUD here';
     if(!ITEMS.gun_lmg) return 'SKIP: no Support MG item';
     var bad=[], g=null, p=null, tr, cmp;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; g.gunCard=null;
       grantLoot({x:p.x,y:p.y,loot:[]},['gun_lmg']);
       if(g.gunCard) bad.push('looting a Support MG raised a stat card');
       tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} });
       if(tr.some(function(o){ return o.t==='HANDLING'; })) bad.push('a gun card was drawn after a pickup');
       cmp=gunCompare(WEAPONS.lmg,p.wep);
       tr=__textTrace(function(){ try{ gunCardDraw(cmp,900,700,1,'SLOT 2'); }catch(_d){} });
       if(!tr.some(function(o){ return o.t==='HANDLING'; })) bad.push('the gun card no longer draws for the belt hover and backpack');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.gunCard=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
