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

# THE GUN CARD FITS ITS WORDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ var _wpw=Math.max(LH(230),ctx.measureText(_cornName).width+LH(30)), _wpx=W-16-_wpw+LH(10), _hcL=(G.hotCells&&G.hotCells.length)?G.hotCells[G.hotCells.length-1]:null;
       var _gz=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _gdx=(typeof _boG==='object'&&_boG)?(_boG.dx||0):0, _lim=_hcL?(W+((_hcL.x+_hcL.w+LH(8))-_gdx-W)/_gz):-1e9;   // the belt edge, brought into this corner's scaled space
       if(_hcL&&_wpx<_lim){ _wpx=_lim; _wpw=W-16+LH(10)-_wpx; }   // v18.39: never over the belt (it covered key 9)
       if(_wpw>LH(60)) hudPanel(_wpx,by-LH(90),_wpw,LH(100),0.62); ctx.textAlign='right'; }catch(_wp){}
'@ @'
  // v21.40, from the 4K visual pass of 2026-10-09 (W-D2): THE GUN CARD FITS ITS WORDS AND STAYS OFF THE SCREEN EDGE. The card was at
  // least LH(230) wide whatever it held, so behind Sputter, 28 / 56 and STOWED Bare Hands more than half of it was empty, and it ran
  // LH(10) past the words, which at the game's text size (15 or 16) put its right edge on the very edge of the screen, where no other
  // panel goes. It now ends 8 pixels in from the edge on screen, where the hidden chip above it ends, starts where the box the mouse
  // moves it by starts (so its resize grip sits under its left edge), and grows left only for a long gun name or stowed line. The words on
  // it, the box the mouse uses and the belt clamp are as they were.
  try{ var _gz=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _wpR=W-8/_gz, _wtx=ctx.measureText(_cornName).width;
       if(p.sec){ ctx.font=FS(TYPE.micro); _wtx=Math.max(_wtx,ctx.measureText('STOWED  '+p.sec.name+((p.sec.mag>0)?'  '+p.secAmmo:'')).width); ctx.font=FS(TYPE.head); }
       var _wpx=Math.min(W-252,W-16-_wtx-LH(14)), _wpw=_wpR-_wpx, _hcL=(G.hotCells&&G.hotCells.length)?G.hotCells[G.hotCells.length-1]:null;
       var _gdx=(typeof _boG==='object'&&_boG)?(_boG.dx||0):0, _lim=_hcL?(W+((_hcL.x+_hcL.w+LH(8))-_gdx-W)/_gz):-1e9;   // the belt edge, brought into this corner's scaled space
       if(_hcL&&_wpx<_lim){ _wpx=_lim; _wpw=_wpR-_wpx; }   // v18.39: never over the belt (it covered key 9)
       if(_wpw>LH(60)) hudPanel(_wpx,by-LH(90),_wpw,LH(100),0.62); ctx.textAlign='right'; }catch(_wp){}
'@

SubRx @'
var VER='21.39';
'@ @'
var VER='21.40';
'@

$pat = "(?m)^  now:'v21\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.40: The gun card in the corner is no wider than its words and no longer touches the screen edge. Check 21.40 fails on v21.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
