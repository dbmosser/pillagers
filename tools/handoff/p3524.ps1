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

# BUILD DATE ON THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// WHAT CHANGED SINCE HE LAST PLAYED, v2.76. His last recorded runs were v2.43
'@ @'
var VER_AT='';   // v35.xx (cw-verat), HIS ORDER (2026-10-27): "also put the date and time of the update, in us eastern time". ship.sh stamps it (yyyy-mm-dd hh:mm, Eastern) at every ship; empty in an unshipped copy.
// WHAT CHANGED SINCE HE LAST PLAYED, v2.76. His last recorded runs were v2.43
'@

SubRx @'
function buildExport(){
'@ @'
// v35.xx (cw-verat): the build date beside the player number on the title, " . oct 27 7:40 pm et"; nothing when the copy carries no stamp.
function verAtSay(){
  var m=/^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d)$/.exec(typeof VER_AT==='string'?VER_AT:''), mo, h;
  if(!m) return '';
  mo=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'][(+m[2])-1]; if(!mo) return '';
  h=+m[4];
  return ' \u00b7 '+mo+' '+(+m[3])+' '+(h%12||12)+':'+m[5]+' '+(h<12?'am':'pm')+' et';
}
function titleVerSync(){ var t=document.getElementById('titlever'); if(t) t.textContent=verShown(VER)+verAtSay(); return t?t.textContent:''; }
function buildExport(){
'@

SubRx @'
document.getElementById('titlever').textContent=verShown(VER);
'@ @'
titleVerSync();
'@

SubRx @'
L.push('=== PILLAGERS '+verShown(VER)+' (build '+VER+') FLIGHT RECORDER ===');
'@ @'
L.push('=== PILLAGERS '+verShown(VER)+' (build '+VER+((typeof VER_AT==='string'&&VER_AT)?', '+VER_AT+' ET':'')+') FLIGHT RECORDER ===');   // v35.xx (cw-verat): the build date too, so an export says when his copy was built
'@

SubRx @'
var VER='35.23';
'@ @'
var VER='35.24';
'@

$pat = "(?m)^  now:'v35\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.24: the title shows when your build was made, us eastern Check 35.24 fails on v35.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
