$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.58 CHECK, inserted before the v11.57 entry. The ring rule is driven
# directly (noiseMark) for an unseen and a seen source, and the four call
# sites are read off their functions.
SubRx @'
  {v:'11.57',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',
'@ @'
  {v:'11.58',what:'the extraction inbound pulse, touchdown and last call and the storm telegraph draw the heard-not-seen noise ring like every other sound (his note of 2026-09-05): ring sizes exist, an unseen source rings and a seen one does not, and the four call sites are positioned',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof noiseMark!=='function'||typeof NOISEMARK==='undefined') return 'SKIP: no noise rings in this build';
     var bad=[], need=['inbound','touchdown','lastcall'];
     for(var i=0;i<need.length;i++) if(!NOISEMARK[need[i]]) bad.push('the '+need[i]+' sound has no ring size, so it can never mark itself');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.noiseRings=[]; p.face=0;   // facing +x
       if(NOISEMARK.inbound){
         // BEHIND the player, within earshot: heard, not seen, so it rings.
         noiseMark('inbound',p.x-400,p.y);
         var n1=(g.noiseRings||[]).length;
         if(n1<1) bad.push('an inbound pulse 400 units behind the player drew no ring');
         // IN FRONT, close, in the open: seen, so no ring (the game own eyes rule).
         g.noiseRings=[];
         noiseMark('inbound',p.x+60,p.y);
         if((g.noiseRings||[]).length>0&&canSee(p.x,p.y,p.face,p.x+60,p.y,g.vseg)) bad.push('control: a seen source 60 units ahead drew a ring');
       }
       var s1='', s2='';
       try{ s1=strikeTick.toString(); s2=tickExtractPoints.toString(); }catch(_s){}
       var sfxc=['sfx(',"'charge'"].join(''), sfxi=['sfx(',"'inbound'"].join(''), sfxt=['sfx(',"'touchdown'"].join(''), sfxl=['sfx(',"'lastcall'"].join('');
       if(s1.indexOf(sfxc)<0) bad.push('the storm telegraph is still played by distance alone, with no position to ring at');
       if(s2.indexOf(sfxi)<0) bad.push('the inbound pulse is still played by distance alone');
       if(s2.indexOf(sfxt)<0) bad.push('the touchdown is still played by distance alone');
       if(s2.indexOf(sfxl)<0) bad.push('the last call is still played by distance alone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g3=__state(); if(g3) g3.noiseRings=[]; }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.57',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
