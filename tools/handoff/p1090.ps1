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

# ============ HIS NOTE, WITH A SCREENSHOT: TEXT COLLISION IN THE LOWER RIGHT.
# ============
# ============ His picture shows SUPPORT MG, the biggest text on the HUD, with
# ============ the green EXTRACTION - OPEN label drawn straight through it.
# ============
# ============ THE CAUSE. That label is a WORLD label: it is drawn at the
# ============ extraction ring's projected screen position, so it goes wherever
# ============ the ring happens to be. The gun name, the ammo and the stowed gun
# ============ are HUD text pinned to the bottom-right corner and are not a panel,
# ============ so nothing has ever known they are there. Stand with an open ring
# ============ down and to your right and the two land on the same pixels.
# ============
# ============ Four other world labels can reach the same corner: a locked door
# ============ and the key it needs, and a downed man and his timer.
# ============
# ============ THE FIX. The corner readout measures itself as it draws and leaves
# ============ its rectangle on G. Every world label then asks one helper whether
# ============ it would land in that rectangle, and if it would, it is lifted
# ============ clear above it rather than hidden: a marker you cannot see is a
# ============ worse answer than a marker an inch higher.
# ============
# ============ The box is one frame old, because the world is drawn before the
# ============ HUD. That is on purpose and it is safe: the corner text is pinned
# ============ to the screen and its width only changes when the gun does.
SubRx @'
  var _HS=hotbarSlots(), _HH=_HS[hotSel()];
'@ @'
  // v10.90, HIS NOTE: the corner readout measures itself so world labels can
  // keep out of it. See the long note in DESIGN.md.
  var _cornW=0;
  function _cornMark(txt){ try{ var w=ctx.measureText(String(txt)).width; if(w>_cornW) _cornW=w; }catch(_cm){} }
  var _HS=hotbarSlots(), _HH=_HS[hotSel()];
'@
SubRx @'
  ctx.font=FS(TYPE.head); ctx.fillStyle=_heldGun?'#cdd6dd':(_HH.c||'#cdd6dd');
  ctx.fillText(_heldGun
    ? (p.wep.name+(p.ads?(opticMag()>1?('  '+opticMag().toFixed(2).replace(/0$/,'')+'x SCOPE'):'  [ADS]'):''))
    : _HH.name,
    W-16,by-LH(34));
'@ @'
  ctx.font=FS(TYPE.head); ctx.fillStyle=_heldGun?'#cdd6dd':(_HH.c||'#cdd6dd');
  var _cornName=_heldGun
    ? (p.wep.name+(p.ads?(opticMag()>1?('  '+opticMag().toFixed(2).replace(/0$/,'')+'x SCOPE'):'  [ADS]'):''))
    : _HH.name;
  _cornMark(_cornName);
  ctx.fillText(_cornName,W-16,by-LH(34));
'@
SubRx @'
  if(p.sec){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    ctx.fillText('STOWED  '+p.sec.name+'  '+p.secAmmo,W-16,by-LH(52));
  }
'@ @'
  if(p.sec){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    var _cornStow='STOWED  '+p.sec.name+'  '+p.secAmmo;
    _cornMark(_cornStow);
    ctx.fillText(_cornStow,W-16,by-LH(52));
  }
  // The rectangle the corner owns, left for the world labels drawn on the NEXT
  // frame. A floor of 180 so a short name like FISTS still reserves the space
  // the ammo line under it needs.
  G.cornerBox={x:W-16-Math.max(180,_cornW)-10,y:by-LH(66),w:Math.max(180,_cornW)+26,h:LH(76)};
'@

# ---- the helper, and the world labels that use it
SubRx @'
    var zlab=za?'EXTRACTION - OPEN':'EXTRACTION - CLOSED';
    ctx.font=FS(TYPE.label);
    var zwid=ctx.measureText(zlab).width;
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zs.x-zwid/2-6,zs.y-LH(11),zwid+12,LH(15));
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    ctx.fillText(zlab,zs.x,zs.y);
    if(!za){
      ctx.font=FS(TYPE.micro);
      ctx.fillStyle='rgba(168,180,193,.7)';
      ctx.fillText('this one will not call',zs.x,zs.y+LH(13));
    }
