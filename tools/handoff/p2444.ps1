$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE PICK SHOWS ON THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge of the title shot with 2 PLAYER CO-OP picked and the second window
     blocked): THE PICK SHOWS. After a same machine pick that stops on a note, 1 PLAYER was still the amber button, so the screen
     did not say what had been chosen, and the blocked note was a line of small red words with a small RETRY under it, like a stray
     error. The picked row now carries the amber rail and a warm fill, 1 PLAYER steps back to an outline row while the pick is
     waiting, and the note and RETRY are one alert card: a red rail, the words at 15px, RETRY the amber primary at its right end.
     The step cards, the line under the rows and the saves panel give back a few pixels, so the title with the alert card up still
     fits a 1080p screen at full size. No word changed. */
  #root #title .tcard{ padding:10px 16px; }
  #root #titlesub{ margin-top:8px !important; }
  #root #slotpanel{ margin-top:14px !important; }
  #root #modemenu button.moderow.picked{ background:#2a2416; border-color:var(--acc); color:var(--tx-1); box-shadow:inset 4px 0 0 var(--acc); }
  #root #modemenu.haspick #titlestart{ background:rgba(17,19,21,.88); border-color:var(--ui-line-hi); color:var(--acc); }
  #root #modemenu.haspick #titlestart:hover:not(:disabled){ background:var(--ui-hover); border-color:var(--acc); }
  #root #modealert{ box-sizing:border-box; display:flex; align-items:center; gap:14px; width:560px; max-width:100%; margin:2px 0 0;
    padding:8px 10px 8px 16px; background:#2a1714; border:1px solid rgba(229,72,47,.45); border-left:4px solid var(--danger); border-radius:2px; }
  #root #modemsg{ flex:1; max-width:none; text-align:left; font-size:15px; line-height:1.45; color:var(--tx-1); }
  #root #modemenu #moderetry{ flex:none; min-width:150px; min-height:48px; padding:0 22px !important; background:var(--acc); border-color:var(--acc);
    color:var(--acc-ink); font-size:17px; font-weight:700; letter-spacing:.12em; }
  #root #modemenu #moderetry:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
'@

SubRx @'
function netModeMsg(t,retry){
  var m=document.getElementById('modemsg'), r=document.getElementById('moderetry');
  if(m){ m.textContent=t||''; m.style.display=t?'':'none'; }
  if(r) r.style.display=(t&&retry)?'':'none';
}
'@ @'
function netModeMsg(t,retry){
  var m=document.getElementById('modemsg'), r=document.getElementById('moderetry');
  if(m){ m.textContent=t||''; m.style.display=t?'':'none'; }
  if(r) r.style.display=(t&&retry)?'':'none';
  var al=document.getElementById('modealert'); if(al) al.style.display=t?'':'none';   // vNN.xx (ui5q1c): the alert card holds the note and RETRY
  try{ netModePickMark(!!t); }catch(_pm){}   // vNN.xx (ui5q1c, his #50): the row picked shows it is the pick while its note is up
}
// vNN.xx, UI REDESIGN ui5q1c (his #50, the title shot with a pick stopped on a note): MARK THE PICKED ROW. While a same machine pick
// waits on a note (the browser blocked the window, player 2 is still in a raid), the row that was picked carries .picked and the
// menu .haspick, so the pick shows and 1 PLAYER steps back; the note going away clears both. Looks only: nothing reads the marks.
function netModePickMark(on){
  var mm=document.getElementById('modemenu'), q, i, id='';
  if(!mm) return;
  if(on&&NET.pick) id=(NET.pick==='pvp')?'modepvp':(NET.arcPick?'modearcade':'modecoop');
  q=mm.querySelectorAll('button[data-mode]');
  for(i=0;i<q.length;i++) q[i].classList.toggle('picked',!!id&&q[i].id===id);
  mm.classList.toggle('haspick',!!id);
}
'@

SubRx @'
      <div id="modemsg" style="display:none"></div>
      <button class="deploy ghost" id="moderetry" style="display:none;padding:8px 24px">RETRY</button>
'@ @'
      <!-- vNN.xx (ui5q1c, his #50): the note and RETRY are one alert card; netModeMsg shows and hides it with the note -->
      <div id="modealert" style="display:none"><div id="modemsg" style="display:none"></div><button class="deploy ghost" id="moderetry" style="display:none;padding:8px 24px">RETRY</button></div>
'@

SubRx @'
var VER='24.43';
'@ @'
var VER='24.44';
'@

$pat = "(?m)^  now:'v24\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.44: A picked mode on the title shows it is the pick, and a blocked second window shows an alert box with a big RETRY. Check 24.44 fails on v24.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
