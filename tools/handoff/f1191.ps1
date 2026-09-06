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

# v11.91 CHECK, inserted before the v11.90 entry. Two halves of one note: a
# belt key holding a bagged gun is pressed through setHot and the gun must
# come up; then a derived Medical cell is pressed through the real canvas
# mousedown and must start a drag carrying the bandage it shows.
SubRx @'
  {v:'11.90',what:'with the backpack open, the gun in your hands can be dragged off its belt cell and dropped into the bag; bare hands come up (his note of 2026-09-06)',
'@ @'
  {v:'11.91',what:'a belt key holding a gun from the backpack equips it into your hands, and a derived belt cell (Medical, plate, grenade) can be dragged to another key (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__runPrep)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof setHot!=='function'||typeof hotbarSlots!=='function'||typeof cv==='undefined'||typeof mouse==='undefined') return 'SKIP: no belt in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], g=null, k, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); var p=g.player;
       // ONE: the key equips the bagged gun.
       var pistol={}; for(k in WEAPONS.pistol) pistol[k]=WEAPONS.pistol[k]; pistol.q='field'; pistol.qRank=1;
       p.wep=pistol; p.ammo=8; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; p.swapped=false; p.downed=false; p.roll=0;
       g.bag=['gun_smg']; g.hotAssign={3:'gun_smg'}; g.hot=0; g.paused=false;
       setHot(3);
       if(!p.wep||p.wep.id!=='smg') bad.push('key 4 showed the SMG but left '+(p.wep&&p.wep.id)+' in hand');
       if(g.bag.indexOf('gun_smg')>=0) bad.push('the SMG is still in the backpack after the key');
       // TWO: a derived cell drags.
       g.bag=['bandage']; g.hotAssign={}; g.bagOpen=true; g.drag=null; g.mapOpen=false;
       __frame(0.016); __frame(0.016);
       var sl=hotbarSlots(), hi=-1;
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='heal'&&!sl[i].assigned){ hi=i; break; }
       var cell=(hi>=0&&g.hotCells)?g.hotCells[hi]:null;
       if(!cell) bad.push('control: the belt drew no Medical cell to press');
       else {
         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         if(!g.drag||g.drag.key!=='bandage') bad.push('pressing on the derived Medical cell started no drag'+(g.drag?' (drag: '+JSON.stringify(g.drag).slice(0,60)+')':''));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(g){ g.bagOpen=false; g.drag=null; } mouse.down=false; }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.90',what:'with the backpack open, the gun in your hands can be dragged off its belt cell and dropped into the bag; bare hands come up (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
