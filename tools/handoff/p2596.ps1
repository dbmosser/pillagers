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

# THE BELT IN FOUR GROUPS WITH LABELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  function drawBelt(){
    var sl=hotbarSlots(),sel=hotSel();
'@ @'
  // v25.xx (belt6a), HIS ORDER 2026-10-13: THE BELT DRAWS ITS FOUR GROUPS. beltGroupOf is the group a key is in (0 guns, 1 throwables, 2 medical,
  // 3 armour); beltClassGlyph is the dim picture a key with nothing on it shows (a grenade, a cross, a plate).
  function beltGroupOf(i){ return (i<GUNKEYS)?0:({throw:1,med:2,plate:3}[BELT_CLASS[i]]||0); }
  function beltClassGlyph(cls,cx,cy,bw){
    if(cls==='throw'){ ctx.beginPath(); ctx.arc(cx,cy,bw*0.17,0,6.2832); ctx.fill(); ctx.fillRect(cx-bw*0.03,cy-bw*0.28,bw*0.06,bw*0.10); }
    else if(cls==='med'){ ctx.fillRect(cx-bw*0.06,cy-bw*0.18,bw*0.12,bw*0.36); ctx.fillRect(cx-bw*0.18,cy-bw*0.06,bw*0.36,bw*0.12); }
    else if(cls==='plate'){ ctx.beginPath(); ctx.moveTo(cx-bw*0.17,cy-bw*0.2); ctx.lineTo(cx+bw*0.17,cy-bw*0.2); ctx.lineTo(cx+bw*0.17,cy+bw*0.04); ctx.lineTo(cx,cy+bw*0.22); ctx.lineTo(cx-bw*0.17,cy+bw*0.04); ctx.closePath(); ctx.fill(); }
  }
  function drawBelt(){
    var sl=hotbarSlots(),sel=hotSel();
'@

SubRx @'
    var gap=LH(6);
'@ @'
    var gap=LH(6), gapG=LH(18);   // v25.xx (belt6a): LH(6) inside a group, LH(18) between groups
'@

SubRx @'
    var bw=Math.floor((_room-(sl.length-1)*gap)/sl.length);
'@ @'
    var _gt=0, _gq;
    for(_gq=1;_gq<sl.length;_gq++) _gt+=(beltGroupOf(_gq)!==beltGroupOf(_gq-1))?gapG:gap;
    var bw=Math.floor((_room-_gt)/sl.length);
'@

SubRx @'
    var tw2=sl.length*bw+(sl.length-1)*gap;
'@ @'
    var tw2=sl.length*bw+_gt;
'@

SubRx @'
    var hx=Math.round(_rL+(_room-tw2)/2),hy=H-bw-LH(13);
'@ @'
    var _lbF=beltFS(bw,0.115), _lbP=parseFloat(((/([\d.]+)px/).exec(String(_lbF))||[0,10])[1])||10, _lbH=Math.round(_lbP*1.5)+LH(3);   // v25.xx (belt6a): the group label strip under the keys
    var hx=Math.round(_rL+(_room-tw2)/2),hy=H-bw-LH(13)-_lbH;
'@

SubRx @'
    G.hotCells=[];
    for(var q=0;q<sl.length;q++){
      var S=sl[q],bx=hx+q*(bw+gap),on=q===sel;
'@ @'
    var _gx=[0], _gp, _pp=LH(4), _gg, _gf, _gl, _gq2;   // v25.xx (belt6a): each key's offset from the left edge, and one graphite plate behind each group
    for(_gp=1;_gp<sl.length;_gp++) _gx.push(_gx[_gp-1]+((beltGroupOf(_gp)!==beltGroupOf(_gp-1))?gapG:gap));
    for(_gg=0;_gg<4;_gg++){
      _gf=-1; _gl=-1;
      for(_gq2=0;_gq2<sl.length;_gq2++) if(beltGroupOf(_gq2)===_gg){ if(_gf<0) _gf=_gq2; _gl=_gq2; }
      if(_gf<0) continue;
      hudPlate(hx+_gf*bw+_gx[_gf]-_pp,hy-_pp,(_gl-_gf)*bw+(_gx[_gl]-_gx[_gf])+bw+_pp*2,bw+_lbH+_pp*2,null,HUDC.plate);
    }
    G.hotCells=[];
    for(var q=0;q<sl.length;q++){
      var S=sl[q],bx=hx+q*bw+_gx[q],on=q===sel;
'@

SubRx @'
      } else if(S.kind!=='empty'){   // v19.01, seen on the 4K screenshots (2026-10-07): an empty key drew this fallback T
'@ @'
      } else if(S.kind==='empty'&&S.cls){ ctx.fillStyle='#9aa7b3'; beltClassGlyph(S.cls,cx2,cy2,bw);   // v25.xx (belt6a): the dim picture of what the key is for
      } else if(S.kind!=='empty'){   // v19.01, seen on the 4K screenshots (2026-10-07): an empty key drew this fallback T
'@

SubRx @'
    // v13.08, HIS NOTE: not in the Undercroft. The belt strip is drawn on the floor
'@ @'
    // v25.xx (belt6a), HIS ORDER 2026-10-13: a small caps label under each group, amber while the highlight is in that group.
    (function(){
      var NM=['GUNS','THROW','MEDICAL','ARMOUR'], g0, f, l, qq, cxl, sg=beltGroupOf(sel);
      ctx.font=_lbF; ctx.textAlign='center';
      for(g0=0;g0<4;g0++){
        f=-1; l=-1;
        for(qq=0;qq<sl.length;qq++) if(beltGroupOf(qq)===g0){ if(f<0) f=qq; l=qq; }
        if(f<0) continue;
        cxl=hx+(f*bw+_gx[f]+l*bw+_gx[l]+bw)/2;
        ctx.fillStyle=(g0===sg)?UIC.acc:HUDC.dim;
        ctx.fillText(NM[g0],cxl,hy+bw+_lbP+LH(1));
      }
      ctx.textAlign='left';
    })();
    // v13.08, HIS NOTE: not in the Undercroft. The belt strip is drawn on the floor
'@

SubRx @'
var VER='25.95';
'@ @'
var VER='25.96';
'@

$pat = "(?m)^  now:'v25\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.96: The belt now has four labelled groups: GUNS, THROW, MEDICAL and ARMOUR, with the lit group in amber. Check 25.96 fails on v25.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
