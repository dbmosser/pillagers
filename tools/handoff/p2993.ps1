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

# Party pages: key caps, ghost board rows, a see-through backdrop (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage.uimghost{ position:absolute; grid-column:1; grid-row:2; left:auto; top:auto; transform:none; order:1; }
'@ @'
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage.uimghost{ position:absolute; grid-column:1; grid-row:2; left:auto; top:auto; transform:none; order:1; }
/* v29.93 (cw-partykeys), the critic on v29.92 (46 = 3, 56 = 2, 64 = 2): "action names dim and 45px apart, keys are bare letters, Hold X in a teal ring is a sentence, the empty board is a card in a void with nothing behind it". Names are light, rows are 56px x scale, keys are key caps (1px line, 4px radius), the ring is a glyph, an empty board shows five ghost rows, the backdrop lets the world through and the wordmark steps back while a page is up. Restyle only. */
body #attract{ background:radial-gradient(ellipse at 50% 38%, color-mix(in srgb, var(--ui-raised) 40%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 88%, transparent) 46%, color-mix(in srgb, var(--ui-void) 96%, transparent) 100%); }
body #attract .arcpage .apk{ color:var(--tx-1); font-weight:600; }
body #attract .arcpage th{ font-size:calc(var(--fs-label) * var(--attz,1)); color:var(--tx-2); font-weight:600; }
body #attract .arcpage td{ height:calc(var(--btn-h) * var(--attz,1)); padding-top:0; padding-bottom:0; vertical-align:middle; }
body #attract .arcpage .apkc{ display:inline-flex; align-items:center; box-sizing:border-box; height:calc(var(--sp-4) * var(--attz,1)); padding:0 calc(var(--sp-1) * var(--attz,1)); margin-right:calc(var(--sp-1) * var(--attz,1)); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font-weight:700; color:var(--tx-1); }
body #attract .arcpage .aprg{ display:inline-block; vertical-align:middle; box-sizing:border-box; width:calc(var(--sp-3) * var(--attz,1)); height:calc(var(--sp-3) * var(--attz,1)); border:3px solid var(--extract); border-radius:50%; }
body #attract .arcpage .apr, body #attract .arcpage .apg{ align-items:center; min-height:calc(var(--btn-h) * var(--attz,1)); border-bottom:1px solid var(--ui-line); }
body #attract .arcpage .apg{ display:flex; justify-content:space-between; gap:calc(var(--sp-4) * var(--attz,1)); color:var(--tx-2); opacity:.4; }
body #attract:has(.arcpage[style*="block"]) .attname, body #attract:has(.arcover[style*="block"]) .attname{ color:var(--tx-2); }
'@

SubRx @'
  if(!rows.length) arcadeAttLine(pg,'apn','NO SCORES YET');
'@ @'
  if(!rows.length){ arcadeAttLine(pg,'apn','NO SCORES YET'); for(i=0;i<5;i++) arcadeAttLine(pg,'apg',(i+1)+'.  ---','--'); }   /* v29.93 (cw-partykeys) critic 56 (2 of 5): an empty board was a card holding one line. Five ghost rows give it its shape */
'@

SubRx @'
    c=tr.insertCell(); c.textContent=rw[1];
    c=tr.insertCell(); c.textContent=rw[2];
'@ @'
    c=tr.insertCell(); arcadeAttKeys(c,rw[1]);
    c=tr.insertCell(); arcadeAttKeys(c,rw[2]);
'@

SubRx @'
function arcadeAttHow(pg){
'@ @'
// v29.93 (cw-partykeys), critic 46 (3 of 5): "keys are bare letters, Hold X in a teal ring is an explaining sentence". A key cell is key caps (a pair like LB / RB is two caps), and the ring is a glyph.
function arcadeAttKeys(cell,txt){
  var s=String(txt||''), ring=/ IN A TEAL RING$/i.test(s), parts=s.replace(/ IN A TEAL RING$/i,'').split(' / '), i, k;
  cell.textContent='';
  for(i=0;i<parts.length;i++){ k=document.createElement('span'); k.className='apkc'; k.textContent=parts[i]; cell.appendChild(k); }
  if(ring){ k=document.createElement('i'); k.className='aprg'; cell.appendChild(k); }
}
function arcadeAttHow(pg){
'@

SubRx @'
var VER='29.92';
'@ @'
var VER='29.93';
'@

$pat = "(?m)^  now:'v29\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.93: How to play shows key caps, and the empty board shows ghost rows. Check 29.93 fails on v29.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
