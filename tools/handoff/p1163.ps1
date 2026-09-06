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

# [+] ON A COLLAPSED CURRENT PILLAGERS BOARD STARTED AN INVISIBLE RESIZE. The
# collapsed box is one line tall and the resize grip zone (v8.93) is taller
# than that, so the grip covered the whole [+] glyph; mousedown tests the grip
# first, by design, and had no collapsed guard, while hudHit (the cursor) and
# the grip draw both skip collapsed panels. So the pointer promised a click,
# the click began a resize nobody could see, and the board never expanded.
# mousedown now agrees with the other two.
SubRx @'
        if(HUDZ[hk]!==undefined){
          if(hudOnGrip(HB2,mouse.x,mouse.y)){
'@ @'
        // v11.63: never on a collapsed panel. Its box is shorter than the grip
        // zone, so the grip covered the [+] glyph and the click that should
        // expand the board started a resize nobody could see. hudHit and the
        // grip draw already skip collapsed panels; mousedown agrees with them.
        if(HUDZ[hk]!==undefined&&!hudOff(hk).c){
          if(hudOnGrip(HB2,mouse.x,mouse.y)){
'@

# STAMPS.
SubRx @'
var VER='11.62';
'@ @'
var VER='11.63';
'@
SubRx @'
var WHATSNEW_VER='11.62';
'@ @'
var WHATSNEW_VER='11.63';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE [+] ON A COLLAPSED PILLAGER BOARD EXPANDS IT AGAIN. The resize grip had grown over the glyph on the folded board, so the click began a resize you could not see and the board stayed shut.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.61:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.62 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.61:[^']*'",{ param($m) "now:'v11.63: [+] on a collapsed CURRENT PILLAGERS board started an invisible resize instead of expanding it. The collapsed box is one line tall and the grip zone is taller, so the grip covered the glyph; mousedown tests the grip first and had no collapsed guard while hudHit and the grip draw both skip collapsed panels. mousedown skips them now. From the v11.46 audit, P2.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
