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

# v12.75 CHECK, inserted before the v12.74 entry. It renders the real box and
# reads the real text. The armour half is asserted as a RULE rather than against
# a word: whatever the rig function calls itself, the summary must not name it,
# because the warning printed underneath says he has none of it. That way a
# renamed rig moves the check with it instead of leaving a hole. The staging is
# asserted too: if the warning is not there, there is nothing to contradict and
# the check says so rather than passing on an empty box.
SubRx @'
  {v:'12.74',what:'the Peddler stall knows what it just paid him: the balance line and the refusal both name the money riding on him that the stall pays into, instead of reading only the banked Credits and telling a man who has just been paid thousands that he holds nothing, while a man carrying nothing still reads the plain banked figure and gets the plain refusal, and the sale line no longer uses a word this game does not use (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.75',what:'the last box before the lift says what actually happens: with nothing equipped it does not promise a sidearm, because the deploy issues a primary and leaves the second slot empty, and it does not list the rig on the line above the warning that he ascends with no armour on, while a character who has a gun equipped still sees that gun named (2026-09-08 first-hour audit)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof syncSectorKit!=='function') return 'SKIP: this build has no sector kit box to render';
     var el=document.getElementById('sectorkit');
     if(!el) return 'SKIP: this build has no sector kit box in the page';
     var bad=[], P2=__P(), keepEq=P2.equipped, keepW=(P2.weapons||[]).slice();
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // WHAT A BRAND NEW CHARACTER HAS: nothing in his hands.
       P2.equipped='fists';
       syncSectorKit();
       var html=String(el.innerHTML||'');
       if(!html) return 'SKIP: the box rendered nothing';
       // The warning is the thing the line above it has to agree with. No
       // warning, nothing to contradict, and this check would be decoration.
       if(html.toLowerCase().indexOf('no armour')<0) return 'SKIP: this build does not print the armour warning, so there is nothing for the line above it to contradict';
       var head=html.split('<div')[0];
       var SIDE='side'+'arm';
       if(head.toLowerCase().indexOf(SIDE)>=0)
         bad.push('with nothing equipped the last box before the lift still promises him a sidearm ['+head+']: the deploy rolls a PRIMARY out of the starter list into gun one and leaves gun two deliberately empty, so it names the wrong slot and promises a second gun that is not coming');
       var rigName='';
       try{ var RG=myRig(); rigName=(RG&&RG.name)||''; }catch(_r){ rigName=''; }
       if(rigName&&head.indexOf(rigName)>=0)
         bad.push('the box says he is going up with '+rigName+' on the line directly above the amber warning that he ascends with no armour on, and that rig is the same constant for everybody, so the two halves of one box contradict each other on every ascent');
       // CONTROL: a character who HAS a gun must still be told which one, or
       // this check would pass on a box that had simply been emptied.
       var gid=null, k;
       for(k in WEAPONS){ if(WEAPONS[k]&&WEAPONS[k].name&&k!=='fists'&&WEAPONS[k].mag){ gid=k; break; } }
       if(gid){
         P2.equipped=gid; if((P2.weapons||[]).indexOf(gid)<0) P2.weapons=(P2.weapons||[]).concat([gid]);
         syncSectorKit();
         var html2=String(el.innerHTML||'');
         if(html2.indexOf(WEAPONS[gid].name)<0)
           bad.push('control: a character with '+WEAPONS[gid].name+' in his hands is no longer told so by the box ['+html2.split('<div')[0]+']');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.equipped=keepEq; P2.weapons=keepW; saveProfile(); syncSectorKit(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.74',what:'the Peddler stall knows what it just paid him: the balance line and the refusal both name the money riding on him that the stall pays into, instead of reading only the banked Credits and telling a man who has just been paid thousands that he holds nothing, while a man carrying nothing still reads the plain banked figure and gets the plain refusal, and the sale line no longer uses a word this game does not use (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
