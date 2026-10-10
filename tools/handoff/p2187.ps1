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

# NO LINE RUNS OFF THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgLayout(){
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), rows=feedRows(), ex=0;
  if(G) G.feed=rows;
  if(rows.length>1) ex=(rows.length-1)*(msgRowH()+LH(3));
'@ @'
// v21.87, the raid text rewrite (R05): NO LINE RUNS OFF THE SCREEN. A message row was one fillText as wide as its words, so a long
// line (a contract name, a long item, his own rewording) ran past both edges of the screen and its ends were never read. A row
// now has a maximum width, min(0.46 x W, LH(600) x hudRes) on screen, and a line wider than that wraps at a word into a second
// line; past two lines the second is cut at a word and ends in a truncation mark. msgWrap splits his wording of the WHOLE line
// (TX first, measured raw through txRawW, as the CONDITIONS wrap does), so an edit he made still matches; a line that fits is
// drawn exactly as before, untouched. The full text of every line that had to wrap goes into the run report (G.tel.longLines).
// This is a safety net: lines are still written to fit the length caps.
var MSGWRAP={}, MSGWRAPN=0;
function msgMaxW(){ var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'); return Math.max(LH(120),Math.min(W*0.46,LH(600)*hudRes())/(z>0?z:1)); }
function msgLineA(){ var mf=(/([\d.]+)px/).exec(FS(TYPE.label)), px=mf?parseFloat(mf[1]):LH(12); return Math.round(px*1.25); }
function msgFit(s,maxW){   // the longest start of s that fits in maxW, cut at a word when there is one
  if(txRawW(ctx,s)<=maxW) return s;
  var lo=0, hi=s.length, mid, sp;
  while(lo<hi){ mid=(lo+hi+1)>>1; if(txRawW(ctx,s.slice(0,mid))<=maxW) lo=mid; else hi=mid-1; }
  sp=s.lastIndexOf(' ',lo);
  if(sp>0) lo=sp;
  return s.slice(0,Math.max(1,lo)).replace(/\s+$/,'');
}
function msgWrap(m,maxW){   // with ctx.font already set: the lines this message row draws (one, or at most two)
  var raw=String(m), s, key, out, a, rest, b, el='\u2026';
  if(txRawW(ctx,raw)<=maxW&&ctx.measureText(raw).width<=maxW) return [raw];   // it fits as it stands: drawn exactly as before
  s=TX(raw); key=ctx.font+'|'+Math.round(maxW)+'|'+s;
  if(MSGWRAP.hasOwnProperty(key)) return MSGWRAP[key];
  if(MSGWRAPN>200){ MSGWRAP={}; MSGWRAPN=0; }
  if(txRawW(ctx,s)<=maxW) out=[s];
  else {
    a=msgFit(s,maxW); rest=s.slice(a.length).replace(/^\s+/,'');
    if(!rest) out=[a];
    else if(txRawW(ctx,rest)<=maxW) out=[a,rest];
    else { b=msgFit(rest,Math.max(1,maxW-txRawW(ctx,el))); out=[a,b+el]; }
  }
  MSGWRAP[key]=out; MSGWRAPN++;
  return out;
}
function msgLayout(){
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), rows=feedRows(), ex=0, i, n, mw, la, ll;
  if(G) G.feed=rows;
  if(rows.length){
    mw=msgMaxW(); la=msgLineA();
    ctx.save();
    try{
      ctx.font=FS(TYPE.label);
      for(i=0;i<rows.length;i++){
        n=msgWrap(rows[i].m,mw).length;
        if(i) ex+=msgRowH()+LH(3);
        if(n>1){
          ex+=(n-1)*la;
          if(G&&G.tel){ ll=(G.tel.longLines=G.tel.longLines||[]); if(ll.indexOf(rows[i].m)<0&&ll.length<20) ll.push(rows[i].m); }
        }
      }
    } finally { ctx.restore(); }
  }
'@

SubRx @'
    var _mh=msgRowH(), _mst=_mh+LH(3);
    for(var _mri=0;_mri<_frows.length;_mri++){
      var _mrw=_frows[_mri], _ma=clamp(_mrw.T,0,1)*(_mri?0.75:1), _mw=ctx.measureText(_mrw.m).width, _mty=LH(96)+_mri*_mst;
      ctx.globalAlpha=_ma;
      hudPlate(W/2-_mw/2-LH(8),_mty,_mw+LH(16),_mh);
      ctx.fillStyle=HUDC.text;
      hudText(_mrw.m,W/2,_mty+Math.round(_mh*13/17),2);
    }
'@ @'
    // v21.87 (R05): a row wraps into at most two lines no wider than msgMaxW, on one plate, and the next row starts under it.
    var _mh=msgRowH(), _mla=msgLineA(), _mmx=msgMaxW(), _mty=LH(96);
    for(var _mri=0;_mri<_frows.length;_mri++){
      var _mrw=_frows[_mri], _ma=clamp(_mrw.T,0,1)*(_mri?0.75:1), _mln=msgWrap(_mrw.m,_mmx), _mw=0, _mph;
      for(var _mli=0;_mli<_mln.length;_mli++) _mw=Math.max(_mw,ctx.measureText(_mln[_mli]).width);
      _mph=_mh+(_mln.length-1)*_mla;
      ctx.globalAlpha=_ma;
      hudPlate(W/2-_mw/2-LH(8),_mty,_mw+LH(16),_mph);
      ctx.fillStyle=HUDC.text;
      for(_mli=0;_mli<_mln.length;_mli++) hudText(_mln[_mli],W/2,_mty+Math.round(_mh*13/17)+_mli*_mla,2);
      _mty+=_mph+LH(3);
    }
'@

SubRx @'
var VER='21.86';
'@ @'
var VER='21.87';
'@

$pat = "(?m)^  now:'v21\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.87: A long raid message wraps into two lines on its plate instead of running off both edges of the screen. Check 21.87 fails on v21.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
