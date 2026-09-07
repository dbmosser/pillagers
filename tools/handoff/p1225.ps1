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

# HIS NOTE (2026-09-07 morning): "credits and xp in right hand corner way too
# small -- all menus, words, UI, hud etc should scale depending on 1080p vs
# 1440p vs 4k". Traced by the 2026-09-07 read-only notes investigation and
# verified by reading at v12.24: applyMenuZoom writes zoom = menuZoom *
# titleRes() onto .modal, .pausebox, .outcome and #hub, and onto the title
# screen; the corner readout #topright is a fixed element at the body (line
# 1166) with hard 32px and 14px sizes (CSS 484-486), and nothing in the file
# ever writes a zoom on it, so it painted the same 44 pixels at 1080p, 1440p
# and 4K while the stash beside it was at 1.73 and 2.47. Two more body-level
# fixed surfaces share the omission: #hubtoast, the floor's answer line, and
# #grabghost, the label under the pointer while dragging.
SubRx @'
    m.style.zoom=(m.id==='hub')?(_sf*0.92):_sf;
  });
'@ @'
    m.style.zoom=(m.id==='hub')?(_sf*0.92):_sf;
  });
  // v12.25, HIS NOTE: "credits and xp in right hand corner way too small; all
  // menus, words, UI, hud etc should scale depending on 1080p vs 1440p vs 4k".
  // The corner readout, the floor's answer line and the drag label are fixed at
  // the body, outside every element in the list above, so they stayed 1080p
  // pixels under a 4K stash drawn at 2.47. The same factor as the windows. A
  // zoomed fixed element takes its own offsets in zoomed pixels too, so
  // right:20px and bottom:38px grow with it and the readout keeps its corner.
  document.querySelectorAll('#topright,#hubtoast,#grabghost').forEach(function(f){ f.style.zoom=_sf; });
'@

# The drag label is created lazily, on the first grab, after applyMenuZoom has
# run, so it takes the factor itself; and it is placed in pointer pixels, which
# a zoomed fixed element reads as zoomed pixels, so the offsets divide by it.
SubRx @'
    document.body.appendChild(g);
'@ @'
    document.body.appendChild(g);
    // v12.25: born lazily, after applyMenuZoom has run, so it takes the factor itself.
    try{ g.style.zoom=Math.max(1,(P&&P.menuZoom)||1)*titleRes(); }catch(_gz){}
'@
SubRx @'
    g.style.left=(ev.clientX+12)+'px'; g.style.top=(ev.clientY+12)+'px';
'@ @'
    // v12.25: a zoomed fixed element takes its offsets in its own zoomed pixels.
    var _gz=parseFloat(g.style.zoom)||1;
    g.style.left=((ev.clientX+12)/_gz)+'px'; g.style.top=((ev.clientY+12)/_gz)+'px';
'@
SubRx @'
  if(g){ g.style.left=(ev.clientX+12)+'px'; g.style.top=(ev.clientY+12)+'px'; }
'@ @'
  if(g){ var _gz2=parseFloat(g.style.zoom)||1; g.style.left=((ev.clientX+12)/_gz2)+'px'; g.style.top=((ev.clientY+12)/_gz2)+'px'; }   // v12.25: zoomed pixels
'@

# The stash screen's top row keeps clear of the readout (v11.52, v11.78). The
# readout is up to 1.3 times wider in real pixels now at 1080p (the default
# menuZoom), so the clearance grows with it. Check 12.25 measures the overlap.
SubRx @'
  .toprow{ padding-right:480px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable; v11.78: the readout is twice as wide */
'@ @'
  .toprow{ padding-right:560px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable; v11.78: the readout is twice as wide; v12.25: the readout carries the window zoom now, up to 1.3 times wider again at 1080p */
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CREDITS AND XP READOUT NOW SCALES WITH YOUR MONITOR AND THE TEXT SIZE SETTING, like every window. So do the answer line in the Undercroft and the label under the pointer while you drag. They were 1080p pixels on a 4K screen.',
'@

# STAMPS.
SubRx @'
var VER='12.24';
'@ @'
var VER='12.25';
'@
SubRx @'
var WHATSNEW_VER='12.24';
'@ @'
var WHATSNEW_VER='12.25';
'@
$cnt=([regex]::Matches($s,"now:'v12\.24:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.24 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.24:[^']*'",{ param($m) "now:'v12.25: his note of 2026-09-07: the credits and XP readout in the corner, the answer line on the floor and the label under the pointer while dragging were fixed at the body, outside every element applyMenuZoom scales, so they stayed 1080p pixels under a 4K stash drawn at 2.47 times. They carry the same factor as the windows now, the drag label divides its pointer offsets by it, and the stash top row keeps 560 pixels clear instead of 480. Check 12.25 forces 4K, 1440p and 1080p in turn and requires the readout zoom to equal the windows and its height to follow, presses the real Text size button and requires the readout to move; controls: at 1080p the readout must not cover a stash top-row button, and a raid must start its CONDITIONS box under the readout; fails on v12.24.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
