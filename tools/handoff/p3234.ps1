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

# THE TITLE MUSIC PLAYS THREE VARIATIONS IN TURN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function musNote(a,t,step){

'@ @'
// v28.xx (cw-musicvar), HIS ANSWER 2.70 c (the idle loop over a long night): "use three variations of the piece in turn". THE ASCENT plays its
// eight bars three ways, one after the other: as written, then with the tune started half a bar later in each bar, then a quarter bar later.
// Same notes, same chords, same kit, so it is still the one piece; only where the tune lands moves. MUS.pass is 0, 1, 2 and round again.
function musVarShift(pass){ return [0,8,4][(((pass|0)%3)+3)%3]; }
function musLeadAt(T,B,si){ return (T&&T.title)?B.lead[(si+musVarShift(MUS.pass))%16]:B.lead[si]; }
// the step after this one, and the pass it belongs to: the pass moves on each time the eight bars come round
function musAdvance(step,len,pass,T){
  var s=(step+1)%len, p=pass|0;
  if(s===0&&T&&T.title) p=(p+1)%3;
  return {step:s,pass:p};
}
function musNote(a,t,step){

'@

SubRx @'
  var m=B.lead[si];

'@ @'
  var m=musLeadAt(T,B,si);   // v28.xx (cw-musicvar): the tune of this pass

'@

SubRx @'
    MUS.step=(MUS.step+1)%_len;

'@ @'
    var _adv=musAdvance(MUS.step,_len,MUS.pass,T); MUS.step=_adv.step; MUS.pass=_adv.pass;   // v28.xx (cw-musicvar): three variations in turn

'@

SubRx @'
var VER='32.33';
'@ @'
var VER='32.34';
'@

$pat = "(?m)^  now:'v32\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.34: The title and idle music changes its tune placement every pass through three variations. Check 32.34 fails on v32.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
