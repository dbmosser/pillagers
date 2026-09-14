$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 1: DOWNED IN AN UNCALLED RING, THE OVERLAY SAID EXTRACTION INBOUND WHILE THE SHIP WAS
# GOING TO ANOTHER RING. downedVerb takes the ring he is lying in (v12.94) but only gave up when both that ring and the global pointer
# were uncalled. With another ring called, by a pillager or by him before he walked off, the pointer was live, so a man down inside an
# open ring nobody had called was told EXTRACTION INBOUND, extracting while downed is permitted, through that other ring's landing and
# its whole window. And the HOLD E TO CALL FOR EXTRACTION row read the pointer too, so it was hidden, although holding E in his ring
# would have called it. Both now read the ring he is lying in: an uncalled ring shows no inbound verb, and offers the call.
SubRx @'
    if((_dz.beaconT===null||_dz.beaconT===undefined)&&(G.beaconT===null||!G.active)) return null;
'@ @'
    // v14.13, HUD audit: an uncalled ring he lies in is not inbound because some other ring is. The call row below offers it instead.
    if((_dz.beaconT===null||_dz.beaconT===undefined)&&(G.beaconT===null||!G.active||_dz!==G.active)) return null;
'@
SubRx @'
    if(G.beaconT===null&&G.active&&G.active.open&&dist(p,G.active)<G.active.r){
      _rowY+=Math.round(_hD*1.35);
      ctx.font=_fD; ctx.fillStyle='#4de3d0';
      ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_rowY);
      if(G.active.callT>0) bar(W/2-70,_rowY+Math.round(_hD*0.45),140,7,clamp(G.active.callT/1.6,0,1),'#4de3d0');
'@ @'
    // v14.13, HUD audit: the ring he is lying in, uncalled, whatever the global pointer says about another ring.
    var _cr=(typeof standingRing==='function')?standingRing():G.active;
    if(_cr&&_cr.open!==false&&(_cr.beaconT===null||_cr.beaconT===undefined)&&dist(p,_cr)<_cr.r){
      _rowY+=Math.round(_hD*1.35);
      ctx.font=_fD; ctx.fillStyle='#4de3d0';
      ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_rowY);
      if(_cr.callT>0) bar(W/2-70,_rowY+Math.round(_hD*0.45),140,7,clamp(_cr.callT/1.6,0,1),'#4de3d0');
'@
SubRx @'
var VER='14.12';
'@ @'
var VER='14.13';
'@

$pat = "(?m)^  now:'v14\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.13: DOWNED IN AN UNCALLED RING, THE OVERLAY OFFERS THE CALL, NOT ANOTHER RING SHIP. Raid HUD and map screen audit of 2026-09-15, finding 1: downedVerb only gave up when both the ring he lay in and the global pointer were uncalled, so with any other ring called a man down in an open uncalled ring read EXTRACTION INBOUND through that other ring landing, and the HOLD E TO CALL FOR EXTRACTION row, reading the pointer, stayed hidden. Both now read the ring he lies in. Check 14.13 calls one ring, downs the player in another, traces the HUD and requires no inbound verb and the call row, with the player down in the called ring reading inbound as the control; it fails on v14.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
