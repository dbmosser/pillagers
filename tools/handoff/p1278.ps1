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
# v9.71 added a guard the surrender did not have: while an extraction is waiting
# on the point you are lying in, the space bar cannot end your raid, because the
# same overlay is telling you that extracting while downed is permitted and a
# hand resting on that key must not throw away a full backpack. The guard is
# right. Nothing told him about it. The surrender row is drawn on one test, that
# he has spent his revive, so in that state the screen printed HOLD SPACE TO
# SURRENDER, the key did nothing, the bar never appeared, and no line explained
# why. A dead control and a prompt that lies.
#
# The guard becomes one named test with two readers, so the key and the screen
# can never disagree about it again, and the row says what is true instead.
SubRx @'
function giveUpTick(dt){
'@ @'
// v12.78, 2026-09-07 audit: ONE TEST, TWO READERS. The rule below was written
// into giveUpTick alone, so the overlay that offers the surrender knew nothing
// about it and printed the prompt anyway: the key did nothing, the bar never
// appeared, and no line said why. Both read this now.
function surrenderBlocked(){
  var p=G&&G.player; if(!p) return false;
  return !!(G.active&&G.beaconT!==null&&G.beaconT!==undefined&&G.beaconT<=0&&
    G.shipHold!==null&&G.shipHold!==undefined&&dist(p,G.active)<G.active.r);
}
function giveUpTick(dt){
'@

SubRx @'
  if(G.active&&G.beaconT!==null&&G.beaconT!==undefined&&G.beaconT<=0&&
     G.shipHold!==null&&G.shipHold!==undefined&&dist(p,G.active)<G.active.r){
    p.giveT=0; return false;
  }
'@ @'
  if(surrenderBlocked()){ p.giveT=0; return false; }   // v12.78: the same test the overlay reads
'@

SubRx @'
    if(p.revived&&CFG.giveUp!==0){
      var _gp=Math.min(1,(p.giveT||0)/GIVEUP_HOLD());
      _rowY+=Math.round(_hD*1.25);
      ctx.font=_fD; ctx.fillStyle=_gp>0?'#ff8a76':'#9b8f8c';
      ctx.fillText('HOLD ['+keyLabel('Space','SPACE')+'] TO SURRENDER',W/2,_rowY);
'@ @'
    if(p.revived&&CFG.giveUp!==0){
      var _gp=Math.min(1,(p.giveT||0)/GIVEUP_HOLD());
      _rowY+=Math.round(_hD*1.25);
      // v12.78, 2026-09-07 audit: AND IT SAYS SO WHEN IT WILL NOT TAKE THE KEY.
      // The v9.71 guard refuses the surrender while an extraction is waiting on
      // the point he is lying in, silently: this row printed the prompt anyway,
      // the key did nothing, the bar never appeared and nothing explained it. It
      // reads the same test the key reads now, and says what is true, with the
      // working verb still drawn underneath it in colour.
      ctx.font=_fD; ctx.fillStyle='#9b8f8c';
      if(surrenderBlocked()) ctx.fillText('NO SURRENDER WITH AN EXTRACTION WAITING',W/2,_rowY);
      else{
      ctx.fillStyle=_gp>0?'#ff8a76':'#9b8f8c';
      ctx.fillText('HOLD ['+keyLabel('Space','SPACE')+'] TO SURRENDER',W/2,_rowY);
      }
'@

# NEW IN.
SubRx @'
  'THE PRICE OF WALKING OUT IS THE PRICE YOU ACTUALLY PAY. The confirm button quoted a fine of a hundred or more XP to players who did not have it, and the line afterwards announced taking it, when the fine has always stopped at zero and took nothing.',
'@ @'
  'THE PRICE OF WALKING OUT IS THE PRICE YOU ACTUALLY PAY. The confirm button quoted a fine of a hundred or more XP to players who did not have it, and the line afterwards announced taking it, when the fine has always stopped at zero and took nothing.',
  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER IT WILL NOT TAKE. With an extraction waiting on the point you are lying in, the space bar is refused on purpose so a resting hand cannot throw away a full backpack. It now says so instead of printing a dead prompt.',
'@

# STAMPS.
SubRx @'
var VER='12.77';
'@ @'
var VER='12.78';
'@
SubRx @'
var WHATSNEW_VER='12.77';
'@ @'
var WHATSNEW_VER='12.78';
'@
$cnt=([regex]::Matches($s,"now:'v12.77:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.77 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12.77:[^']*'",{ param($m) "now:'v12.78: 2026-09-07 audit (P3). v9.71 gave the surrender a guard it did not have: while an extraction is waiting on the point he is lying in, the space bar cannot end his raid, because the same overlay is telling him that extracting while downed is permitted and a hand resting on that key must not throw away a full backpack. The guard is right and nothing told him about it. The surrender row is drawn on one test, that he has spent his revive, so in that state the screen printed HOLD SPACE TO SURRENDER, the key did nothing, the progress bar never appeared because it is drawn only once the hold has started, and no line explained the refusal: a dead control and a prompt that lies, at three health with the point swarmed. The guard is now one named test with two readers, so the key and the screen can never disagree about it again, and the row says what is true instead, with the working verb still drawn underneath it in colour. Check 12.78 puts him down with his revive spent inside a point with an extraction waiting, holds the real key for two seconds through the real frame loop, and requires the hold never to start and the drawn text to carry the refusal and not the prompt, with a control outside that state requiring the prompt to be drawn and the hold to run; fails on v12.77.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
