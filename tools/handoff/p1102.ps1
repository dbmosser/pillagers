$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE 8: FULLSCREEN DIES WHEN HE CHANGES SAVE, AND HE ASKED WHY.
# ============
# ============ "if i click fullscreen and then click to change the save, it kicks
# ============ me out of fullscreen --why??", 2026-09-04.
# ============
# ============ THE ANSWER, AND IT IS NOT A BUG I CAN PATCH AWAY. Clicking another
# ============ save writes the slot pointer and calls location.reload, because the
# ============ profile key is read once at file scope and the whole game is built
# ============ from it. Every browser drops fullscreen on a page load, and it
# ============ cannot be re-entered afterwards without a fresh click, because
# ============ requestFullscreen needs a user gesture and a gesture does not
# ============ survive a navigation. So the two honest fixes are to switch saves
# ============ WITHOUT reloading, which is a deep change I am not making 55 hours
# ============ from an alpha, or to stop it being a mystery and put the way back
# ============ one click away. This is the second.
# ============
# ============ WHAT HE GETS: a line under the saves that says changing save
# ============ reloads the game, so nobody is surprised; and, if he WAS in
# ============ fullscreen when he switched, the title screen says so on the way
# ============ back in and the GO FULLSCREEN button is right there. The flag lives
# ============ in its own storage key and never touches the profile.

# ---- 1. the note under the saves, always there
SubRx @'
      <div id="slotlist" style="margin-top:8px;display:grid;gap:6px"></div>
'@ @'
      <div id="slotlist" style="margin-top:8px;display:grid;gap:6px"></div>
      <!-- v11.02, HIS NOTE 8: he asked why changing save leaves fullscreen. It
           reloads the game, and a browser always drops fullscreen on a reload.
           Said here, where the click is. -->
      <div style="margin-top:6px;font-size:10.5px;color:var(--ash);letter-spacing:.06em">Changing save reloads the game, which is why it leaves fullscreen.</div>
      <div id="fsback" style="display:none;margin-top:6px;font-size:11px;color:var(--amber);letter-spacing:.06em">You were in fullscreen. The reload dropped it, as it always does. GO FULLSCREEN is above.</div>
'@

# ---- 2. remember it, and say it once on the way back
SubRx @'
function fsCan(){
'@ @'
// v11.02, HIS NOTE 8. Its own key, never the profile: this is about the browser
// and the tab, not about a character, and it must survive the switch between two
// saves without belonging to either.
var FSKEY='salvagerun:fsWanted';
function fsMark(){
  try{ if(fsOn()) localStorage.setItem(FSKEY,'1'); }catch(e){}
}
// Read once, cleared once, so the line appears on the reload it belongs to and
// never again.
function fsBackNote(){
  var was=null;
  try{ was=localStorage.getItem(FSKEY); if(was) localStorage.removeItem(FSKEY); }catch(e){}
  var el=document.getElementById('fsback');
  if(el) el.style.display=(was&&!fsOn())?'':'none';
  return !!was;
}
function fsCan(){
'@

# ---- 3. both roads out of the title reload, so both remember
SubRx @'
          if(sn===SLOT) return;
          try{ localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}
          location.reload();
'@ @'
          if(sn===SLOT) return;
          fsMark();   // v11.02, his note 8
          try{ localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}
          location.reload();
'@
SubRx @'
        if(!slotInfo(key)&&key!==SLOT){
          try{ localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}
          location.reload(); return;
        }
'@ @'
        if(!slotInfo(key)&&key!==SLOT){
          fsMark();   // v11.02, his note 8
          try{ localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}
          location.reload(); return;
        }
'@

# ---- 4. and the title screen asks on the way in
SubRx @'
      fsSync();
    })();
'@ @'
      fsSync();
      try{ fsBackNote(); }catch(_fb){}   // v11.02, his note 8
    })();
'@
# ---- and it goes away the moment he is back in fullscreen, without a reload
SubRx @'
  b.textContent=fsOn()?'LEAVE FULLSCREEN':'GO FULLSCREEN';
}
'@ @'
  b.textContent=fsOn()?'LEAVE FULLSCREEN':'GO FULLSCREEN';
  // v11.02: once he is back in, the line has done its job.
  if(fsOn()){ var nb=document.getElementById('fsback'); if(nb) nb.style.display='none'; }
}
'@

SubRx @'
var VER='11.01';
'@ @'
var VER='11.02';
'@
SubRx @'
  now:'v11.01: the feedback buttons at the end of a raid, your note. The old twenty-four were the open questions of v5.72, eight of them one-machine questions you have since answered with dozens of runs, and nothing at all from the last thirty builds. The new thirty lead with the three a friend cannot tell you any other way: it crashed, it looked wrong, the sound was off.',
'@ @'
  now:'v11.02: why changing save leaves fullscreen, your question. Because it reloads the game, and a browser always drops fullscreen on a reload; it cannot be put back without a click, because entering fullscreen needs a gesture and a gesture does not survive a page load. The saves panel says so now, and if you were in fullscreen when you switched, the title screen tells you and GO FULLSCREEN is right there.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'CHANGING SAVE RELOADS THE GAME, which is why it drops fullscreen. The saves panel says so now, and if you were in fullscreen when you switched, the title screen tells you on the way back and the button is right above it.',
'@
SubRx @'
var WHATSNEW_VER='11.01';
'@ @'
var WHATSNEW_VER='11.02';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
