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

# RUN OVER CARD: SCORE LABEL, DIM ZERO, WARN PENALTY, INSET RULE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage, body #attract .arcover{ background-image:linear-gradient(var(--ui-line), var(--ui-line)); background-repeat:no-repeat; background-size:calc(100% - var(--sp-5) * var(--attz,1)) 1px; background-position:center calc(100% - (var(--sp-3) + var(--btn-h) + var(--sp-2)) * var(--attz,1)); }

'@ @'
body #attract .arcpage, body #attract .arcover{ background-image:linear-gradient(var(--ui-line), var(--ui-line)); background-repeat:no-repeat; background-size:calc(100% - var(--sp-4) * 2 * var(--attz,1)) 1px; background-position:center calc(100% - (var(--sp-3) + var(--btn-h) + var(--sp-2)) * var(--attz,1)); }
/* v31.xx (cw-partylook8), the critic on 55 (3 of 5, after v31.73) and 64 (2 of 5): "the hero is one white line, score and the number are the same size: a 16px tx-2 score label above the 56px figure", "dim a zero result to tx-2", "the bottom divider runs wider (626 to 1293) than the top one (634 to 1286): inset it to the content margin", "colour the -50% in warn", "left-align the empty state". The footer rule is inset to the 32px card padding (it was 24px), so it meets the stats rule edge to edge; the score word is a small label over the figure (the text is the same, only split in two spans), a zero score is tx-2, the penalty on the second line is warn amber, and the no scores yet line sits on the left edge like every other row. Restyle only. */
body #attract .arcover .aos .aolb{ display:block; font-size:max(16px, calc(var(--fs-label) * var(--attz,1))); line-height:1.4; font-weight:600; letter-spacing:var(--track); color:var(--tx-2); margin-bottom:calc(var(--sp-1) * var(--attz,1)); }
body #attract .arcover .aos.aoz{ color:var(--tx-2) !important; }
body #attract .arcover .aoh .aow{ color:var(--warn); }
body #attract .arcpage .apn{ text-align:left; }

'@

SubRx @'
function arcadeOverCount(c,o){

'@ @'
// v31.xx (cw-partylook8): the hero is a small label span over the figure; the text read is unchanged (SCORE 0 SP).
function arcadeHeroSet(el,t){
  var m=/^(\D*?)(\d.*)$/.exec(String(t)), a;
  el.textContent='';
  if(m&&m[1].replace(/\s/g,'')){ a=document.createElement('span'); a.className='aolb'; a.textContent=m[1]; el.appendChild(a); el.appendChild(document.createTextNode(m[2])); }
  else el.appendChild(document.createTextNode(String(t)));
  return el;
}
function arcadeOverCount(c,o){

'@

SubRx @'
  if(el.textContent!==t) el.textContent=t;

'@ @'
  if(el.textContent!==t||!el.querySelector('.aolb')) arcadeHeroSet(el,t);   // v31.xx (cw-partylook8)
  el.classList.toggle('aoz',!((+o.team||0)>0));

'@

SubRx @'
    for(i=0;i<ln.length;i++){ if(!ln[i][1]) continue; el=document.createElement('div'); el.className=ln[i][0]; el.textContent=ln[i][1]; c.appendChild(el); }

'@ @'
    for(i=0;i<ln.length;i++){ if(!ln[i][1]) continue; el=document.createElement('div'); el.className=ln[i][0]; el.textContent=ln[i][1];
      if(ln[i][0]==='aoh'&&/ -50%$/.test(ln[i][1])){ el.textContent=ln[i][1].replace(/-50%$/,''); var _aw=document.createElement('span'); _aw.className='aow'; _aw.textContent='-50%'; el.appendChild(_aw); }   // v31.xx (cw-partylook8): the penalty in warn amber
      c.appendChild(el); }

'@

SubRx @'
var VER='31.76';
'@ @'
var VER='31.77';
'@

$pat = "(?m)^  now:'v31\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.77: The run over card has a small score label over the big figure, a zero score is dim, the penalty is amber, and the rules line up. Check 31.77 fails on v31.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