'@ @'
    var zlab=za?'EXTRACTION - OPEN':'EXTRACTION - CLOSED';
    ctx.font=FS(TYPE.label);
    var zwid=ctx.measureText(zlab).width;
    // v10.90, HIS NOTE: this is the label in his screenshot, drawn straight
    // through SUPPORT MG. It is lifted clear of the corner readout instead.
    var zsy=hudDodge(zs.x,zs.y,zwid/2+6,LH(15),za?0:LH(13));
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zs.x-zwid/2-6,zsy-LH(11),zwid+12,LH(15));
    ctx.fillStyle=za?'#4de3d0':'rgba(168,180,193,.95)';
    ctx.fillText(zlab,zs.x,zsy);
    if(!za){
      ctx.font=FS(TYPE.micro);
      ctx.fillStyle='rgba(168,180,193,.7)';
      ctx.fillText('this one will not call',zs.x,zsy+LH(13));
    }
'@
SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle=haveKey?'#7fc4a0':'#ff8a76';
      ctx.fillText(haveKey?('['+keyLabel('KeyE','E')+'] UNLOCK '+G.nearDoor.name):(G.nearDoor.name+' - LOCKED'),dsc.x,dsc.y);
      if(!haveKey&&kName){
        ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(255,192,74,.92)';
        ctx.fillText('needs the '+kName,dsc.x,dsc.y+LH(12));
      }
'@ @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle=haveKey?'#7fc4a0':'#ff8a76';
      var _dlab=haveKey?('['+keyLabel('KeyE','E')+'] UNLOCK '+G.nearDoor.name):(G.nearDoor.name+' - LOCKED');
      var _dy=hudDodge(dsc.x,dsc.y,ctx.measureText(_dlab).width/2+6,LH(15),(!haveKey&&kName)?LH(12):0);
      ctx.fillText(_dlab,dsc.x,_dy);
      if(!haveKey&&kName){
        ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(255,192,74,.92)';
        ctx.fillText('needs the '+kName,dsc.x,_dy+LH(12));
      }
'@

# ---- the helper itself, beside the projection it works in
SubRx @'
var by=H-34;
'@ @'
// v10.90, HIS NOTE: keep a world label out of the corner the HUD owns. Given a
// label centred at sx,sy with a half width and a height, and how far a second
// line hangs below it, this returns the y to draw at: unchanged when there is no
// overlap, and lifted just above the corner box when there is. It LIFTS rather
// than hides, because a marker you cannot see is a worse answer than one an inch
// higher, and it never pushes a label off the top of the screen.
function hudDodge(sx,sy,halfW,hgt,tail){
  var B=G&&G.cornerBox; if(!B) return sy;
  var l=sx-halfW, r=sx+halfW, t=sy-hgt, b=sy+(tail||0)+4;
  if(r<B.x||l>B.x+B.w||b<B.y||t>B.y+B.h) return sy;
  var lift=b-B.y+6;
  var out=sy-lift;
  return (out-hgt<4)?sy:out;
}
var by=H-34;
'@

SubRx @'
var VER='10.89';
'@ @'
var VER='10.90';
'@
SubRx @'
  now:'v10.89: X no longer swaps weapons, your note. The key, its legend lines and the bracket in front of the stowed gun are gone; the hotbar is how a gun comes up. The swap itself is kept, because dragging a gun onto the one in your hands and the bot pulling its sidearm both use it.',
'@ @'
  now:'v10.90: the text collision in the lower right, your screenshot. EXTRACTION - OPEN is a world label drawn at the ring, and the gun name under it is HUD text pinned to the corner that nothing knew was there. The corner now measures itself and world labels lift clear of it.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
