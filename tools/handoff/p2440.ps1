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

# HOSTILE GLARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95); wc.stroke(); wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.5,2.6,3.1,0,3.47,5.97); wc.stroke(); wc.fillStyle=INK; wc.fillRect(hx2-6.3,ty-31.5,1.5,0.9); wc.fillRect(hx2+4.8,ty-31.5,1.5,0.9); }   // v20.01: Curved, lashes
'@ @'
  if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95); wc.stroke(); wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.5,2.6,3.1,0,3.47,5.97); wc.stroke(); wc.fillStyle=INK; wc.fillRect(hx2-6.3,ty-31.5,1.5,0.9); wc.fillRect(hx2+4.8,ty-31.5,1.5,0.9); }   // v20.01: Curved, lashes
  // v23.xx (spr23), HIS CALL (2026-10-12, the sprite design: "hostile glare"; ship with a side by side picture so he can veto it):
  // a hostile pillager looked exactly as friendly as you, the same big round eyes. A foe pillager (team foe, not a hire) now has
  // an upper lid cutting each eye to an almond, slanting down toward the nose, and a dark brow bar along it: a glare. Everyone else
  // (you, your team, hires, the Undercroft, the Peddler, the Survivor) keeps the round eyes, and the pupils still follow the aim
  // under the lid. His face ruling stands: the face and the eyes stay, only the lids change. Cosmetic only.
  if(st.team==='foe'&&!st.merc&&!(st.own&&(st.own.merc||st.own.friendly))&&!st.hero&&!(OUTF&&/^(skeleton|robot|android)$/.test(OUTF.mark))){
    var _gk=(OUTF&&OUTF.skin)?OUTF.skin:(SKINCOL[st.skin]||'#f2d2a8'), _gs, _ex;
    for(_gs=-1;_gs<=1;_gs+=2){
      _ex=hx2+_gs*3.4;
      wc.fillStyle=_gk; wc.beginPath();
      wc.moveTo(_ex-2.9,ty-33.0); wc.lineTo(_ex+2.9,ty-33.0); wc.lineTo(_ex-_gs*2.9,ty-29.6); wc.closePath(); wc.fill();   // the upper lid, low at the nose
      wc.fillRect(_ex-2.9,ty-27.0,5.8,0.9);                                                                                 // and the lower lid
      wc.strokeStyle=INK; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(_ex+_gs*2.9,ty-32.6); wc.lineTo(_ex-_gs*2.6,ty-29.9); wc.stroke();   // the brow bar
    }
  }
'@

SubRx @'
var VER='24.39';
'@ @'
var VER='24.40';
'@

$pat = "(?m)^  now:'v24\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.40: Hostile pillagers glare: brow bars over narrowed eyes. Everyone friendly keeps round eyes. Check 24.40 fails on v24.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
