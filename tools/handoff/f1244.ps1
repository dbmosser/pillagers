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

# v12.44 CHECK, inserted before the v12.43 entry. The ship is landed by running
# the real extraction ticker one step past the end of the beacon, which is the
# only code that creates a boarding window, with two seconds on a live raid
# clock. It reads the number the window holds AND the words on the ring badge,
# because the badge is what he actually reads. Two controls: a full clock must
# still give the ordinary thirty second window, and a raid with the clock
# switched off must still give thirty, which is the v12.24 rule and is what the
# guard on this clamp protects.
SubRx @'
  {v:'12.43',what:'holding the sprint key while aiming, or while wading, lays no scent behind a man who is not sprinting, so nothing hunts him along a trail he never made; a plain sprint on dry land still lays one (2026-09-07 audit)',
'@ @'
  {v:'12.44',what:'the boarding window never outlives the raid clock: a ship landing with two seconds left announces what the raid actually has and not the three second floor, on the number and on the ring badge alike, while a full clock and a raid with the clock switched off both still give the ordinary thirty seconds (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof tickExtractPoints!=='function'||typeof zoneBadge!=='function') return 'SKIP: this build has no extraction ticker or ring badge to read';
     var bad=[];
     // Land a ship on a ring with a chosen amount of raid clock left, by running
     // the real ticker one step past the end of the beacon. Returns the window
     // it created and the words the ring badge prints for it.
     function land(left,clockOn){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||!g.zones||!g.zones.length) return null;
       var z=g.active||g.zones[0], p=g.player;
       CFG.raidSec=clockOn?540:0;
       g.active=z; z.open=true; z.hold=null; z.holdMax=null; z.boardT=0; z.pullT=null;
       z.beaconT=0.001; g.beaconT=z.beaconT;
       g.timeLeft=left;
       p.downed=false; p.iv=99; p.x=z.x; p.y=z.y;
       tickExtractPoints(0.01);
       if(z.hold===null||z.hold===undefined) return {none:1};
       return {hold:z.hold,left:g.timeLeft,badge:String(zoneBadge(z)||'')};
     }
     function badgeSeconds(txt){
       var m=/([0-9]+)S UNTIL EXTRACTION ENDS/.exec(txt);
       return m?(+m[1]):null;
     }
     try{
       // THE FINDING: the ship lands with two seconds of raid left.
       var A=land(2.0,true);
       if(!A) return 'SKIP: no raid with an extraction point to land a ship on';
       if(A.none) return 'SKIP: one step past the end of the beacon opened no boarding window, so there is nothing to read here';
       if(A.hold>A.left+0.001)
         bad.push('the boarding window says '+A.hold+' seconds with only '+A.left+' left on the raid clock, so the timer kills him with the countdown still running');
       var sec=badgeSeconds(A.badge);
       if(sec===null) bad.push('control: the ring badge did not print a seconds figure at all ['+A.badge+'], so what he reads cannot be checked here');
       else if(sec>Math.max(0,Math.ceil(A.left)))
         bad.push('the ring badge reads "'+A.badge+'" with '+A.left+' seconds of raid left, so every readout he has is promising him time the raid does not have');
       if(!(A.hold>0)) bad.push('the boarding window came out at '+A.hold+', which reads as no window at all');
       // CONTROL ONE: a full clock still gives the ordinary thirty seconds.
       var B=land(540,true);
       if(B&&!B.none&&B.hold!==30) bad.push('control: with a full raid clock the boarding window is '+B.hold+' and not the ordinary 30, so the clamp has changed a normal extraction');
       // CONTROL TWO: with the clock switched off it is still thirty, which is
       // the v12.24 rule and the reason this clamp is guarded at all.
       var C=land(0,false);
       if(C&&!C.none&&C.hold!==30) bad.push('control: with the raid clock switched off the boarding window is '+C.hold+' and not 30, so the v12.24 rule has been undone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz&&!gz.over){ gz.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.43',what:'holding the sprint key while aiming, or while wading, lays no scent behind a man who is not sprinting, so nothing hunts him along a trail he never made; a plain sprint on dry land still lays one (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
