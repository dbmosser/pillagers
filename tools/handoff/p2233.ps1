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

# THE CLOCK IN THE ALERT LANE, WITH A SHORT HINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(tlNow===30){ say('THIRTY SECONDS. '+outHint(1)); blip('clockwarn'); }
  else if(tlNow>0){
    say((tlNow/60)+' minute'+(tlNow===60?'':'s')+' left.'+(tlNow<=180?('  '+outHint(0)):''));
'@ @'
  // v22.33, the raid text rewrite (R10): THE CLOCK IN THE ALERT LANE, WITH A SHORT HINT. HIS ORDER (2026-10-09): the raid text reads
  // like a shooter HUD. THIRTY SECONDS and TEN SECONDS were one feed row of about seventy characters (the mark, then a sentence
  // about the way out) that the next remark pushed down; they are now alerts, THIRTY SECONDS a warning and TEN SECONDS a critical
  // line, with a clock glyph and the hint as their detail (at most 48 characters, outHint below). They share the key clock, so TEN
  // SECONDS takes the place of a THIRTY SECONDS still showing. The minute marks are objective feed rows, 3 MINUTES LEFT with the
  // hint as the detail from three minutes. The marks, their sounds and the frames they fire on are unchanged.
  if(tlNow===30){ say('THIRTY SECONDS','warn',{sub:outHint(1),key:'clock',icon:'clock'}); blip('clockwarn'); }
  else if(tlNow>0){
    say((tlNow/60)+' MINUTE'+(tlNow===60?'':'S')+' LEFT','obj',(tlNow<=180)?{sub:outHint(0)}:null);
'@

SubRx @'
    if(prev>10&&10>=now) say('TEN SECONDS. '+outHint(1));
'@ @'
    if(prev>10&&10>=now) say('TEN SECONDS','crit',{sub:outHint(1),key:'clock',icon:'clock'});   // v22.33 (R10)
'@

SubRx @'
function outHint(urgent){
'@ @'
function outHint(urgent){
  // v22.33, the raid text rewrite (R10): the hint is the detail under a clock alert, so it is one short sentence of at most 48
  // characters. It no longer says way out, is down or lands (the words of the extraction are extraction, inbound and extract), and
  // it names the use key through keyLabel, so on a controller it says [X]. Every branch of the v12.93 state machine is kept.
  var _K='['+keyLabel('KeyE','E')+']';
'@

SubRx @'
      return landed?('Your way out is down. Hold E to extract, '+Math.ceil(ac.hold)+'s left.')
                   :('Your way out is '+Math.ceil(ac.beaconT)+'s away. Stay in the ring.');
    return 'Your extraction is '+metres(din)+'m '+compass8(ac.x-G.player.x,ac.y-G.player.y)+'. '+
           (landed?('It leaves in '+Math.ceil(ac.hold)+'s.'):('It lands in '+Math.ceil(ac.beaconT)+'s.'));
'@ @'
      return landed?('Hold '+_K+' to extract, '+Math.ceil(ac.hold)+'s left.')
                   :('Extraction inbound in '+Math.ceil(ac.beaconT)+'s. Stay in the ring.');
    return 'Extraction '+metres(din)+'m '+compass8(ac.x-G.player.x,ac.y-G.player.y)+'. '+
           (landed?('Leaves in '+Math.ceil(ac.hold)+'s.'):('Inbound in '+Math.ceil(ac.beaconT)+'s.'));
'@

SubRx @'
  if(!no) return 'Every extraction point is closed.';
'@ @'
  if(!no) return 'Every extraction is closed.';
'@

SubRx @'
  if(no.d<no.z.r) return 'You are standing in the way out. Hold E to call it.';
'@ @'
  if(no.d<no.z.r) return 'Hold '+_K+' here to call for extraction.';
'@

SubRx @'
  return 'Nearest way out '+far+'m '+dir+'. Stand in it and hold E.';
'@ @'
  return 'Nearest extraction '+far+'m '+dir+'.';
'@

SubRx @'
var VER='22.32';
'@ @'
var VER='22.33';
'@

$pat = "(?m)^  now:'v22\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.33: THIRTY SECONDS and TEN SECONDS are alerts with one short hint that names your use key. Check 22.33 fails on v22.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
