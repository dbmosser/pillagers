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

# HIS NOTES, 2026-09-05: "cooking grenades should give more warning before
# exploding in your hand, need a message with 1 sec left like COOKED GRENADE!
# THROW GRENADE NOW" and "COOKING A GRENADE SHOULD COUNT down, NOT UP!!!". He
# died to his own charge in both runs that night. The in-hand readout already
# counts down (COOKING 0.8s, and a shrinking bar); what it never did was
# shout. FRAG_FUSE is 1.1 seconds and is NOT moved here (his order: no in-raid
# balancing before alpha); with that fuse the last second is nearly the whole
# cook, which is the finding, and the shout is honest about it.

# 1. THE WORDS, in one place, before the HUD draw.
SubRx @'
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@ @'
// v11.55, HIS NOTE: the last second of a cooked frag, in his words. One place,
// so the draw and the check read the same line.
function cookShout(p){
  if(!p||!p.cooking||p.cookKind!=='frag') return null;
  var left=FRAG_FUSE-(p.cookT||0);
  return left<=1.0?'COOKED GRENADE! THROW GRENADE NOW':null;
}
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@

# 2. THE SHOUT ON SCREEN, above the countdown, flashing.
SubRx @'
      if(isFrag) bar(cs2.x-24,cs2.y-LH(22),48,4,1-cf,ccol);
    }
  }
'@ @'
      if(isFrag) bar(cs2.x-24,cs2.y-LH(22),48,4,1-cf,ccol);
      // v11.55, HIS NOTE: the last second shouts. Drawn above the countdown at
      // the operator, where his eyes are, in the head size and flashing.
      var _cshout=cookShout(p);
      if(_cshout){
        ctx.font=FS(TYPE.head); ctx.textAlign='center';
        ctx.fillStyle=(Math.floor(G.t*8)%2)?'#ff5a4a':'#fff0c0';
        var _csw=ctx.measureText(_cshout).width;
        ctx.fillStyle='rgba(6,9,13,.78)';
        ctx.fillRect(cs2.x-_csw/2-8,cs2.y-LH(62),_csw+16,LH(22));
        ctx.fillStyle=(Math.floor(G.t*8)%2)?'#ff5a4a':'#fff0c0';
        ctx.fillText(_cshout,cs2.x,cs2.y-LH(46));
        ctx.font=FS(TYPE.micro); ctx.textAlign='left';
      }
    }
  }
'@

# STAMPS.
SubRx @'
var VER='11.54';
'@ @'
var VER='11.55';
'@
SubRx @'
var WHATSNEW_VER='11.54';
'@ @'
var WHATSNEW_VER='11.55';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A COOKED GRENADE SHOUTS FOR ITS LAST SECOND: COOKED GRENADE! THROW GRENADE NOW, above the countdown. The fuse is still 1.1 seconds, so that is most of the cook; say the number you want and it changes.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.54:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.54 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.54:[^']*'",{ param($m) "now:'v11.55: HIS NOTES of 2026-09-05, a cooked grenade needs a shout with a second left, and the count must go down. The readout already counted down; nothing shouted. cookShout(p) owns his line for the last second of a frag in hand and drawHUD draws it flashing above the countdown. FRAG_FUSE stays 1.1 s (no balancing before alpha), so the shout covers nearly the whole cook, which is the finding: he died to his own charge twice that night. Check 11.55 reads cookShout at half a second left, controls a smoke and an empty hand, and requires drawHUD to read it.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
