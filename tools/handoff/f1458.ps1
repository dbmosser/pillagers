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

SubRx @'
  {v:'14.57',what:
'@ @'
  {v:'14.58',what:'only a left click picks up a backpack tile, and B or I drops a held drag: a middle click on a staged tile starts no drag, a left click does, and closing the backpack with I mid-drag lets go of it (backpack audit finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function'||typeof mouse==='undefined'||typeof cv==='undefined'||!cv) return 'SKIP: no raid canvas or keys in this build';
     var bad=[], g0=null;
     var press=function(btn){ mouse.x=120; mouse.y=120; cv.dispatchEvent(new MouseEvent('mousedown',{button:btn,clientX:120,clientY:120,bubbles:true,cancelable:true})); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; p.iv=99; p.downed=false;
       var stage=function(){ g.bagOpen=true; g.drag=null; g.bagCells=[{x:100,y:100,w:40,h:40,key:'medkit',bagIx:0,stackIx:0}]; };
       // CONTROL: a left click on the tile picks it up.
       stage(); press(0);
       if(!g.drag) return 'SKIP: a left click on the staged tile did not pick it up here, so a pickup cannot be seen';
       // THE FIX: a middle click picks up nothing.
       stage(); press(1);
       if(g.drag) bad.push('a middle click picked up the tile, a drag only a left release can end');
       // AND B or I mid-drag lets go.
       stage(); g.drag={key:'medkit',bagIx:0};
       raidKey('KeyI',false,null);
       if(g.drag) bad.push('closing the backpack with I left the drag held, riding the reticle into the next shot');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ g0.bagOpen=false; g0.drag=null; g0.bagCells=null; if(g0.player) g0.player.iv=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; mouse.down=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
