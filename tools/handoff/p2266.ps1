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

# ONE PROMPT STYLE AT THE SEARCH SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v19.55, seen on the 4K ring screenshot (2026-10-08): the prompts drawn at a place in the world ([E] CALL FOR EXTRACTION, [E] SEARCH,
'@ @'
// v22.66, the raid text rewrite (R24): ONE PROMPT STYLE AT THE SEARCH SIZE. HIS NOTE (v10.52): the SEARCH prompt was too small, so it
// went up to TYPE.head; every other prompt at a place in the world (a door, a downed pillager, a ring, a survivor, the seal) stayed
// at the label size or smaller, each in its own colour, with no plate, so a door read smaller than a crate and a prompt over a busy
// floor was hard to read. hudPrompt draws them all one way: TYPE.head (never smaller than his SEARCH), on a plate measured to the
// words, the line in bone caps (or the colour of its meaning: extraction, gain, danger) with the bracketed key drawn over in amber,
// and an optional second line in TYPE.label sentence case. The whole line is one fillText, as before; the key is drawn on top of it.
// The caller still owns hudAtIn. Returns the width, and by, the bottom of the plate, for a bar under it.
function hudPrompt(s,x,y,o){
  var t=String(s), m, w, a, d, sub=(o&&o.sub)?String(o.sub):'', sw=0, h, bw, i0, i1;
  ctx.font=FS(TYPE.head); ctx.textAlign='center';
  m=ctx.measureText(t); w=m.width;
  a=(m.actualBoundingBoxAscent>0)?m.actualBoundingBoxAscent:LH(12); d=(m.actualBoundingBoxDescent>0)?m.actualBoundingBoxDescent:LH(3);
  if(sub){ ctx.font=FS(TYPE.label); sw=ctx.measureText(sub).width; ctx.font=FS(TYPE.head); }
  h=a+d+LH(8)+(sub?LH(15):0); bw=Math.max(w,sw)+LH(16);
  hudPlate(x-bw/2,y-a-LH(4),bw,h,(o&&o.accent)||null,(o&&o.plate)||null);
  ctx.fillStyle=(o&&o.col)||HUDC.text; ctx.fillText(t,x,y);
  i0=t.indexOf('['); i1=(i0>=0)?t.indexOf(']',i0):-1;
  if(i1>i0){ ctx.textAlign='left'; ctx.fillStyle=HUDC.warn; ctx.fillText(t.slice(i0,i1+1),x-w/2+ctx.measureText(t.slice(0,i0)).width,y); ctx.textAlign='center'; }
  if(sub){ ctx.font=FS(TYPE.label); ctx.fillStyle=(o&&o.subCol)||HUDC.text; ctx.fillText(sub,x,y+d+LH(14)); ctx.font=FS(TYPE.head); }
  return {w:w,by:y-a-LH(4)+h};
}
// v19.55, seen on the 4K ring screenshot (2026-10-08): the prompts drawn at a place in the world ([E] CALL FOR EXTRACTION, [E] SEARCH,
'@

SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle=haveKey?'#7fc4a0':'#ff8a76';
      var _dlab=haveKey?('['+keyLabel('KeyE','E')+'] UNLOCK '+G.nearDoor.name):(G.nearDoor.name+' - LOCKED');
'@ @'
      ctx.font=FS(TYPE.head); ctx.textAlign='center';   // v22.66 (R24): the SEARCH size, measured in it for the dodge below
      var _dlab=haveKey?('['+keyLabel('KeyE','E')+'] UNLOCK '+G.nearDoor.name):(G.nearDoor.name+' LOCKED');
'@

SubRx @'
      ctx.fillText(_dlab,dsc.x,_dy);
      if(!haveKey&&kName){
        ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(255,192,74,.92)';
        ctx.fillText('needs the '+kName,dsc.x,_dy+LH(12));
      }
'@ @'
      hudPrompt(_dlab,dsc.x,_dy,{col:haveKey?HUDC.text:HUDC.danger,sub:(!haveKey&&kName)?('Needs the '+kName):''});   // v22.66 (R24): one prompt style, the key it needs as the second line
'@

SubRx @'
      ctx.fillText('['+keyLabel('KeyE','E')+'] REVIVE '+(G.nearDown.name||'PILLAGER')+
        '  '+_rvLeft.toFixed(0)+'s',ds3.x,ds3.y);
'@ @'
      hudPrompt('['+keyLabel('KeyE','E')+'] REVIVE '+String(G.nearDown.name||'PILLAGER').toUpperCase()+
        '  \u00b7  '+_rvLeft.toFixed(0)+'s',ds3.x,ds3.y);   // v22.66 (R24): one prompt style
'@

