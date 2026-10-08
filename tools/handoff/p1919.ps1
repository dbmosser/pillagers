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

# THE STATUS ICONS KEEP OFF MOVED PANELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  B=HUDBOX.raiders;                          // a board dragged or grown down into the band pushes the column below it
  if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y<=oy&&B.y+B.h+g*hr>oy) oy=Math.round(B.y+B.h+g*hr);
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
  yBot=H-LH(8)*hr;                           // and it stops above the controls and the vitals, wherever they sit
  B=HUDBOX.legend; if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y>oy) yBot=Math.min(yBot,B.y-g*hr);
  B=HUDBOX.body;   if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y>oy) yBot=Math.min(yBot,B.y-LH(20)*hr);
'@ @'
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
  yBot=H-LH(8)*hr;                           // and it stops above the controls and the vitals, wherever they sit
  // v19.19, from the review (2026-10-07): the board was avoided only when its top was above the column, and the controls list and the
  // vitals only when their top was below it, so a board dragged down, or a list grown or dragged up, had the icons drawn over it. Every
  // panel at the left is now treated the same, top to bottom: one that starts by the column's first row pushes the column below it, one
  // that starts lower ends the column above it. When that leaves no room for a row, the column moves to the right of those panels.
  var _bx=[HUDBOX.raiders,HUDBOX.legend,HUDBOX.body].filter(function(b){ return b&&b.x<ox+wC&&b.x+b.w>ox; }).sort(function(a,b){ return a.y-b.y; }), _bi, _br;
  for(_bi=0;_bi<_bx.length;_bi++){ B=_bx[_bi];
    if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;
    if(B.y<=oy+S*hr/2) oy=Math.round(B.y+B.h+g*hr);
    else yBot=Math.min(yBot,B.y-((B===HUDBOX.body)?LH(20):g)*hr);
  }
  if(yBot-oy<S*hr*0.6&&_bx.length){
    _br=0; for(_bi=0;_bi<_bx.length;_bi++) _br=Math.max(_br,_bx[_bi].x+_bx[_bi].w);
    ox=Math.round(_br+g*hr); oy=Math.round(H*0.40); yBot=H-LH(8)*hr;
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.x<ox+wC&&NETTEAMBOX.x+NETTEAMBOX.w>ox&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);
  }
'@

SubRx @'
var VER='19.18';
'@ @'
var VER='19.19';
'@

$pat = "(?m)^  now:'v19\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.19: Status icons never draw over a board or controls list you have moved or resized. Check 19.19 fails on v19.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
