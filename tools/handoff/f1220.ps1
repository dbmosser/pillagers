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

# v12.20 CHECK, inserted before the v12.19 entry. A Howler is put outside a
# building, alerted, with the player inside it and every other machine
# removed; one real entity step must add no mortar shell. Then the player
# is moved into the open beside it and one step must add one.
SubRx @'
  {v:'12.19',what:'the stash right-click menu takes the menu zoom like every window, so at 4K it is not a 1080p-sized menu under a 4K stash (his note of 2026-09-06)',
'@ @'
  {v:'12.20',what:'the Howler does not shell a target under a roof it is not itself under, and still shells one in the open (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy and step';
     if(typeof mkHowler!=='function'||typeof buildingAtPt!=='function') return 'SKIP: no Howler or building lookup in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, B=(g.map&&g.map.buildings)||[], b=null, i;
       for(i=0;i<B.length&&!b;i++) if(B[i].w>=120&&B[i].h>=120) b=B[i];
       if(!b) return 'SKIP: no building large enough to stand in';
       for(i=g.ents.length-1;i>=0;i--) g.ents.splice(i,1);   // only the Howler shoots in this room
       p.x=b.x+b.w/2; p.y=b.y+b.h/2; p.downed=false;
       var e=mkHowler(b.x-260,b.y+b.h/2); e.cd=0; e.alert=3; e.tx=p.x; e.ty=p.y; e.rng=2000; e.hearT=0; e.state='patrol'; g.ents.push(e);
       if(buildingAtPt(g.map,e.x,e.y)) return 'SKIP: the Howler could not be placed outside';
       var n0=g.shells.filter(function(s){ return s.mortar; }).length;
       __ents(0.1);
       var n1=g.shells.filter(function(s){ return s.mortar; }).length;
       if(n1>n0) bad.push('the Howler outside shelled the player under a roof ('+(n1-n0)+' shell'+((n1-n0)===1?'':'s')+')');
       // CONTROL: the same Howler shells the same player in the open.
       p.x=e.x+300; p.y=e.y; e.cd=0; e.alert=3; e.tx=p.x; e.ty=p.y;
       if(buildingAtPt(g.map,p.x,p.y)) bad.push('control: the open spot is under a roof');
       else {
         __ents(0.1);
         var n2=g.shells.filter(function(s){ return s.mortar; }).length;
         if(n2<=n1) bad.push('control: the Howler did not shell the player in the open');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.19',what:'the stash right-click menu takes the menu zoom like every window, so at 4K it is not a 1080p-sized menu under a 4K stash (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
