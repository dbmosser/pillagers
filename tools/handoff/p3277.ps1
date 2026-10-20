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

# THE TROPHY CASE FILLS ITS CARD WITH A FOCUS RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  '#trophymodal .trgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(236px,1fr));gap:14px 12px;flex:1;min-height:0;overflow-y:auto;padding:6px 4px 10px 2px;align-content:start}'+
  '.trp{position:relative;display:flex;flex-direction:column;align-items:center;text-align:center;padding:14px 12px 14px;background:linear-gradient(rgba(255,255,255,.035),rgba(0,0,0,.34));border:1px solid var(--ui-line-hi);border-bottom:6px solid var(--tc,#55524c);clip-path:polygon(12px 0,100% 0,100% 100%,0 100%,0 12px)}'+
  '.trp svg{width:66px;height:66px;margin-bottom:6px}'+
  '.trp.no svg{opacity:.26}'+
  '.trp .trn{font-family:var(--f-cond);font-weight:700;font-size:21px;letter-spacing:.06em;text-transform:uppercase;color:var(--tx-1);line-height:1.1}'+
  '.trp.no .trn{color:var(--tx-3)}'+
  '.trp .trd{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:.1em;text-transform:uppercase;color:var(--tx-2);margin-top:4px}'+
  '.trp .trw{font-family:var(--f-cond);font-weight:700;font-size:13px;letter-spacing:.14em;text-transform:uppercase;color:var(--tc,#55524c);margin-top:7px}');

'@ @'
  // v28.xx (cw-trophygrid), the critic scored the trophy case 2 of 5 (2026-10-18, 2026-10-20: "two thirds empty, the grid orphans a single card on row two, nothing shows focus, the header stats are crude, the tiles are gradient washes with a corner tick and dim locked text"). Four equal columns, so eight trophies are two full rows that fill the card; the cards are flat panels (guide: Panel P, 4 px radius, no gradient, no tick) with a bigger cup (96 px), name 28, line 20 and date 16 in tx-2 (the guide floor is 16, the date no longer takes the rarity colour, the bar does). A card is a button so Tab and the pad can land on it, and the focused one gets the lime ring. The money, xp and stash readout of the top right is hidden while the case is open (it is not about trophies).
  '#trophymodal .trgrid{display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:minmax(200px,1fr);gap:var(--sp-3);flex:1;min-height:0;overflow-y:auto;padding:var(--sp-1) var(--sp-1) var(--sp-2);align-content:stretch}'+
  '.trp{position:relative;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;gap:var(--sp-1);padding:var(--sp-3) var(--sp-2);margin:0;min-width:0;min-height:0;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-bottom:3px solid var(--tc,#55524c);border-radius:var(--rad);clip-path:none;cursor:default;font:inherit}'+
  '.trp:hover{background:var(--ui-raised)}'+
  '.trp:focus,.trp:focus-visible{outline:2px solid var(--acc);outline-offset:2px;background:var(--ui-raised)}'+
  '.trp svg{width:96px;height:96px;margin:0}'+
  '.trp.no svg{opacity:.4}'+
  '.trp .trn{font-family:var(--f-cond);font-weight:700;font-size:28px;letter-spacing:.04em;color:var(--tx-1);line-height:1.1}'+
  '.trp.no .trn{color:var(--tx-2)}'+
  '.trp .trd{font-family:var(--f-cond);font-weight:600;font-size:20px;letter-spacing:.04em;color:var(--tx-2);margin:0}'+
  '.trp .trw{font-family:var(--f-cond);font-weight:600;font-size:16px;letter-spacing:.04em;color:var(--tx-2);margin:0}'+
  'body:has(#trophymodal.on) #topright{display:none !important}');
'@

SubRx @'
    h+='<div class="trp '+(has?'yes':'no')+'" data-trophy="'+T.id+'" style="--tc:'+col+'">'+trophyCup(col)+

'@ @'
    h+='<button type="button" class="trp '+(has?'yes':'no')+'" data-trophy="'+T.id+'" style="--tc:'+col+'">'+trophyCup(col)+

'@

SubRx @'
       '<div class="trn">'+escHtml(T.n)+'</div><div class="trd">'+escHtml(T.d)+'</div>'+
       '<div class="trw">'+(has?(ts&&isFinite(ts.getTime())?escHtml(ts.toLocaleDateString(undefined,{month:'short',day:'numeric'})).toUpperCase():'EARNED'):'LOCKED')+'</div></div>';

'@ @'
       '<div class="trn">'+escHtml(T.n)+'</div><div class="trd">'+escHtml(T.d)+'</div>'+
       '<div class="trw">'+(has?(ts&&isFinite(ts.getTime())?escHtml(ts.toLocaleDateString(undefined,{month:'short',day:'numeric'})).toUpperCase():'EARNED'):'LOCKED')+'</div></button>';

'@

SubRx @'
var VER='32.76';
'@ @'
var VER='32.77';
'@

$pat = "(?m)^  now:'v32\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.77: The trophy case is two full rows of big cards, the focused card has a lime ring and the top right money readout is out of the way. Check 32.77 fails on v32.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
