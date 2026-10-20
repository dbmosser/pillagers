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

# GOLDEN KILL NAMES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function goldDrop(x,y){
'@ @'
// v28.xx (cw-cx-goldnames), HIS ANSWER 3.84 b: "Always the specific name"; raider is pillager bot under his words rule.
function goldDownName(kind){ return 'golden '+(kind==='raider'?'pillager bot':(GOLD.kinds[kind]?kind:'enemy'))+' down'; }
function goldDrop(x,y,kind){
'@

SubRx @'
  try{ say('GOLDEN ENEMY DOWN','obj',{sub:'SEARCH THE HOARD'}); }catch(_gs){}
'@ @'
  try{ say(goldDownName(kind),'obj',{sub:'SEARCH THE HOARD'}); }catch(_gs){}
'@

SubRx @'
  if(e&&!S.dead&&(!(e.hp>0)||G.ents.indexOf(e)<0)){ S.dead=1; S.dx=e.x; S.dy=e.y; goldDrop(e.x,e.y); }
'@ @'
  // v28.xx (cw-cx-goldnames): retain the kind after the body is removed, for both windows.
  if(e&&!S.dead&&(!(e.hp>0)||G.ents.indexOf(e)<0)){ S.dead=1; S.dx=e.x; S.dy=e.y; S.kind=e.kind; goldDrop(e.x,e.y,e.kind); }
'@

SubRx @'
  if(S.dead) return [0,1,Math.round(+S.dx||0),Math.round(+S.dy||0)];
'@ @'
  // v28.xx (cw-cx-goldnames): the death word carries the kind even when the linked window never saw the body.
  if(S.dead) return [0,1,Math.round(+S.dx||0),Math.round(+S.dy||0),S.kind||(S.ref&&S.ref.kind)||''];
'@

SubRx @'
      S.dead=1; S.dx=+a[2]||0; S.dy=+a[3]||0;
'@ @'
      // v28.xx (cw-cx-goldnames): accept older four-field words using the mirrored body when available.
      S.dead=1; S.dx=+a[2]||0; S.dy=+a[3]||0; S.kind=GOLD.kinds[a[4]]?a[4]:(S.ref&&S.ref.kind)||'enemy';
'@

SubRx @'
      try{ spark(S.dx,S.dy,'#ffc72e',30,320); flash(S.dx,S.dy,260,'#ffc72e',.5); say('GOLDEN ENEMY DOWN','obj',{sub:'SEARCH THE HOARD'}); }catch(_gd){}
'@ @'
      try{ spark(S.dx,S.dy,'#ffc72e',30,320); flash(S.dx,S.dy,260,'#ffc72e',.5); say(goldDownName(S.kind),'obj',{sub:'SEARCH THE HOARD'}); }catch(_gd){}
'@

SubRx @'
// GOLDEN ENEMY DOWN in the alert. If nothing qualifies at 3 s it looks again every second. DEMO and CAREER are the same.
'@ @'
// v28.xx (cw-cx-goldnames): the specific golden kind down in the alert. If nothing qualifies at 3 s it looks again every second. DEMO and CAREER are the same.
'@

SubRx @'
// (t fl, k clue), which marks it taken for everyone and shrinks the circle; so either of them can find the golden enemy. When it falls, GOLDEN ENEMY DOWN is said in both windows and the
'@ @'
// v28.xx (cw-cx-goldnames): (t fl, k clue) marks it taken for everyone and shrinks the circle; when the golden enemy falls, the specific kind down is said in both windows and the
'@

SubRx @'
var VER='33.06';
'@ @'
var VER='33.07';
'@

$pat = "(?m)^  now:'v33\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.07: Golden kill callouts name the fallen kind in both windows and keep search the hoard. Check 33.07 fails on v33.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
