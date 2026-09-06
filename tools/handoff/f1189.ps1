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

# v11.89 CHECK, inserted before the v11.88 entry. The real handlers: the
# shared mouse object is pointed at the cell and a real mousedown goes to the
# canvas; then at the open bag panel and a real mouseup goes to the window.
SubRx @'
  {v:'11.88',what:'the scorched cache a lightning strike leaves holds one Fulgurite worth 2500 and nothing else (his note of 2026-09-06)',
'@ @'
  {v:'11.89',what:'with the backpack open, the gun in your hands can be dragged off its belt cell and dropped into the bag; bare hands come up (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__runPrep)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof cv==='undefined'||typeof mouse==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: no canvas or mouse in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], g=null, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); var p=g.player;
       var smg={}; for(k in WEAPONS.smg) smg[k]=WEAPONS.smg[k]; smg.q='field'; smg.qRank=1;
       p.wep=smg; p.ammo=20; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; p.swapped=false; p.downed=false;
       g.bag=[]; g.bagOpen=true; g.drag=null; g.mapOpen=false;
       __frame(0.016); __frame(0.016);
       var cell=(g.hotCells||[])[0];
       if(!cell) return 'SKIP: the belt drew no cells';
       if(!g.bagPanel) bad.push('control: the open backpack drew no panel');
       mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
       if(!g.drag||g.drag.gunSlot!=='gunA') bad.push('pressing on the gun in slot 1 with the backpack open started no drag'+(g.drag?' (drag: '+JSON.stringify(g.drag).slice(0,60)+')':''));
       if(g.bagPanel){ mouse.x=g.bagPanel.x+g.bagPanel.w/2; mouse.y=g.bagPanel.y+g.bagPanel.h/2; }
       window.dispatchEvent(new MouseEvent('mouseup',{button:0}));
       if(g.bag.indexOf('gun_smg')<0) bad.push('the gun did not land in the backpack (bag '+g.bag.join(',')+')');
       if(!p.wep||p.wep.id!=='fists') bad.push('the hands still hold '+(p.wep&&p.wep.id));
       if(g.drag) bad.push('control: the drag was left hanging after the release');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(g){ g.bagOpen=false; g.drag=null; } mouse.down=false; }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.88',what:'the scorched cache a lightning strike leaves holds one Fulgurite worth 2500 and nothing else (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
