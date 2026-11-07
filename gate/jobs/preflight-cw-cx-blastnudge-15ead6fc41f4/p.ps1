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

# BLAST SHOVE AND BIG HIT AIM NUDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
const BIG_HIT=30;
'@ @'
// v28.xx (cw-cx-blastnudge): his g-3, "A shove only"; g-6, "A small nudge on big hits".
const BLAST_SHOVE_V=300, BLAST_SHOVE_T=0.14;
var BLAST_AT=null;
const BIG_HIT=30;
'@

SubRx @'
  // v28.xx (cw-cx-healrisk): a landed big hit spends the medical wind-up; plates and flowing heals continue.
'@ @'
  // v28.xx (cw-cx-blastnudge): only a landed, survived hit; no random draw or simulation change.
  if(p.hp>0&&!G.sim){
    if(BLAST_AT){
      var _bsx=p.x-BLAST_AT.x, _bsy=p.y-BLAST_AT.y, _bsd=Math.hypot(_bsx,_bsy);
      if(_bsd<BLAST_AT.R){
        var _bsv=BLAST_SHOVE_V*(1-_bsd/BLAST_AT.R);
        if(_bsd>=1){ p.kickVx=_bsx/_bsd*_bsv; p.kickVy=_bsy/_bsd*_bsv; p.kickT=BLAST_SHOVE_T; }
        else if(p.hitDX){ p.kickVx=p.hitDX*_bsv; p.kickVy=0; p.kickT=BLAST_SHOVE_T; }
      }
    } else if(bigHit(amt0)){
      var _ans=1;
      if(typeof sx==='number'&&isFinite(sx)&&typeof sy==='number'&&isFinite(sy))
        _ans=angDiff(Math.atan2(sy-p.y,sx-p.x),p.face)>0?-1:1;
      p.aimNudge=_ans*(0.06+0.03*clamp((amt0-30)/60,0,1)); p.aimNudgeT=0.25;
    }
  }
  // v28.xx (cw-cx-healrisk): a landed big hit spends the medical wind-up; plates and flowing heals continue.
'@

SubRx @'
  if(G.wheel&&G.wheel.face===undefined) G.wheel.face=p.face;
'@ @'
  // v28.xx (cw-cx-blastnudge): mouse stays put; the gun and dotted aim line recover over a quarter second.
  if(p.aimNudgeT>0&&!G.wheel){ p.aimNudgeT=Math.max(0,p.aimNudgeT-dt); p.face+=p.aimNudge*(p.aimNudgeT/0.25); }
  if(G.wheel&&G.wheel.face===undefined) G.wheel.face=p.face;
'@

SubRx @'
damagePlayer(70*(1-sd/R)+20,'barrel','EXPLOSIVE BARREL',x,y);
'@ @'
{ var _blastPrev=BLAST_AT; BLAST_AT={x:x,y:y,R:R}; try{ damagePlayer(70*(1-sd/R)+20,'barrel','EXPLOSIVE BARREL',x,y); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): blast context ends with this hit. */
'@

SubRx @'
damagePlayer(K.pd*(1-sd/R)+K.pb,'barrel',K.nm,x,y);
'@ @'
{ var _blastPrev=BLAST_AT; BLAST_AT={x:x,y:y,R:R}; try{ damagePlayer(K.pd*(1-sd/R)+K.pb,'barrel',K.nm,x,y); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): blast context ends with this hit. */
'@

SubRx @'
damagePlayer(80*(1-dp/R)+18,_fSrc,_fName,f.x,f.y);
'@ @'
{ var _blastPrev=BLAST_AT; BLAST_AT={x:f.x,y:f.y,R:R}; try{ damagePlayer(80*(1-dp/R)+18,_fSrc,_fName,f.x,f.y); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): blast context ends with this hit. */
'@

SubRx @'
damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
'@ @'
{ var _blastPrev=BLAST_AT; BLAST_AT={x:SH.tx,y:SH.ty,R:R}; try{ damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): blast context ends with this hit. */
'@

SubRx @'
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y);
  for(j=G.ents.length-1;j>=0;j--){
'@ @'
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) { var _blastPrev=BLAST_AT; BLAST_AT={x:pt.x,y:pt.y,R:R}; try{ damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): debris is a blast in either window. */
  for(j=G.ents.length-1;j>=0;j--){
'@

SubRx @'
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y);
}
'@ @'
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) { var _blastPrev=BLAST_AT; BLAST_AT={x:pt.x,y:pt.y,R:R}; try{ damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y); }finally{ BLAST_AT=_blastPrev; } } /* v28.xx (cw-cx-blastnudge): debris is a blast in either window. */
}
'@

