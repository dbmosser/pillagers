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

# A WAITING TRADE OFFER IS TAKEN FIRST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netGiftKey(){
  var s, st, S, k, it, nm, gi;
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||G.player.downed) return false;
  if(G.bagOpen){
'@ @'
function netGiftKey(){
  var s, st, S, k, it, nm, gi;
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||G.player.downed) return false;
  // v18.20, HIS NOTE (2026-10-03, "still not clear how trading works"): A WAITING OFFER IS TAKEN FIRST. With his own backpack open,
  // the receiver's T (or Y) started an offer of his own and the one waiting for him ran out; the prompt had told him to press T.
  // An open offer to this player is answered before anything else; with none waiting the key offers as before.
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('Taking it.'); return true; }
  if(G.bagOpen){
'@

SubRx @'
var VER='18.19';
'@ @'
var VER='18.20';
'@

$pat = "(?m)^  now:'v18\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.20: Pressing T or Y with a trade offer waiting always takes it, even with your backpack open. Check 18.20 fails on v18.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
