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

# SMOOTH LOOK, A SMALLER PILLAGER, A BIGGER BULWARK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
(function(){ var i; for(i=0;i<XF_ROWS.length;i++){ XF_KEYS.push(XF_ROWS[i][0]); DEF[XF_ROWS[i][0]]=1; if(XF_ROWS[i][3]==='w') XF_WORLD.push(XF_ROWS[i][0]); } })();
'@ @'
(function(){ var i; for(i=0;i<XF_ROWS.length;i++){ XF_KEYS.push(XF_ROWS[i][0]); DEF[XF_ROWS[i][0]]=1; if(XF_ROWS[i][3]==='w') XF_WORLD.push(XF_ROWS[i][0]); } })(); DEF.xfPix=0;   // v28.xx (cw-smoothlook), HIS ORDER (2026-10-25): "I don't like the pixelated style, I want the graphics smooth". The pixel look is off by default; its row stays in Settings, experimental, and off is the smooth game byte for byte.
'@

SubRx @'
GAMEOPTS.push({k:r[0],label:r[1],sec:'EXPERIMENTAL',hint:r[2],opts:[{n:'on',cfg:on},{n:'off',cfg:off}],def:0});
'@ @'
GAMEOPTS.push({k:r[0],label:r[1],sec:'EXPERIMENTAL',hint:r[2],opts:[{n:'on',cfg:on},{n:'off',cfg:off}],def:(r[0]==='xfPix'?1:0)});   // v28.xx (cw-smoothlook): the pixel look row defaults to off (his 10-25 order); every other experimental row stays on
'@

SubRx @'
function mmOn(){ return +CFG.mmSz>0; }
'@ @'
function mmOn(){ return +CFG.mmSz>0; } function pixOffMove(){ if(!P||P.pixOff1===1) return false; if(P.gameOpts&&typeof P.gameOpts.xfPix==='number') P.gameOpts.xfPix=1; P.pixOff1=1; return true; }   // v28.xx (cw-smoothlook), HIS ORDER (2026-10-25) "I want the graphics smooth": a save that holds the pixel look moves to off once (P.pixOff1 marks it done), so a pixel pick made after today survives
'@

SubRx @'
try{ mmOffMove(); }catch(_mo){}   // v33.35 (cw-mmoff): once per save
'@ @'
try{ mmOffMove(); }catch(_mo){} try{ pixOffMove(); }catch(_po){}   // v33.35 (cw-mmoff): once per save; v28.xx (cw-smoothlook): the pixel look move, once per save
'@

SubRx @'
var FIG_SCALE=1, FIG_UP=12, /*
'@ @'
var FIG_SCALE=0.8, FIG_UP=4, /* v28.xx (cw-smoothlook), HIS NOTES (2026-10-25): "Pillager is too big" and "Pillager still too big" (his 10-20 order already said "or maybe even smaller, should be scaled properly compared to bodies on ground, trees, deer"). 1 to 0.8, drawing only: hit areas, walking and doors are untouched. FIG_UP 12 to 4 so the plates sit just over the smaller head. */ /*
'@

SubRx @'
function machMul(e){ return (e&&MACH_KIND[e.kind]===1)?FIG_MACH:1; }
'@ @'
var BULWARK_BIG=1.5; /* v28.xx (cw-smoothlook), HIS NOTES (2026-10-25): "Player too big vs the bulwark which is too small" and "Bulwark still too small". The bulwark is drawn, plated and hit 1.5 times the other machines (about 2x its old art); it still walks, fits doors and routes on the old radius, so it never sticks in a doorway. A bigger target is the balance cost. */ function machMul(e){ return (e&&MACH_KIND[e.kind]===1)?(e.kind==='bulwark'?FIG_MACH*BULWARK_BIG:FIG_MACH):1; }
'@

SubRx @'
var VER='34.80';
'@ @'
var VER='34.81';
'@

$pat = "(?m)^  now:'v34\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.81: The game looks smooth again (the pixel look is off, saved games too). Pillagers are drawn a fifth smaller. The bulwark is about twice as big and easier to hit. Watch for: name plates sitting right over heads, the smaller pillager staying easy to spot in a fight, and the bulwark art overlapping walls when it hugs one. Check 34.81 fails on v34.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
