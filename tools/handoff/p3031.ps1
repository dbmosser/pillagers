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

# SMALL ART TOUCHES: PACK BUCKLE, BOOT LACES, JERSEY SHADOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(_SCH){ wc.fillStyle=_SCH.a; wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2); }
'@ @'
  if(_SCH){ wc.fillStyle=_SCH.a; wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2); }
  // v28.xx (cw-smalltouch), HIS ANSWER 75 (2026-10-18): "Finish the small art touches." The plain pack was a flat brown block: it gets a dark lower seam, a strap down the flap and a steel buckle, all inside the old outline.
  if(/^#[0-9a-fA-F]{6}$/.test(_PKC)){
    var _pkx=x-fl*9+leanX;
    wc.fillStyle=darkHex(_PKC,.35); wc.fillRect(_pkx-pw/2+0.6,ty-14.2,pw-1.2,0.9); wc.fillRect(_pkx-0.5,ty-19.2,1.0,5.0);
    wc.fillStyle='#cfd5db'; wc.fillRect(_pkx-0.9,ty-16.6,1.8,1.5);
  }
'@

SubRx @'
    wc.fillStyle=litHex(_BT[1],.30); wc.fillRect(x+1.1+swing+_toe,ty-4.2-liftA,2.2,1.0);
'@ @'
    wc.fillStyle=litHex(_BT[1],.30); wc.fillRect(x+1.1+swing+_toe,ty-4.2-liftA,2.2,1.0);
    // v28.xx (cw-smalltouch), HIS ANSWER 75: "Finish the small art touches." Boots get two pale lace dots behind the toe cap, toward the facing.
    var _lc=(fl>0)?_toe-1.6:_toe+2.4;
    wc.fillStyle='#d8d4c4'; wc.fillRect(x-6.5+swing2+_lc,ty-3.9-liftB,1.0,0.75); wc.fillRect(x-6.5+swing2+_lc,ty-2.6-liftB,1.0,0.75); wc.fillRect(x+1.1+swing+_lc,ty-3.9-liftA,1.0,0.75); wc.fillRect(x+1.1+swing+_lc,ty-2.6-liftA,1.0,0.75);
'@

SubRx @'
wc.fillStyle='#f4f2ec';
    var _jy=ty-20;
    wc.fillRect(_jx+2.6,_jy,3.4,1.5); wc.fillRect(_jx+4.5,_jy,1.5,2.6); wc.fillRect(_jx+2.6,_jy+1.9,3.4,1.5); wc.fillRect(_jx+2.6,_jy+1.9,1.5,2.6); wc.fillRect(_jx+2.6,_jy+3.8,3.4,1.5);
    wc.fillRect(_jx+7.2,_jy,3.4,1.5); wc.fillRect(_jx+9.1,_jy,1.5,5.3); wc.fillRect(_jx+7.2,_jy+1.9,3.4,1.5); wc.fillRect(_jx+7.2,_jy+3.8,3.4,1.5);
'@ @'
    var _jy=ty-20, _jp, _jo;
    // v28.xx (cw-smalltouch), HIS ANSWER 75: "Finish the small art touches." The 23 gets a soft ink shadow down and to the right, so the number reads off the red shirt.
    for(_jp=0;_jp<2;_jp++){
      wc.fillStyle=_jp?'#f4f2ec':'rgba(20,22,27,.6)'; _jo=_jp?0:0.6;
      wc.fillRect(_jx+2.6+_jo,_jy+_jo,3.4,1.5); wc.fillRect(_jx+4.5+_jo,_jy+_jo,1.5,2.6); wc.fillRect(_jx+2.6+_jo,_jy+1.9+_jo,3.4,1.5); wc.fillRect(_jx+2.6+_jo,_jy+1.9+_jo,1.5,2.6); wc.fillRect(_jx+2.6+_jo,_jy+3.8+_jo,3.4,1.5);
      wc.fillRect(_jx+7.2+_jo,_jy+_jo,3.4,1.5); wc.fillRect(_jx+9.1+_jo,_jy+_jo,1.5,5.3); wc.fillRect(_jx+7.2+_jo,_jy+1.9+_jo,3.4,1.5); wc.fillRect(_jx+7.2+_jo,_jy+3.8+_jo,3.4,1.5);
    }
'@

SubRx @'
var VER='30.30';
'@ @'
var VER='30.31';
'@

$pat = "(?m)^  now:'v30\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.31: Packs, boots and the jersey number have finer drawn detail. Check 30.31 fails on v30.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
