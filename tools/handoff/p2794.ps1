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

# THE AIR STRIKE, POWER-UPS, MEDALS AND HAUL HAVE SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  say('AIR STRIKE INBOUND','warn');
'@ @'
  say('AIR STRIKE INBOUND','warn');
  // v27.94 (snd3), HIS ORDER (2026-10-15, "add the sounds"): THE AIR STRIKE HAS SOUNDS. Calling it said AIR STRIKE INBOUND in silence and each of the six
  // blasts was the plain boom. Now the call is a target lock, a radio squelch and two low confirm pulses (yours, on the HUD bus), the strike craft comes
  // in over you for the 1.5 s before the first blast (a rocket roar rising in pitch), and each of the six blasts is a recorded blast at its own pitch
  // with a sub drop, the same ring and range as boom. No words, no voices. Cosmetic only: no seeded draw, no game state.
  try{ blip('airConfirm'); blip('airInbound'); }catch(_ac){}
'@

SubRx @'
  try{ say('AIR STRIKE INBOUND','warn',nm?{sub:String(nm).toUpperCase()}:undefined); }catch(_asf){}
'@ @'
  try{ say('AIR STRIKE INBOUND','warn',nm?{sub:String(nm).toUpperCase()}:undefined); }catch(_asf){}
  try{ blip('airInbound'); }catch(_aib){}   // v27.94 (snd3): the other window hears the craft come in, not the confirm (that is the caller's)
'@

SubRx @'
function airBlast(st,i){
  var q=st.pts[i], p=G.player, R=AIR.R, j, e, de, dm;
  sfx('boom',q.x,q.y);
'@ @'
function airBlast(st,i){
  var q=st.pts[i], p=G.player, R=AIR.R, j, e, de, dm;
  sfx('airBoom',q.x,q.y,i);   // v27.94 (snd3): one of six blasts, each at its own pitch (the blast number rides as wid)
'@

SubRx @'
  try{ styTone(PWR_SND.spawn); }catch(_s){}
'@ @'
  try{ blip('pwrAppear'); }catch(_s){}   // v27.94 (snd3): a power-up drops: a low bell out of a sub
'@

SubRx @'
  try{ styTone(PWR_SND[it.k]); }catch(_t){}
'@ @'
  try{ if(SPK_PWR[it.k]) blip(SPK_PWR[it.k]); else styTone(PWR_SND[it.k]); }catch(_t){}   // v27.94 (snd3): each power-up has its own pickup sound (a kind with none keeps its old note)
'@

SubRx @'
    if(S.act[k]<=0){ S.act[k]=0; try{ styTone(PWR_SND.end); }catch(_e){} }
'@ @'
    if(S.act[k]<=0){ S.act[k]=0; try{ blip('pwrEnd'); }catch(_e){} }   // v27.94 (snd3): one runs out
'@

SubRx @'
    else if(S.act[k]<=PWR.warn&&Math.ceil(S.act[k])!==Math.ceil(before)){ try{ styTone(PWR_SND.tick); }catch(_k){} }
'@ @'
    else if(S.act[k]<=PWR.warn&&Math.ceil(S.act[k])!==Math.ceil(before)){ try{ blip('pwrLast'); }catch(_k){} }   // v27.94 (snd3): each of the last 3 s
'@

SubRx @'
S.shSnd=t; try{ styTone(PWR_SND.shhit); }catch(_b){} }
'@ @'
S.shSnd=t; try{ blip('pwrBubbleHit'); }catch(_b){} }   // v27.94 (snd3): the bubble takes a hit
'@

SubRx @'
  try{ styTone(STY_SND[txt]); }catch(_sn){}
  try{ styTone(STY_TIER_SND[styTierOf(txt)]); }catch(_tn){}   // v27.39 (partyp2): and the voice of its tier on top
'@ @'
  // v27.94 (snd3): the medal has ONE sound, a Halo style pop that climbs with the tier of its plate (copper medal1, amber medal2, gold medal3), in place of the
  // old note and the tier voice on top of it
  try{ blip('medal'+Math.max(1,Math.min(3,styTierOf(txt)))); }catch(_sn){}
'@

SubRx @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) annCue(ANN_STREAK[c]); }catch(_avc){} }
  return n;
'@ @'
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5
  return n;
'@

SubRx @'
try{ if(ANN_STREAK[c]) annCue(ANN_STREAK[c]); }catch(_avc){} }   // v25.xx (noannouncer): the streak plays its chime ladder
'@ @'
try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)
'@

SubRx @'
    if(ix>=0){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} }
'@ @'
    if(ix>=0){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} try{ blip('goldAppear'); }catch(_gap){} }   // v27.94 (snd3): three low bells out of a sub bloom, once a raid when it is gilded
'@

SubRx @'
if(!S.ref){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} } S.ref=e; }
'@ @'
if(!S.ref){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} try{ blip('goldAppear'); }catch(_gap2){} } S.ref=e; }
'@

SubRx @'
    try{ if(k&&ITEMS[k]) sfx(lootVoice([k])); }catch(_sf){}
'@ @'
    try{ if(k&&ITEMS[k]) blip(SPK_HAUL[r]||'haulTick'); }catch(_sf){}   // v27.94 (snd3): each item of the haul comes up with a soft tock that climbs with its rarity (common to gold)
'@

SubRx @'
var VER='27.93';
'@ @'
var VER='27.94';
'@

$pat = "(?m)^  now:'v27\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.94: The air strike, power-ups, medals, golden enemy and haul reveal have their own dark sounds, and the old thin chimes are gone. Check 27.94 fails on v27.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