SubRx @'
_fSrc,_fName,{down:true});
'@ @'
_fSrc,_fName,{down:true,bl:R});
'@

SubRx @'
'howler','HOWLER',{roof:_onRoof?_roof:null});
'@ @'
'howler','HOWLER',{roof:_onRoof?_roof:null,bl:R});
'@

SubRx @'
netHitPlayer(pl,45*(1-d/R)+10,e.kind,e.name,e.x,e.y);
'@ @'
netHitPlayer(pl,45*(1-d/R)+10,e.kind,e.name,e.x,e.y,0,R);
'@

SubRx @'
function netHitPlayer(p,amt,src,srcName,sx,sy,rd){
'@ @'
function netHitPlayer(p,amt,src,srcName,sx,sy,rd,bl){
'@

SubRx @'
  if(!p||!p.net){ damagePlayer(amt,src,srcName,sx,sy); return 'own'; }
'@ @'
  // v28.xx (cw-cx-blastnudge): bl is a blast radius, never inferred from a damage source name.
  if(!p||!p.net){
    var _blastPrev=BLAST_AT; BLAST_AT=(typeof bl==='number'&&isFinite(bl)&&bl>0)?{x:sx,y:sy,R:bl}:null;
    try{ damagePlayer(amt,src,srcName,sx,sy); }finally{ BLAST_AT=_blastPrev; }
    return 'own';
  }
'@

SubRx @'
  if(rd) m.rd=1;
'@ @'
  if(typeof bl==='number'&&isFinite(bl)&&bl>0) m.bl=bl; // v28.xx (cw-cx-blastnudge): radius travels with the existing centre.
  if(rd) m.rd=1;
'@

SubRx @'
netHitPlayer(b,dmgFn(d),src,name,x,y)
'@ @'
netHitPlayer(b,dmgFn(d),src,name,x,y,0,opt.bl)
'@

SubRx @'
  try{ damagePlayer(d,netClean(m.kind,16)||'other',netClean(m.name,24)||'',(typeof m.x==='number'&&isFinite(m.x))?m.x:undefined,(typeof m.y==='number'&&isFinite(m.y))?m.y:undefined); } finally{ LATCH_BITE=0; }
'@ @'
  // v28.xx (cw-cx-blastnudge): player 2 applies his own shove and aim nudge after his own hit guards.
  var _blastPrev=BLAST_AT;
  BLAST_AT=(typeof m.bl==='number'&&isFinite(m.bl)&&m.bl>0&&typeof m.x==='number'&&isFinite(m.x)&&typeof m.y==='number'&&isFinite(m.y))?{x:m.x,y:m.y,R:m.bl}:null;
  try{ damagePlayer(d,netClean(m.kind,16)||'other',netClean(m.name,24)||'',(typeof m.x==='number'&&isFinite(m.x))?m.x:undefined,(typeof m.y==='number'&&isFinite(m.y))?m.y:undefined); } finally{ LATCH_BITE=0; BLAST_AT=_blastPrev; }
'@

SubRx @'
var VER='37.50';
'@ @'
var VER='37.51';
'@

$pat = "(?m)^  now:'v37\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.51: Blasts push surviving players away using wall collision. Incoming non-blast hits of 30 or more nudge the gun for a quarter second, with no random draw, stacking, reticle movement or new text. Both seats apply their own landed-hit rules. Check 37.51 fails on v37.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
