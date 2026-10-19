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

# KNOW YOUR PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padLostPoll(gp){
'@ @'
// v28.xx (cw-cx-padowner): J7, "first pad = p2, second pad = p1". Only this window claims; forwarding asks for that exact slot.
function padClaimPulse(gp){
  if(CFG.rumble===0||!gp) return false;
  if(gp.vibrationActuator) return padRumbleOn(gp,0.6*rumbleK(),250);
  if(NET.same&&NET.pair) return netSamePost({t:'padclaim',pair:NET.pair,ix:gp.index,s:0.6*rumbleK()});
  return false;
}
function padClaimRecv(m){
  var gp=RUMBLE.other;
  if(!gp||!gp.connected||netPadIxOk(m.ix)<0||gp.index!==m.ix) return 'nopad';
  return padRumbleOn(gp,+m.s||0,250)?'rumble':'nopad';
}
function padClaimPoll(gp){
  var key=(NET.same||'solo')+':'+(NET.pair||'');
  if(!gp||!gp.connected){ PAD.claim=null; return; }
  if(PAD.claim&&PAD.claim.key===key&&PAD.claim.ix===gp.index) return;
  PAD.claim={key:key,ix:gp.index,tag:NET.same==='p2'?'p2':'p1',until:netPadNow()+2};
  padClaimPulse(gp);
}
// v28.xx (cw-cx-padowner): the local pillager gets one short tag on the sharp HUD canvas in the hub and raid, with a wall-clock expiry.
function padClaimDraw(x,y){
  var c=PAD.claim, key=(NET.same||'solo')+':'+(NET.pair||'');
  if(!c||c.key!==key||netPadNow()>=c.until) return '';
  var z=hudRes(), col=c.tag==='p2'?'#5fd7e8':'#f5b73b', w;
  x=clamp(x,32*z,W-32*z); y=clamp(y+44*z,32*z,H-24*z);
  ctx.save();
  try{
    ctx.font=FS(TYPE.label).replace(/[\d.]+px/,Math.round(22*z)+'px'); ctx.textAlign='center'; ctx.textBaseline='middle';
    w=ctx.measureText(c.tag).width+20*z;
    ctx.fillStyle='rgba(6,9,13,.92)'; ctx.fillRect(x-w/2,y-16*z,w,32*z);
    ctx.strokeStyle=col; ctx.lineWidth=z; ctx.strokeRect(x-w/2,y-16*z,w,32*z);
    ctx.fillStyle=col; ctx.fillText(c.tag,x,y);
  }finally{ ctx.restore(); }
  return c.tag;
}
function padLostPoll(gp){
'@

SubRx @'
  if(padLostPoll(gp)){ RUMBLE.gp=null; return; }
'@ @'
  padClaimPoll(gp); // v28.xx (cw-cx-padowner): claim before the reconnect pause consumes this poll.
  if(padLostPoll(gp)){ RUMBLE.gp=null; return; }
'@

SubRx @'
  if(m.t==='rumble'){ if(!RUMBLE.other) return 'nopad'; return padRumbleOn(RUMBLE.other,+m.s||0,+m.ms||0)?'rumble':'nopad'; }   // v17.37: a buzz the other window asked for, on the pad this window reads for him
'@ @'
  if(m.t==='padclaim') return padClaimRecv(m); // v28.xx (cw-cx-padowner): never buzz a different slot after a delayed request.
  if(m.t==='rumble'){ if(!RUMBLE.other) return 'nopad'; return padRumbleOn(RUMBLE.other,+m.s||0,+m.ms||0)?'rumble':'nopad'; }   // v17.37: a buzz the other window asked for, on the pad this window reads for him
'@

SubRx @'
  if(GFXWT) gfxWorldText();   // v23.xx (gfx5): the nameplates, tags, damage numbers and labels of this raid frame, sharp on the HUD canvas
'@ @'
  if(GFXWT) gfxWorldText();   // v23.xx (gfx5): the nameplates, tags, damage numbers and labels of this raid frame, sharp on the HUD canvas
  var _pcs=msPlayerScreen(); padClaimDraw(_pcs.x,_pcs.y); // v28.xx (cw-cx-padowner): this window only.
'@

SubRx @'
  var p=HB.player;
  // The hub is a place you point at things, so it always has an arrow, v2.91.
  if(_curNow!=='default'){ _curNow='default'; try{ cv.style.cursor='default'; }catch(e){} }
  ctx.clearRect(0,0,W,H);
'@ @'
  var p=HB.player;
  // The hub is a place you point at things, so it always has an arrow, v2.91.
  if(_curNow!=='default'){ _curNow='default'; try{ cv.style.cursor='default'; }catch(e){} }
  ctx.clearRect(0,0,W,H);
  padClaimDraw((p.x-ox)*hubScale(),(p.y-oy)*hubScale()); // v28.xx (cw-cx-padowner): the same tag beside the hub pillager.
'@

SubRx @'
  padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false; padBodyCls();
'@ @'
  padClaimPoll(null); // v28.xx (cw-cx-padowner): even a cable gap between polls earns a fresh claim.
  padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false; padBodyCls();
'@

SubRx @'
var VER='31.92';
'@ @'
var VER='31.93';
'@

$pat = "(?m)^  now:'v31\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.93: Claiming a pad gives that pad a 250 ms pulse and puts p1 in amber or p2 in cyan beside its pillager for two seconds. First pad stays p2 and second stays p1. Check 31.93 fails on v31.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
