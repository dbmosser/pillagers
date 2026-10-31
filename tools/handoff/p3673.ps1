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

# ONE INSET FOR THE RAID HUD PANELS, ONE CARD FOR THE CLOCK AND THE EXTRACT LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudRes(){
'@ @'
// v28.xx (cw-hudinset), the Codex critic on the raid HUD (o-120d, 3 3 3 2): 'the roster starts at x=10, the bars at x=24, the minimap sits about 18px from the right edge, and the weapon card runs almost flush to the right and bottom edges'. ONE INSET for every corner panel: the right column's own (16 in its zoom, 16.8 at 1080p), in screen pixels. The roster, the feed and the controls list, the status icons, the vitals bars, the teammate rows and the ammo card all stand this far from their screen edge.
function hudIns(){ return Math.round(16*(HUDZ.cond||1)*hudRes()); }
function hudRes(){

'@

SubRx @'
MEDALBOX.x=Math.round(LH(9)*rs);
'@ @'
MEDALBOX.x=hudIns();   /* v28.xx (cw-hudinset): the shared inset */
'@

SubRx @'
return {x:Math.round(LH(9)*rs),y:bot-h,w:fw,h:h,rh:rh,gap:gap,fp:fp};
'@ @'
return {x:hudIns(),y:bot-h,w:fw,h:h,rh:rh,gap:gap,fp:fp};
'@

SubRx @'
ox=Math.round(9*hr);
'@ @'
ox=hudIns();   /* v28.xx (cw-hudinset): the shared inset */ 
'@

SubRx @'
PADX=clamp(PADX+HOr.dx/_rz,4,Math.max(4,W/_rz-LW-4));
'@ @'
PADX=clamp(8+hudIns()/_rz+HOr.dx/_rz,4,Math.max(4,W/_rz-LW-4));   // v28.xx (cw-hudinset): the panel (8 left of the text) stands on the shared inset
'@

SubRx @'
var col=w.st==='EXTRACTED'?'#7fc4a0':(w.st==='DEAD'?'#6b7783':'#cdd6dd');
'@ @'
var col=w.st==='EXTRACTED'?'#7fc4a0':(w.st==='DEAD'?'#6b7783':(w.me?UIC.tx_1:UIC.tx_2));   // v28.xx (cw-hudinset), the critic: 'eight rows at equal weight form a dense block'. YOU is the bright row (tx-1), the rivals sit one step back (tx-2)
'@

SubRx @'
ctx.save(); hudZoomIn('body',0,H);
'@ @'
ctx.save(); hudZoomIn('body',0,H); var _bsx=hudIns()/((HUDZ.body||1)*hudRes()*hudUserZ('body'))-16; ctx.translate(_bsx,0);   /* v28.xx (cw-hudinset): the bars (drawn from x 16) stand on the shared inset on the screen */
'@

SubRx @'
var R=hudZoomRect('body',0,H,{x:16,y:by-50,w:HBW,h:50+HBH}), T=hudZoomRect('body',0,H,{x:16,y:by-50-LH(5)-LH(18),w:HBW,h:1});
'@ @'
var R=hudZoomRect('body',0,H,{x:16+_bsx,y:by-50,w:HBW,h:50+HBH}), T=hudZoomRect('body',0,H,{x:16+_bsx,y:by-50-LH(5)-LH(18),w:HBW,h:1});
'@

SubRx @'
_wpR=W-8/_gz
'@ @'
_wpR=W-hudIns()/_gz
'@

SubRx @'
NETTEAMBOX={n:n,x:Math.round(12*_thr),y:_tt,w:Math.round(158*_thr),h:Math.round(n*44*_thr)};
'@ @'
NETTEAMBOX={n:n,x:hudIns(),y:_tt,w:Math.round(158*_thr),h:Math.round(n*44*_thr)};
'@

SubRx @'
    hudFadeRect(x-4,y-15,w+8,36);
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-4,y-15,w+8,36);
'@ @'
    hudPanel(x-4,y-15,w+8,36,undefined,1);   // v28.xx (cw-hudinset), the critic on the party windows: the teammate rows were a 62 percent blue-black box on their own margin. The shared panel (fill, 1px line, 4px radius), its left edge on the shared inset
'@

SubRx @'
var _hfMate=hudFadeBegin('partner-'+g.seat);
'@ @'
x=hudIns()/_thr+4; var _hfMate=hudFadeBegin('partner-'+g.seat);
'@

SubRx @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0};
'@ @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0}, CLKCARD={g:null,k:'',x:0,y:0,w:0,h:0,ay:0};   // v28.xx (cw-hudinset): the top centre card as last drawn: k 'one' holds the clock and the extract row, k 'row' is the extract row under the score card (the arrow inside it)
'@

