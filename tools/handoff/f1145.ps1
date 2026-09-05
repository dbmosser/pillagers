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

# v11.45 HOOK: read and reset WNSEEN, the closure the title-keys probe could not
# see. A setter too, so a check can start from the not-yet-seen state whatever an
# earlier check left behind.
SubRx @'
window.__applyLoaded=(typeof applyLoadedProfile==='function')?function(prof){ applyLoadedProfile({key:SKEY,value:JSON.stringify(prof)}); return true; }:undefined;
'@ @'
window.__applyLoaded=(typeof applyLoadedProfile==='function')?function(prof){ applyLoadedProfile({key:SKEY,value:JSON.stringify(prof)}); return true; }:undefined;
window.__wnseen=function(v){ if(v!==undefined) WNSEEN=v; return WNSEEN; };
'@

# v11.45 CHECK, before the v11.44 entry.
SubRx @'
  {v:'11.44',what:'loading a pre-mig945 save keeps the player saved dials: the rig-buyback migration persists through storeSet without saving the defaults over the config before the cfgv block reads it, and the buyback still runs',
'@ @'
  {v:'11.45',what:'the title screen does not answer the floor keys: P and ESC on the boot title leave the pause box closed, ENTER there does not stamp the NEW IN card as seen, and ENTER still starts the game',
   run:function(){
     if(!(window.__showScreen&&window.__keys&&window.__wnseen)) return 'SKIP: this fixture cannot stage the boot title';
     var t=document.getElementById('title'), pb=document.getElementById('pausebox');
     if(!t||!pb) return 'SKIP: no title screen or pause box in this build';
     var bad=[];
     function K(code,key){ var ev=new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true}); window.dispatchEvent(ev); }
     function clearKeys(){ var k=__keys(); for(var q in k) delete k[q]; }
     // THE BOOT CONDITION: state hub with the title raised over it, exactly as a
     // fresh load. __showScreen(hub) sets state hub and clears windows; the title
     // is then raised the way its HTML class does at boot. Calling __showScreen
     // (title) would set state to title and disarm the branch under test, which
     // is what fooled the earlier probe into a not-reproduced verdict.
     __topClear(); clearKeys();
     __showScreen('hub'); t.classList.add('on');
     if(pb.classList.contains('on')) pb.classList.remove('on');
     // 1. P on the title must NOT raise the pause box over it.
     K('KeyP','p');
     if(pb.classList.contains('on')){ bad.push('P on the title screen opened the pause box over it'); pb.classList.remove('on'); }
     // 2. ESC likewise.
     K('Escape','Escape');
     if(pb.classList.contains('on')){ bad.push('ESC on the title screen opened the pause box over it'); pb.classList.remove('on'); }
     // 3. ENTER on the title must not stamp the NEW IN card as seen. Read
     //    synchronously, before any frame can stamp it for other reasons.
     __wnseen(0);
     var wasUp=t.classList.contains('on');
     K('Enter','Enter');
     if(__wnseen()===1) bad.push('ENTER on the title screen stamped the NEW IN card as already seen');
     // CONTROL: the title keeps its own start; ENTER must still take the title down.
     if(wasUp&&t.classList.contains('on')) bad.push('control: ENTER on the title did not start the game (the title is still up), so the title start itself is broken');
     clearKeys();
     return bad.length?bad.join('; '):null; }},
  {v:'11.44',what:'loading a pre-mig945 save keeps the player saved dials: the rig-buyback migration persists through storeSet without saving the defaults over the config before the cfgv block reads it, and the buyback still runs',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