SubRx @'
      if(nc2.fallen&&(nc2.fellAt===undefined||G.t-nc2.fellAt>2.3)){
        var _ft='['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+nc2.fallen.toUpperCase();
        ctx.fillText(_ft,s.x,s.y);
        if(nc2.fallenCrew!==undefined&&CFG.raiderFeud!==0){
          var _fw=ctx.measureText(_ft).width;
          ctx.fillStyle=['#c8452f','#4a90c2','#c2a54a','#7a4ac2'][nc2.fallenCrew%4];
          ctx.fillRect(s.x-_fw/2-9,s.y-LH(9),4,LH(11));
        }
      }
else if(nc2.tag) ctx.fillText('['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+String(nc2.tag).toUpperCase(),s.x,s.y);
      else ctx.fillText('['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':nc2.type.toUpperCase())),s.x,s.y);
      // His #23: item names in the world when you are near them. A single-item
      // crate that YOU dropped or a body someone emptied loot into is not a
      // mystery box, so it says what it holds; multi-item finds stay unsearched
      // secrets, because he explicitly wants searching to mean something.
      if(nc2.loot.length===1&&nc2.dropped){
        var dit=ITEMS[nc2.loot[0]];
        if(dit){ ctx.fillStyle=RCOL[dispR(nc2.loot[0])||dit.r]||'#cdd6dd';
          ctx.fillText(dit.name,s.x,s.y+LH(17)); }
      }
'@ @'
      // v22.66 (R24): one prompt style. The fallen pillager's crew colour is the plate's accent bar (it was a bar beside the words),
      // and the one item a dropped crate holds is the second line, in its rarity colour.
      var _skey='['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH ', _ft, _fcr=null, _fsub='', _fsc=null;
      if(nc2.fallen&&(nc2.fellAt===undefined||G.t-nc2.fellAt>2.3)){
        _ft=_skey+nc2.fallen.toUpperCase();
        if(nc2.fallenCrew!==undefined&&CFG.raiderFeud!==0) _fcr=['#c8452f','#4a90c2','#c2a54a','#7a4ac2'][nc2.fallenCrew%4];
      }
      else if(nc2.tag) _ft=_skey+String(nc2.tag).toUpperCase();
      else _ft=_skey+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':nc2.type.toUpperCase()));
      // His #23: item names in the world when you are near them. A single-item
      // crate that YOU dropped or a body someone emptied loot into is not a
      // mystery box, so it says what it holds; multi-item finds stay unsearched
      // secrets, because he explicitly wants searching to mean something.
      if(nc2.loot.length===1&&nc2.dropped){
        var dit=ITEMS[nc2.loot[0]];
        if(dit){ _fsub=dit.name; _fsc=RCOL[dispR(nc2.loot[0])||dit.r]||'#cdd6dd'; }
      }
      hudPrompt(_ft,s.x,s.y,{accent:_fcr,sub:_fsub,subCol:_fsc});
'@

SubRx @'
    ctx.font=FS(TYPE.label); ctx.textAlign='center';
    ctx.fillStyle=_rHold?'#7fc4a0':'#4de3d0';
    // v11.74: extractNowLine, the same line as the banner (v8.68 named the window; v11.74 reworded it).
    ctx.fillText(_rHold?
      extractNowLine(extLetter(RZ),RZ.hold):
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y);
'@ @'
    // v11.74: extractNowLine, the same line as the banner (v8.68 named the window; v11.74 reworded it).
    // v22.66 (R24): one prompt style, in the extraction colours.
    hudPrompt(_rHold?
      extractNowLine(extLetter(RZ),RZ.hold):
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y,{col:_rHold?HUDC.gain:HUDC.extract});
'@

SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      if(!padZ.open){
        ctx.fillStyle='#ff5a4a';
        ctx.fillText('EXTRACTION CLOSED',ps.x,ps.y);
'@ @'
      ctx.textAlign='center'; var _pzb=ps.y+LH(6);   // v22.66 (R24): one prompt style; a hold bar sits under its plate
      if(!padZ.open){
        hudPrompt('EXTRACTION CLOSED',ps.x,ps.y,{col:HUDC.danger});
'@

SubRx @'
        ctx.fillStyle='#7fc4a0';
        if(!(G.active===padZ&&!p.downed&&dist(p,padZ)<padZ.r))
          ctx.fillText('['+keyLabel('KeyE','E')+'] EXTRACT - '+Math.ceil(padZ.hold)+'s',ps.x,ps.y);
        if(padZ.pullT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.pullT/1.4,0,1),'#7fc4a0');
'@ @'
        if(!(G.active===padZ&&!p.downed&&dist(p,padZ)<padZ.r))
          _pzb=hudPrompt('['+keyLabel('KeyE','E')+'] EXTRACT  \u00b7  '+Math.ceil(padZ.hold)+'s',ps.x,ps.y,{col:HUDC.gain}).by+LH(3);
        if(padZ.pullT>0) bar(ps.x-30,_pzb,60,6,clamp(padZ.pullT/1.4,0,1),'#7fc4a0');
'@

SubRx @'
          ctx.fillStyle='#4de3d0';
          ctx.fillText('INBOUND '+Math.ceil(padZ.beaconT)+'s',ps.x,ps.y);
'@ @'
          hudPrompt('INBOUND '+Math.ceil(padZ.beaconT)+'s',ps.x,ps.y,{col:HUDC.extract});   // v22.66 (R24)
'@

SubRx @'
        ctx.fillText('['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION',ps.x,ps.y);
        if(padZ.callT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
'@ @'
        _pzb=hudPrompt('['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION',ps.x,ps.y,{col:HUDC.extract}).by+LH(3);   // v22.66 (R24)
        if(padZ.callT>0) bar(ps.x-30,_pzb,60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
'@

SubRx @'
    ctx.fillStyle='#4de3d0'; ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_exRow);
'@ @'
    ctx.fillStyle='#4de3d0'; ctx.fillText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION',W/2,_exRow);   // v22.66 (R24): the key in brackets, as every prompt
'@

SubRx @'
      ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_rowY);
'@ @'
      ctx.fillText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION',W/2,_rowY);   // v22.66 (R24): the key in brackets
'@

SubRx @'
    if(_ir&&_sd) return {msg:'HOLD '+keyLabel('KeyE','E')+' TO EXTRACT',sub:'Extracting while downed is permitted',col:'#4de3d0'};
'@ @'
    if(_ir&&_sd) return {msg:'HOLD ['+keyLabel('KeyE','E')+'] TO EXTRACT',sub:'Extracting while downed is permitted',col:'#4de3d0'};   // v22.66 (R24): the key in brackets
'@

SubRx @'
      _msg='HOLD '+keyLabel('KeyE','E')+' TO EXTRACT';
'@ @'
      _msg='HOLD ['+keyLabel('KeyE','E')+'] TO EXTRACT';   // v22.66 (R24): the key in brackets, as every prompt
'@

SubRx @'
      var _sp=w2s(_se.x,40,_se.y);
      ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#7fc4a0';
      ctx.fillText('['+keyLabel('KeyE','E')+'] GIVE '+ITEMS[_se.want].name.toUpperCase(),_sp.x,_sp.y);
      ctx.textAlign='left';
'@ @'
      var _sp=w2s(_se.x,40,_se.y), _hsG=hudAtIn(_sp.x,_sp.y);   // v22.66 (R24): grows with the screen, as every world prompt
      hudPrompt('['+keyLabel('KeyE','E')+'] GIVE '+ITEMS[_se.want].name.toUpperCase(),_sp.x,_sp.y);
      ctx.textAlign='left';
      if(_hsG) ctx.restore();
'@

SubRx @'
    ctx.font=FS(TYPE.head); ctx.textAlign='center';
var _slp=w2s(p.x,66,p.y);
    ctx.fillStyle='#ffc04a'; ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CUT THE SEAL',_slp.x,_slp.y);   // v21.74 (K14): the button in hand, as every other prompt; on the keyboard with E unmoved it reads as before
    bar(_slp.x-70,_slp.y+LH(6),140,7,clamp((_SRh.cut+G.seal.gained)/Math.max(1,sealNeed(_SRh.tier)),0,1),'#ffc04a');
    ctx.textAlign='left';
'@ @'
    // v21.74 (K14): the button in hand, as every other prompt. v22.66 (R24): one prompt style, grown with the screen, the key in
    // brackets (HOLD [E] TO CUT THE SEAL), and the hold bar under its plate.
    var _slp=w2s(p.x,66,p.y), _hsL=hudAtIn(_slp.x,_slp.y);
    var _slb=hudPrompt('HOLD ['+keyLabel('KeyE','E')+'] TO CUT THE SEAL',_slp.x,_slp.y).by+LH(3);
    bar(_slp.x-70,_slb,140,7,clamp((_SRh.cut+G.seal.gained)/Math.max(1,sealNeed(_SRh.tier)),0,1),'#ffc04a');
    ctx.textAlign='left';
    if(_hsL) ctx.restore();
'@

SubRx @'
var VER='22.65';
'@ @'
var VER='22.66';
'@

$pat = "(?m)^  now:'v22\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.66: Every world prompt is drawn at the SEARCH size on a plate, with the key in amber brackets. Check 22.66 fails on v22.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