SubRx @'
var _tSrc=_noClk?(G.t||0):Math.ceil(Math.max(0,G.timeLeft));
'@ @'
var _tSrc=_noClk?(G.t||0):Math.ceil(Math.max(0,G.timeLeft));
  // v28.xx (cw-hudinset), the critic (o-120d): 'the timer, sun icon, extract chip and teal arrow are four separate floating pieces with no shared container; the extract timer is the number the player needs under pressure and is light on a busy backdrop'. In a raid with no score card (no career, no arcade) the clock, its sky icon, the extract line and its arrow stand on ONE centred card (_clkCard); the clock text is drawn by _clkJob once the card is down. With a score card (career, arcade) his order keeps the clock and the score as separate windows, so the extract line and its arrow share one card under the score card instead.
  var _clkJob=null, _clkTx='';
  CLKCARD.g=null;
  function _clkCard(hMin,botY){
    var ow=ctx.font, ctw, hw, x0, y0=Math.round(4*_tz), h;
    ctx.font=_fClk; ctw=ctx.measureText(_clkTx).width; ctx.font=ow;
    hw=Math.round(Math.max(hMin,ctw/2+30*_tz)+8*_tz); x0=Math.round(W/2-hw); h=Math.round(botY-y0);
    hudPlate(x0,y0,hw*2,h,null,HUDC.plate);
    CLKCARD.g=G; CLKCARD.k='one'; CLKCARD.x=x0; CLKCARD.y=y0; CLKCARD.w=hw*2; CLKCARD.h=h; CLKCARD.ay=Math.round(botY-5*_tz);
    if(_clkJob){ var jb=_clkJob; _clkJob=null; jb(); }
    ctx.textAlign='center';
  }
'@

SubRx @'
var _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(mm+':'+(ss<10?'0':'')+ss).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }
'@ @'
_clkTx=mm+':'+(ss<10?'0':'')+ss; _clkJob=function(){ var _cpo; ctx.font=_fClk; ctx.textAlign='center'; ctx.fillStyle=(!_noClk&&_tSrc<=CLOCK_RED)?'#ff5a4a':'#cdd6dd'; _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(_clkTx,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(_clkTx).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }; }
'@

SubRx @'
    ctx.save();
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(_compX,_xpy+_eph/2); ctx.scale(_xsc,_xsc); ctx.translate(-_compX,-(_xpy+_eph/2)); }
    hudPlate(_xpx,_xpy,_epw,_eph,null,HUDC.plate);
'@ @'
    // v28.xx (cw-hudinset): ONE CARD. The arrow stands 4 px lower so it clears the words, and sits inside the card with the extract line. No score card: the clock card is this card (_clkCard). A score card above: the extract card is as wide as the score card and holds the arrow.
    var _oneCard=!!_clkJob, _rowCard=!!(G.arcade||G.career), _az0=_tz*(G.arcade?ARCADE_ARW:1), _cdX=_xpx, _cdY=_xpy, _cdW=_epw, _cdH=_eph, _ayy;
    if(_oneCard||_rowCard) _yArw+=Math.round(4*_tz);
    _ayy=_yArw+(G.arcade?Math.round(8*_tz):0);
    if(_rowCard){
      if(!_rushUI&&SCOREBOX.g===G&&SCOREBOX.w>_cdW){ _cdW=SCOREBOX.w; _cdX=Math.round(_compX-_cdW/2); }
      _cdH=Math.round(_ayy+5*_az0+5*_tz-_cdY);
      CLKCARD.g=G; CLKCARD.k='row'; CLKCARD.x=_cdX; CLKCARD.y=_cdY; CLKCARD.w=_cdW; CLKCARD.h=_cdH; CLKCARD.ay=Math.round(_ayy+5*_az0);
    }
    if(_oneCard){ _clkCard(_epw/2,Math.round(_ayy+5*_az0+5*_tz)); _cdX=CLKCARD.x; _cdY=CLKCARD.y; _cdW=CLKCARD.w; _cdH=CLKCARD.h; ctx.font=_fCmp; ctx.fillStyle=_col; }
    ctx.save();
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(_compX,_cdY+_cdH/2); ctx.scale(_xsc,_xsc); ctx.translate(-_compX,-(_cdY+_cdH/2)); }
    if(!_oneCard) hudPlate(_cdX,_cdY,_cdW,_cdH,null,HUDC.plate);
'@

SubRx @'
ctx.roundRect(_xpx+0.5,_xpy+0.5,_epw-1,_eph-1,Math.min(_eph/2,LH(4))); else ctx.rect(_xpx,_xpy,_epw,_eph);
'@ @'
ctx.roundRect(_cdX+0.5,_cdY+0.5,_cdW-1,_cdH-1,Math.min(_cdH/2,LH(4))); else ctx.rect(_cdX,_cdY,_cdW,_cdH);
'@

SubRx @'
  // v22.13, the raid text rewrite (R08): the MARKED row that flashed here is retired.
'@ @'
  if(_clkJob) _clkCard(0,Math.round(_yClk+_hClk*0.30+6*_tz));   // v28.xx (cw-hudinset): no extraction to point at (all shut): the clock and its sky icon still stand on their card
  // v22.13, the raid text rewrite (R08): the MARKED row that flashed here is retired.
'@

SubRx @'
var VER='36.72';
'@ @'
var VER='36.73';
'@

$pat = "(?m)^  now:'v36\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.73: Corner panels sit on one margin; the clock and the extract line share one card; the pillager board reads YOU first. Check 36.73 fails on v36.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
