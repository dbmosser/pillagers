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

# v12.88 CHECK, inserted before the v12.87 entry.
#
# IT FEEDS THE PARSER A REPORT IT BUILDS IN THE EXPORT'S OWN FORMAT, because the
# bug is entirely in reading that format and there is no way to hand a real file
# to a file input from a script. The gun names are taken off the weapon table
# rather than typed, so a rename cannot make this check quietly stop testing
# anything: it picks the first two-word name the build actually has.
#
# THE ARM THAT FAILS ON v12.87 is the two-word gun coming back as itself. There
# the name is cut at the first space, the lookup misses, and the ghost is reported
# as an Auto Rifle.
SubRx @'
  {v:'12.87',what:'you come back down with an empty backpack and belt
'@ @'
  {v:'12.88',what:'a friend imported from a run report carries the gun they actually carried, even when its name has a space in it, and a report naming a gun this build does not have gets a ghost with no favourite claimed rather than a confident wrong one (audit finding 3, 2026-09-11)',
   run:function(){
     if(!(window.__ghost&&window.__ghost.parse)) return 'SKIP: this fixture cannot reach the run-report reader';
     if(typeof WEAPONS!=='object') return 'SKIP: this fixture has no weapon table to read';
     var bad=[];
     try{
       // OFF THE TABLE, NOT TYPED: the first name with a space in it and the
       // first without, so a rename cannot make this check stop testing.
       var two=null, one=null, k;
       for(k in WEAPONS){
         var nm=WEAPONS[k]&&WEAPONS[k].name; if(!nm) continue;
         if(!two&&nm.indexOf(' ')>=0) two=nm;
         if(!one&&nm.indexOf(' ')<0) one=nm;
       }
       if(!two) return 'SKIP: no weapon in this build has a space in its name, so there is nothing here to cut';
       // The export's own shape: a header it tests for, then run lines.
       function report(gun,withSource){
         var L=['=== PILLAGERS FLIGHT RECORDER ==='];
         for(var i=1;i<=4;i++)
           L.push('#'+i+' v1.00 '+(i<3?'EXTRACT':'DEAD')+' [std] wep:'+gun+(withSource?'(owned)':'')+' dur:31s haul:1200c');
         return L.join('\n');
       }
       var g=__ghost.parse(report(two,true),'FRIEND');
       if(!g){ bad.push('a report in the export format was refused outright, so nothing about a friend can be read at all'); }
       else {
         if(g.wepName!==two)
           bad.push('a friend whose every run says '+two+' is reported as '+(g.wepName===null?'having no favourite':('favouring the '+g.wepName))+': the name is cut at the first space, so the lookup misses and the game states a fact about a real person that their own report contradicts');
         if(g.wep&&WEAPONS[g.wep]&&WEAPONS[g.wep].name!==two)
           bad.push('the ghost is armed with the '+WEAPONS[g.wep].name+' rather than the '+two+', so the damage and engagement range they walk your raids with belong to a different gun');
         if(g.runs!==4||g.ext!==2)
           bad.push('control: the reader miscounted a four-run report as '+g.runs+' runs and '+g.ext+' extractions, so this check is reading something other than the report');
       }
       // THE SOURCE BRACKET IS OPTIONAL IN THE FORMAT, so a report without it has
       // to read the same way.
       var g2=__ghost.parse(report(two,false),'FRIEND');
       if(g2&&g2.wepName!==two)
         bad.push('the same report without the owned-or-issued bracket reads as '+(g2.wepName===null?'no favourite':g2.wepName)+' rather than the '+two);
       // A ONE-WORD NAME ALWAYS WORKED AND MUST GO ON WORKING.
       if(one){
         var g3=__ghost.parse(report(one,true),'FRIEND');
         if(!g3||g3.wepName!==one)
           bad.push('control: a one-word gun no longer reads correctly either ('+(g3?g3.wepName:'nothing came back')+' rather than the '+one+'), so the reader has been broken rather than fixed');
       }
       // A NAME THIS BUILD DOES NOT HAVE MUST NOT BECOME A CONFIDENT WRONG ANSWER.
       var g4=__ghost.parse(report('Zither Cannon',true),'FRIEND');
       if(g4&&g4.wepName)
         bad.push('a report naming a gun this build does not have still claims the friend favours the '+g4.wepName+', which is a statement about a real person that nothing in their report supports');
       if(g4&&!(g4.wep&&WEAPONS[g4.wep]))
         bad.push('a report naming a gun this build does not have leaves the ghost with no usable weapon at all, so dropping the claim broke the arming with it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.87',what:'you come back down with an empty backpack and belt
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
