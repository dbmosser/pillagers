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

# v11.53 CHECK, inserted before the v11.52 entry. Real frames through __loop,
# because the sprint decision lives in updatePlayer and reads the keys object.
SubRx @'
  {v:'11.52',what:'credits and XP are shown at all times in the upper right corner, in the Undercroft and in a raid, above the screens and clear of the CONDITIONS box, and the readout follows the profile when a figure changes',
'@ @'
  {v:'11.53',what:'holding Shift with movement while crouched leaves the crouch and sprints, a roll leaves the crouch, and walking without Shift keeps it (his notes of 2026-09-05)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keys&&window.__runPrep)) return 'SKIP: this fixture cannot drive the player';
     if(typeof tryRoll!=='function') return 'SKIP: no roll in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, K=__keys(), q;
       for(q in K) delete K[q];
       g.ents.length=0;   // nothing on the map to change the stance for us
       p.stam=100; p.stamLock=0; p.stamRelease=0; p.ads=false; p.downed=false; p.roll=0; p.rollCd=0;
       // ARM ONE: crouched, then Shift with W through four real frames.
       G.crouchTog=true;
       K['ShiftLeft']=true; K['KeyW']=true;
       var t0=performance.now();
       for(var f=0;f<4;f++) __loop(t0+f*16.7);
       if(G.crouchTog) bad.push('holding Shift with W while crouched left the crouch on');
       if(!G.sprinting) bad.push('holding Shift with W while crouched did not sprint (sprinting '+G.sprinting+', stamina '+Math.round(p.stam)+')');
       delete K['ShiftLeft']; delete K['KeyW'];
       // ARM TWO: crouched, then a roll.
       G.crouchTog=true; p.stam=100; p.roll=0; p.rollCd=0; p.downed=false;
       K['KeyW']=true; tryRoll(); delete K['KeyW'];
       if(!(p.roll>0)) bad.push('control: the roll did not start (roll '+p.roll+')');
       if(G.crouchTog) bad.push('rolling left the crouch on');
       // CONTROL: walking without Shift keeps the crouch.
       G.crouchTog=true; p.roll=0; p.rollCd=0; K['KeyW']=true;
       for(var f2=0;f2<4;f2++) __loop(t0+200+f2*16.7);
       delete K['KeyW'];
       if(!G.crouchTog) bad.push('control: walking without Shift cleared the crouch on its own');
       G.crouchTog=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){} try{ G.crouchTog=false; }catch(_g){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.52',what:'credits and XP are shown at all times in the upper right corner, in the Undercroft and in a raid, above the screens and clear of the CONDITIONS box, and the readout follows the profile when a figure changes',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
