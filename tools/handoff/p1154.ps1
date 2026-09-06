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

# HIS NOTE, 2026-09-05 in-run at 53 s of his second run: "'EXTRACTION - OPEN'
# IS CONFUSING... POSSIBLE STATES FOR AN EXTRACTION POINT SHOULD INSTEAD BE"
# and his four lines. The ring badge said OPEN for three different situations
# (nothing called yet, called and inbound, landed and waiting) and CLOSED with
# a whisper under it. It says which of his four states the ring is in now, in
# his words, with the live seconds where he wrote 30S. One function owns the
# words so the badge can never disagree with the clock.

# 1. THE FOUR STATES, in one place, before the HUD draw.
SubRx @'
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@ @'
// v11.54, HIS NOTE: the four states of an extraction point, in his words.
// Nothing called yet; called and inbound (the beacon clock); landed and open
// for the hold window (the ship clock); closed for the raid.
function zoneBadge(z){
  if(!z.open) return 'EXTRACTION POINT - CLOSED FOR THE REMAINDER OF THIS RAID';
  if(z.beaconT===null||z.beaconT===undefined) return 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN';
  if(z.beaconT>0) return 'EXTRACTION POINT - '+Math.max(0,Math.ceil(z.beaconT))+'S UNTIL EXTRACTION BEGINS';
  if(z.hold!==null&&z.hold!==undefined) return 'EXTRACTION POINT - EXTRACT NOW! '+Math.max(0,Math.ceil(z.hold))+'S UNTIL EXTRACTION ENDS';
  return 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN';
}
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@

# 2. THE BADGE READS IT. The closed whisper is folded into his CLOSED line.
SubRx @'
    var zlab=za?'EXTRACTION - OPEN':'EXTRACTION - CLOSED';
    ctx.font=FS(TYPE.label);
    var zwid=ctx.measureText(zlab).width;
    // v10.90, HIS NOTE: this is the label in his screenshot, drawn straight
    // through SUPPORT MG. It is lifted clear of the corner readout instead.
    var zsy=hudDodge(zs.x,zs.y,zwid/2+6,LH(15),za?0:LH(13));
'@ @'
    var zlab=zoneBadge(zz2);   // v11.54, HIS NOTE: his four states, his words
    ctx.font=FS(TYPE.label);
    var zwid=ctx.measureText(zlab).width;
    // v10.90, HIS NOTE: this is the label in his screenshot, drawn straight
    // through SUPPORT MG. It is lifted clear of the corner readout instead.
    var zsy=hudDodge(zs.x,zs.y,zwid/2+6,LH(15),0);
'@
SubRx @'
    ctx.fillText(zlab,zs.x,zsy);
    if(!za){
      ctx.font=FS(TYPE.micro);
      ctx.fillStyle='rgba(168,180,193,.7)';
      ctx.fillText('this one will not call',zs.x,zsy+LH(13));
    }
  }
'@ @'
    ctx.fillText(zlab,zs.x,zsy);
    // v11.54: the closed whisper ("this one will not call") is inside his
    // CLOSED FOR THE REMAINDER OF THIS RAID line now.
  }
'@

# STAMPS.
SubRx @'
var VER='11.53';
'@ @'
var VER='11.54';
'@
SubRx @'
var WHATSNEW_VER='11.53';
'@ @'
var WHATSNEW_VER='11.54';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'EXTRACTION POINTS SAY WHICH STATE THEY ARE IN. Sound the alarm to begin the countdown; N seconds until extraction begins; extract now, N seconds until it ends; closed for the remainder of this raid. Your four lines, with the live clock.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.53:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.53 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.53:[^']*'",{ param($m) "now:'v11.54: HIS NOTE of 2026-09-05, EXTRACTION - OPEN is confusing. The ring badge said OPEN for three situations and CLOSED with a whisper under it. zoneBadge(z) owns his four lines (sound the alarm to begin countdown; NS until extraction begins; extract now! NS until extraction ends; closed for the remainder of this raid) with the live beacon and hold clocks, and the badge draws it. Check 11.54 stages a zone through all four states, requires each of his lines with the right seconds, and controls that the HUD draw reads zoneBadge.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
