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

# ONE WINDOW FRAME, CLOSE IN ONE PLACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    #root button:active:not(:disabled), #root .ui-btn:active:not(:disabled){ transform:none !important; }
  }
</style>
'@ @'
    #root button:active:not(:disabled), #root .ui-btn:active:not(:disabled){ transform:none !important; }
  }
  /* v24.21, UI REDESIGN ui6 (his #50 2026-10-12): THE WINDOW FRAME. Every window and the pause box sit on one plate: graphite with a
     faint static grain, a hairline edge, the top left corner cut at 12px with the hairline carried round the cut, and a short amber tick
     on the top edge, in place of the double periwinkle frame. The title is a header bar over a hairline, in bone. Every station window
     ends in a footer bar over a hairline with CLOSE at its right end, at the foot of the frame, so CLOSE is in one place everywhere:
     the shop, the Mainframe, Settings, Fashion and the stash at one height, and the card windows (Wirt, the Last Pour, the Terms, the
     party) at the foot of their card. Nothing moves in the page order, so the controller walks the same way it did. */
  :root{ --ui-grain:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='128' height='128'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='128' height='128' filter='url(%23n)' opacity='.06'/%3E%3C/svg%3E"); }
  #root .modal{ background:radial-gradient(1200px 600px at 50% -10%, rgba(170,164,152,.06), transparent 60%), var(--ui-scrim); }
  #root .modal::before, #root .pausebox::before{ border-radius:0; border:1px solid var(--ui-line); box-shadow:none;
    background:linear-gradient(var(--acc),var(--acc)) 12px 0/48px 2px no-repeat,
      linear-gradient(135deg, transparent 0 8.1px, var(--ui-line-hi) 8.1px 9.3px, transparent 9.3px) 0 0/12px 12px no-repeat,
      var(--ui-grain) 0 0/128px 128px repeat, var(--ui-bg);
    background-origin:border-box; clip-path:polygon(12px 0,100% 0,100% 100%,0 100%,0 12px); }
  #root .modal > h3{ font-family:var(--f-cond); font-weight:700; font-size:28px; line-height:1.05; letter-spacing:.02em; text-transform:uppercase;
    color:var(--tx-1); margin:0 0 14px; padding:4px 0 14px; border-bottom:1px solid var(--ui-line); }
  #root .modal > .ui-foot{ flex:none; display:flex; align-items:center; gap:8px; width:100%; margin-top:auto !important; padding-top:12px;
    border-top:1px solid var(--ui-line); }
  #root #termsmodal > .ui-foot, #root #gamblemodal > .ui-foot, #root #barmodal > .ui-foot, #root #partymodal > .ui-foot{ margin-top:14px !important; max-width:1116px; }
  #root .modal > .ui-foot > .ui-back{ order:99; margin-left:auto !important; min-width:120px; }
  /* the stash: its CLOSE leaves the top row for a footer bar at the foot of the screen, at the height of every window CLOSE
     (the stash is drawn at 0.92 of the window size, his v9.67 note, so 31.74 + 40 at 0.92 is the 26 + 40 of a window) */
  #root #hub{ padding-bottom:84px; }
  #root #hub::after{ content:''; position:absolute; left:22px; right:22px; bottom:84px; border-top:1px solid var(--ui-line); pointer-events:none; }
  #root #hub #stashclose{ position:absolute; right:22px; bottom:31.74px; margin:0 !important; min-width:120px; color:var(--tx-1); border-color:var(--ui-line-hi); }
</style>
'@

SubRx @'
  try{ cardFrameFit(el); }catch(_cf){}   // v20.18: a card window's frame fits what it holds
}
'@ @'
  try{ cardFrameFit(el); }catch(_cf){}   // v20.18: a card window's frame fits what it holds
}
// v24.21, UI REDESIGN ui6 (his #50): THE FOOTER BAR. uiFrame marks a window: its CLOSE row becomes the footer (.ui-foot) and CLOSE
// the back button at its right end (.ui-back); the stylesheet does the rest. Nothing is moved in the page, so the controller walks
// the window in the order it always did and B still finds CLOSE by its word.
var UIFRAME_CLOSE={tradermodal:'closetrader',gamblemodal:'closegamble',appearmodal:'closeappear',barmodal:'closebar',termsmodal:'closeterms',
  partymodal:'closeparty',opmodal:'closeop',sectormodal:'closesector',settingsmodal:'closesettings',welcomemodal:'welcomeno'};
function uiFrame(id){
  var m=document.getElementById(id), b=m?document.getElementById(UIFRAME_CLOSE[id]):null, row=b?b.parentElement:null;
  if(!m||!b||!row||row.parentElement!==m) return false;
  m.classList.add('ui-win'); row.classList.add('ui-foot'); b.classList.add('ui-back');
  return true;
}
(function(){ for(var k in UIFRAME_CLOSE){ if(Object.prototype.hasOwnProperty.call(UIFRAME_CLOSE,k)){ try{ uiFrame(k); }catch(_u){} } } })();
'@

SubRx @'
var VER='24.20';
'@ @'
var VER='24.21';
'@

$pat = "(?m)^  now:'v24\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.21: Every window sits on one cut corner plate with an amber tick, and CLOSE is in a footer at the bottom right of every station window and the stash. Check 24.21 fails on v24.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
