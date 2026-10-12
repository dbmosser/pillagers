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

if ($s.Contains("  {v:'23.80',what:")) { throw "check 23.80 is in the fixture already" }

SubRx @'
  {v:'23.79',what:
'@ @'
  {v:'23.80',what:'his #17 and answer 34: the backpack shows the gun stat card for the gun under the mouse, or the selected gun, against the gun in hand',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof drawHUD!=='function') return 'SKIP: no raid or HUD here';
     if(!ITEMS.gun_dmr||!ITEMS.bandage) return 'SKIP: no Marksman Rifle or Bandage item';
     var bad=[], g=null, p=null, mx0=mouse.x, my0=mouse.y, bag0=null, padOn0=(typeof PAD==='object'&&PAD)?PAD.on:null, tr, i, c=null;
     function has(t){ return tr.some(function(o){ return o.t===t; }); }
     function verdict(){ return tr.some(function(o){ return o.t==='UPGRADE'||o.t==='DOWNGRADE'||o.t==='SIDEGRADE'; }); }
     function draw(){ tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; if(padOn0!==null) PAD.on=false;
       bag0=g.bag.slice(); g.gunCard=null;
       mouse.x=-500; mouse.y=-500;
       g.bag=['gun_dmr']; g.bagOpen=true; g.mapOpen=false; g.bagSel=0; g.bagBelt=false;
       draw();
       if(!has('HANDLING')||!verdict()) bad.push('a selected gun in the backpack shows no stat card (no HANDLING or verdict drawn)');
       g.bag=['bandage']; g.bagSel=0;
       draw();
       if(has('HANDLING')) bad.push('a selected Bandage shows a gun stat card');
       g.bag=['bandage','gun_dmr']; g.bagSel=0;
       draw();
       for(i=0;i<(g.bagCells||[]).length;i++) if(g.bagCells[i].key==='gun_dmr') c=g.bagCells[i];
       if(!c) return bad.length?bad.join('; '):'SKIP: staging: the Marksman Rifle tile was not laid out';
       if(has('HANDLING')) bad.push('a gun card shows with the Bandage selected and nothing under the mouse');
       mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2;
       draw();
       if(!has('HANDLING')) bad.push('the mouse over a gun tile shows no stat card');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       mouse.x=mx0; mouse.y=my0; if(padOn0!==null) PAD.on=padOn0;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.bagOpen=false; if(bag0) g2.bag=bag0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
