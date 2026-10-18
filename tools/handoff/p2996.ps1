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

# PAUSE X, SETTINGS FOCUS ROW, KEYS FADE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #settabs{ top:calc(var(--py) + var(--sp-1)); }
'@ @'
#root #settingsmodal #settabs{ top:calc(var(--py) + var(--sp-1)); }

/* v28.xx (cw-pausex) critic c-31 (pause 25/42/49 at 3: "no close affordance, only a tiny Esc Resume"; Settings 26 at 3: "no focus is visible, the detail pane says Edit the words but that row has no raised fill or amber edge"; Keys 32 at 3: "the World rows are sliced off mid glyph, no fade", "section labels are tiny"). Now: the pause card has the same 48 x 48 header X as Settings and Keys (it resumes), the row the detail pane names wears the focus look, and the Keys list fades out over its last 32px with 24px labels. */
#root #pausex{ position:absolute; z-index:2; top:calc(50% - var(--pbh, 50vh) / 2 + var(--sp-3)); right:calc(50% - var(--pw) / 2); width:var(--sp-5); height:var(--sp-5); min-width:0 !important; min-height:0 !important; padding:0 !important; font-size:0 !important; line-height:1; display:flex; align-items:center; justify-content:center; }
#root #pausex::after{ content:''; --xc:var(--tx-1); width:var(--sp-3); height:var(--sp-3); background:linear-gradient(45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%), linear-gradient(-45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%); }
#root #pausex:hover::after{ --xc:var(--acc); }
#root #pausebox.asking #pausex{ display:none; }
#root #setlist .row.dshow:not(.setjump){ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--acc); }
#root #setlist .row.dshow:not(.setjump) > button{ border-color:var(--ui-line-hi); background:var(--ui-void); color:var(--acc); }
#root #keyslist{ padding-bottom:var(--sp-4); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-4)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-4)), transparent); }
#root #keyslist .keysec{ font-size:var(--fs-body); padding-top:var(--sp-3); }
'@

SubRx @'
<div id="pausebleed" style="display:none;
'@ @'
<button id="pausex" title="Resume" aria-label="Resume"></button>
  <div id="pausebleed" style="display:none;
'@

SubRx @'
c=b.children[i]; if(c.offsetHeight>0){ t=Math.min
'@ @'
c=b.children[i]; if(c.offsetHeight>0&&c.id!=='pausex'){ t=Math.min
'@

SubRx @'
// v4.24 HIS ORDER: no accidental abandons. First click arms a YES button on
'@ @'
// v28.xx (cw-pausex) the header X on the pause card is the Resume button's twin
document.getElementById('pausex').onclick=function(){ document.getElementById('resumebtn').onclick(); };
// v4.24 HIS ORDER: no accidental abandons. First click arms a YES button on
'@

SubRx @'
if(!r){ if(dt.innerHTML) dt.innerHTML=''; return; }
'@ @'
if(!r){ if(dt.innerHTML) dt.innerHTML=''; return; }
    // v28.xx (cw-pausex) the row the pane names wears the focus look even with no pointer on it
    var _cur=sl.querySelector('.row.dshow'); if(_cur!==r){ if(_cur) _cur.classList.remove('dshow'); r.classList.add('dshow'); }
'@

SubRx @'
var VER='29.95';
'@ @'
var VER='29.96';
'@

$pat = "(?m)^  now:'v29\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.96: Pause card has a close X, Settings shows the focused row, Keys fades out. Check 29.96 fails on v29.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
