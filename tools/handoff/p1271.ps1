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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P3), specced from the source.
#
# The sprint flag is computed, then the scent marks are laid, and only THEN is
# the flag cancelled for aiming and for deep water. So holding Shift while
# aiming, or while wading, laid a sprint trail although you were not sprinting:
# you moved at the aiming speed, paid no stamina, the readout said AIMING, and a
# trail of scent went down behind you anyway. Every machine and pillager on
# patrol or investigating within 170 units smells that list, so you were hunted
# along a trail you never made, at the two moments you are slowest and least
# able to leave. v12.33 stopped DRAWING your own marks, which is his note; this
# is the half that survives it, and it is the half that gets you killed.
#
# The block simply moves below the two cancels, so it reads the final answer.
SubRx @'
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
  if(sprint&&mg>0){
    G.prints=G.prints||[];
    var _lpr=G.prints.length?G.prints[G.prints.length-1]:null;
    if(!_lpr||dist(p,_lpr)>34){
      // v8.85: mine, so the draw side can tell your own sprint trail from a
      // pillager's. The AI that smells this list does not care either way.
      G.prints.push({x:p.x,y:p.y,t:0,mine:1});
      if(G.prints.length>40) G.prints.shift();
    }
  }
  if(p.ads) sprint=false;
'@ @'
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
  // v12.71, 2026-09-07 audit: THE SCENT GOES DOWN BELOW THE CANCELS NOW. It was
  // laid here, above both of them, so Shift held while aiming or while wading
  // put a sprint trail behind a man who was not sprinting: aiming speed, no
  // stamina spent, the readout saying AIMING, and a line of scent going down
  // anyway. Everything on patrol or investigating within 170 units smells that
  // list, so he was hunted along a trail he never made, at the two moments he is
  // slowest and least able to leave. Moved below, where sprint is final.
  if(p.ads) sprint=false;
'@

SubRx @'
  var wading=inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset));
  if(wading) sprint=false;
  G.sprinting=sprint;
'@ @'
  var wading=inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset));
  if(wading) sprint=false;
  G.sprinting=sprint;
  // v12.71: and here is the trail, reading the sprint flag AFTER the aiming and
  // the deep-water cancels above have had their say. Same 34 units, same 40
  // mark ceiling, same mine flag; only the moment it is asked has moved.
  if(sprint&&mg>0){
    G.prints=G.prints||[];
    var _lpr=G.prints.length?G.prints[G.prints.length-1]:null;
    if(!_lpr||dist(p,_lpr)>34){
      // v8.85: mine, so the draw side can tell your own sprint trail from a
      // pillager's. The AI that smells this list does not care either way.
      G.prints.push({x:p.x,y:p.y,t:0,mine:1});
      if(G.prints.length>40) G.prints.shift();
    }
  }
'@

# NEW IN.
SubRx @'
  'A SEARCH CONTRACT NAMES A PLACE ON THE SECTOR YOU ARE PLAYING. It wrote the name down when the card was made, so changing sector afterwards left it pointing at a place with almost the right name in the wrong part of the map, and searching it moved nothing.',
'@ @'
  'A SEARCH CONTRACT NAMES A PLACE ON THE SECTOR YOU ARE PLAYING. It wrote the name down when the card was made, so changing sector afterwards left it pointing at a place with almost the right name in the wrong part of the map, and searching it moved nothing.',
  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL. Shift held while you aimed, or while you waded, laid scent behind a man who was not sprinting, and everything on patrol within 170 units follows that scent. You were being hunted along a trail you never made.',
'@

# STAMPS.
SubRx @'
var VER='12.70';
'@ @'
var VER='12.71';
'@
SubRx @'
var WHATSNEW_VER='12.70';
'@ @'
var WHATSNEW_VER='12.71';
'@
$cnt=([regex]::Matches($s,"now:'v12\.70:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.70 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.70:[^']*'",{ param($m) "now:'v12.71: 2026-09-07 audit (P3). The sprint flag is computed, then the scent marks are laid, and only then is the flag cancelled for aiming and for deep water. So Shift held while aiming, or while wading, laid a sprint trail behind a man who was not sprinting: he moved at the aiming speed, paid no stamina, the readout said AIMING, and a line of scent went down behind him anyway. Everything on patrol or investigating within 170 units smells that list, so he was hunted along a trail he never made, at the two moments he is slowest and least able to leave. v12.33 stopped drawing his own marks, which was his note; this is the half that survives it, and it is the half that gets him killed. The block moves below both cancels so it reads the final answer, with the same 34 unit spacing, the same 40 mark ceiling and the same flag; only the moment it is asked has moved. The bot never runs this function at all, so no paired number can move. Check 12.71 walks him with the aim held and requires no mark of his own to be laid, walks him wading and requires the same, and controls that a plain sprint on dry land still lays them; fails on v12.70.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
