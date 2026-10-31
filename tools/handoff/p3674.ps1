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

# THE EXTRACTION COUNTDOWN STANDS ON A PLATE AND SAYS EACH FACT ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!holding) _exBW=extBanPlate(_exS,W/2,_exBan,_exR).w;   // v32.xx (cw-extscrim)
    hudText(_exS,W/2,_exBan);   // v16.30, his word: inbound
    // v6.41, his note: no bar. The line above it is already a countdown in seconds.
    if(!inRing){
var _ea=Math.atan2(G.active.y-p.y,G.active.x-p.x),_ed=Math.round(dist(p,G.active));
      ctx.save(); ctx.translate(W/2-28*_exR,_exRow-LH(4)*_exR); ctx.rotate(_ea+Math.PI/2); ctx.scale(_exR,_exR);
      ctx.fillStyle='#ffc04a';
      ctx.beginPath(); ctx.moveTo(0,-10); ctx.lineTo(-6,6); ctx.lineTo(6,6); ctx.closePath(); ctx.fill();
      ctx.restore();
      ctx.font=hudFS(TYPE.label); ctx.fillStyle='#ffc04a';
      hudText(metres(_ed)+'m',W/2+14*_exR,_exRow);
    } else {
      // count what is actually converging
'@ @'
    // v36.xx (cw-xcountplate), the critic on o-120g (P0 'the extraction countdown has no plate on busy ground and repeats the action and the distance'): the countdown stands on its plate
    // while inbound AND once the ship has landed (the landed line was the one left bare), measured to the words as drawn.
    _exBW=extBanPlate(TX(_exS),W/2,_exBan,_exR).w;   // v32.xx (cw-extscrim)
    hudText(_exS,W/2,_exBan);   // v16.30, his word: inbound
    // v36.xx (cw-xcountplate): the letter is the ring's name (his words stay: extract in progress), so it is ringed like a badge. The distance is the pill's job (top centre, once), the action is the centre line (once).
    try{ var _exPre=TX(holding?'EXTRACT IN PROGRESS!  ':'EXTRACT '), _exFp=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,24])[1]), _exCx=W/2-hudRawW(TX(_exS))/2+hudRawW(_exPre)+hudRawW(TX(_exL))/2;
      ctx.save(); ctx.lineWidth=Math.max(1.5,_exFp*0.07); ctx.strokeStyle=ctx.fillStyle; ctx.beginPath(); ctx.arc(_exCx,_exBan-_exFp*0.3,_exFp*0.52,0,6.2832); ctx.stroke(); ctx.restore(); }catch(_exRg){}
    {
      // count what is actually converging
'@

SubRx @'
      if(_ctop===null) continue;
      var _cy=_ctop+_ca+_cp;

'@ @'
      if(_ctop===null) continue;
      WLTEXT.boxes[WLTEXT.boxes.length-1].k=(_cg.cache||_cg.station)?'c':'t';   // v36.xx (cw-xcountplate): a cache or station label ('c') or other world text ('t')
      var _cy=_ctop+_ca+_cp;

'@

SubRx @'
    if(_ntop===null||wlUnder(ne.x-tw/2-11,_ntop,tw+22,ph2+5)) continue;

'@ @'
    if(_ntop!==null) WLTEXT.boxes[WLTEXT.boxes.length-1].k='n';   // v36.xx (cw-xcountplate): this box is a name tag; the damage numbers keep clear of it
    if(_ntop===null||wlUnder(ne.x-tw/2-11,_ntop,tw+22,ph2+5)) continue;

'@

SubRx @'
  var out=[],i,j,d,e,nid,px,npx,top,txt,font,w,x,y,pass,clear,q,scale,alerted;

'@ @'
  var out=[],i,j,d,e,nid,px,npx,top,txt,font,w,x,y,pass,clear,q,scale,alerted,bx,hh,bk;

'@

SubRx @'
    }else if(d.key==='self'||(!d.key&&d.c==='#ff5a4a')) y-=48;

'@ @'
    }else if(d.key==='self'||(!d.key&&d.c==='#ff5a4a')) y-=48;
    // v36.xx (cw-xcountplate), the critic on o-132 (an enemy name overlaps the damage numbers rising off it): the name tags the stack pass placed this frame (WLTEXT, k 'n') are where the names really
    // are, so a number that would sit on one steps up to just over it. The tag, the cache labels and the number's colour, size and timing are untouched; only this frame's text position moves.
    if(WLTEXT.g===G&&WTX.z>0) for(bk=0;bk<12;bk++){
      hh=false;
      for(j=0;j<WLTEXT.boxes.length;j++){
        bx=WLTEXT.boxes[j]; if(bx.k!=='n') continue;
        var _bx0=WTX.ox+bx.x/WTX.z, _by0=WTX.oy+bx.y/WTX.z, _bw=bx.w/WTX.z, _bh=bx.h/WTX.z;
        if(x-w/2<_bx0+_bw+4&&x+w/2>_bx0-4&&y-px*0.85<_by0+_bh+4&&y+px*0.2>_by0-4){ y=_by0-4-px*0.2; hh=true; }
      }
      if(!hh) break;
    }

'@

SubRx @'
var VER='36.73';
'@ @'
var VER='36.74';
'@

$pat = "(?m)^  now:'v36\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.74: The extraction countdown stands on a plate with its ring name ringed, the distance shows once, and damage numbers keep clear of name tags. Check 36.74 fails on v36.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
