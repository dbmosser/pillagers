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

# A WRAPPED LINE KEEPS HIS WORDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var TXHIT=[], TXREC=0;
'@ @'
var TXHIT=[], TXREC=0, TXMW=null;
// v21.84, the raid text rewrite (R02 follow up): A WRAPPED LINE DRAWS HIS WORDS. txRawW measures a string as it stands, through the
// measureText under the TX door, for the code that splits a line into rows itself. Since R02 measureText measures TX(t), and a wrap
// that measured its trial rows that way measured his whole rewording on the last trial of a one line row (it no longer fit, so the
// last word broke off and the rows drawn were pieces of the ORIGINAL, which no edit matches: his words were gone), and measured his
// rewording of one row of a wrapped line on that row (the row was never formed, so his words were gone again). Those wraps now
// run TX on the whole line first and split that, measuring each trial row as it stands.
function txRawW(c,s){ return (TXMW?TXMW.call(c,s):c.measureText(s)).width; }
'@

SubRx @'
    proto.measureText=function(t){ return _mt.call(this,(typeof t==='string'&&t.length)?TX(t):t); };
'@ @'
    proto.measureText=function(t){ return _mt.call(this,(typeof t==='string'&&t.length)?TX(t):t); };
    TXMW=_mt;   // v21.84: the raw measure, for txRawW
'@

SubRx @'
      var ck=ctx.font+'|'+inner+'|'+t, best, n, lo, hi, mid, tr, it, IND=Math.round(LH(8));   // v19.83: IND, the hanging indent of a second line
'@ @'
      t=TX(String(t));   // v21.84: his wording of the whole row is what is split, and the cache key carries it, so an edit busts it
      var ck=ctx.font+'|'+inner+'|'+t, best, n, lo, hi, mid, tr, it, IND=Math.round(LH(8));   // v19.83: IND, the hanging indent of a second line
'@

SubRx @'
          if(ctx.measureText(trial).width<=(lines.length?w-IND:w)){ cur=trial; }
'@ @'
          if(txRawW(ctx,trial)<=(lines.length?w-IND:w)){ cur=trial; }
'@

SubRx @'
        var wWords=((wm+1)+'. '+wnShort(WHATSNEW[wm])).split(' '),wLine='',wFirst=1;
'@ @'
        var wWords=TX((wm+1)+'. '+wnShort(WHATSNEW[wm])).split(' '),wLine='',wFirst=1;   // v21.84: his wording of the entry is what is wrapped
'@

SubRx @'
          if(wLine&&ctx.measureText(wCand).width>wnW-LH(44)){
'@ @'
          if(wLine&&txRawW(ctx,wCand)>wnW-LH(44)){
'@

SubRx @'
      var zw=Math.max(10,z.w*sc-6), fs=11, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=String(z.name), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;
'@ @'
      var zw=Math.max(10,z.w*sc-6), fs=11, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=TX(String(z.name)), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;   // v21.84: his name for the zone is what shrinks and splits
'@

SubRx @'
        for(k=1;k<ws.length;k++){ w1=c.measureText(ws.slice(0,k).join(' ')).width; w2=c.measureText(ws.slice(k).join(' ')).width; if(Math.max(w1,w2)<bw){ bw=Math.max(w1,w2); best=k; } }
'@ @'
        for(k=1;k<ws.length;k++){ w1=txRawW(c,ws.slice(0,k).join(' ')); w2=txRawW(c,ws.slice(k).join(' ')); if(Math.max(w1,w2)<bw){ bw=Math.max(w1,w2); best=k; } }
'@

SubRx @'
var VER='21.83';
'@ @'
var VER='21.84';
'@

$pat = "(?m)^  now:'v21\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.84: A reworded line in the CONDITIONS panel, the What is New card or a sector map zone name wraps his words instead of the original. Check 21.84 fails on v21.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
