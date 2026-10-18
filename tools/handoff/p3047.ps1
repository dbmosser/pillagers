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

# The demo kit stays the same all night (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var A=ARCADE_GUNS1.filter(function(k){ return !!WEAPONS[k]; }), a, B, b, k;
  a=A.length?A[Math.floor(Math.random()*A.length)]:'rifle';
  B=ARCADE_GUNS2.filter(function(k2){ return k2!==a&&!!WEAPONS[k2]; });
  b=B.length?B[Math.floor(Math.random()*B.length)]:null;
'@ @'
  var a, b, k, _pk=arcadePartyKit();
  a=_pk.a; b=_pk.b||null;   // v28.xx (cw-partykit), his answer Q67 (2026-10-18): "Same kit all night, and a new kit after NEW PARTY." The two guns are in the party record
'@

SubRx @'
function arcadeNewParty(){
  var _sd=((Math.random()*4294967296)>>>0)||1;   // v26.xx (party6): the night seed, picked as a raid picks its own
  try{ localStorage.setItem(ARCADE_PARTY_KEY,JSON.stringify({t:Date.now(),s:_sd,m:(ARCADE.mapIx|0)})); }catch(_np){ return false; }
'@ @'
// v28.xx (cw-partykit), his answer Q67 (2026-10-18): THE KIT IS THE SAME ALL NIGHT. The random kit (a gun in hand from ARCADE_GUNS1, a different one stowed
// from ARCADE_GUNS2) is drawn once and kept in the party record, so every drop, respawn and run of the night starts with it, in both windows; NEW PARTY
// draws the next one. Math.random only, as before. A record without a kit (no party yet, or an older record) gets one drawn the first time it is asked for.
function arcadeKitPickRandom(){
  var A=ARCADE_GUNS1.filter(function(k){ return !!WEAPONS[k]; }), a=A.length?A[Math.floor(Math.random()*A.length)]:'rifle',
      B=ARCADE_GUNS2.filter(function(k2){ return k2!==a&&!!WEAPONS[k2]; }), b=B.length?B[Math.floor(Math.random()*B.length)]:'';
  return {a:a,b:b};
}
function arcadePartyKit(){
  var o=arcadePartyRec(), k=o.kit;
  if(k&&typeof k==='object'&&typeof k.a==='string'&&ARCADE_GUNS1.indexOf(k.a)>=0&&WEAPONS[k.a]&&(k.b===''||(typeof k.b==='string'&&ARCADE_GUNS2.indexOf(k.b)>=0&&k.b!==k.a&&WEAPONS[k.b]))) return k;
  k=arcadeKitPickRandom(); o.kit=k;
  try{ localStorage.setItem(ARCADE_PARTY_KEY,JSON.stringify(o)); }catch(_pk){}
  return k;
}
function arcadeNewParty(){
  var _sd=((Math.random()*4294967296)>>>0)||1;   // v26.xx (party6): the night seed, picked as a raid picks its own
  try{ localStorage.setItem(ARCADE_PARTY_KEY,JSON.stringify({t:Date.now(),s:_sd,m:(ARCADE.mapIx|0),kit:arcadeKitPickRandom()})); }catch(_np){ return false; }
'@

SubRx @'
var VER='30.46';
'@ @'
var VER='30.47';
'@

$pat = "(?m)^  now:'v30\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.47: The starting guns stay the same all night and change after New party. Check 30.47 fails on v30.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
