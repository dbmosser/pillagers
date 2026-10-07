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

# THE COMPACT LEGEND FITS ITS KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LEGEND_MINI_PAD=[
'@ @'
// v18.60, FROM THE CODE COMB (2026-10-07): THE COMPACT LEGEND NAMES THE KEYS AS SET AND NEVER RUNS A KEY INTO ITS WORD. On the
// keyboard the list said the default keys after CHANGE KEYS moved them, and every word sat a fixed 44 from its key, so CTRL / C
// printed into crouch. The keys come from the key map now (the same text by default), and the word column clears the widest key.
var LEGEND_MINI_CODES={'WASD':['KeyW','KeyA','KeyS','KeyD'],'SHIFT':['ShiftLeft'],'CTRL / C':['ControlLeft','KeyC'],'SPACE':['Space'],'R':['KeyR'],'F':['KeyF'],'B / I':['KeyB','KeyI'],'E':['KeyE'],'M':['KeyM'],'Z':['KeyZ'],'N':['KeyN']};
function legendKeys(s){
  var c=LEGEND_MINI_CODES[s], o;
  if(!c) return s;
  try{ o=c.map(function(k){ return keyName(keysOf(k)); }); }catch(_l){ return s; }
  return (s==='WASD')?o.join(''):o.join(' / ');
}
var LEGEND_MINI_PAD=[
'@

SubRx @'
    var COLW=LH(112),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*_mr+LH(16);   // v17.76: wide enough for TACTICAL BELT beside its key; v18.17: as many rows as the list has
'@ @'
    if(!(PAD&&PAD.on)) for(mi=0;mi<MN.length;mi++) MN[mi]=[legendKeys(MN[mi][0]),MN[mi][1]];   // v18.60: the keys as set
    var _kw=0, _lw=0; ctx.font=FS(TYPE.micro); for(mi=0;mi<MN.length;mi++) _kw=Math.max(_kw,ctx.measureText(padB(MN[mi][0])).width);
    ctx.font=MONO; for(mi=0;mi<MN.length;mi++) _lw=Math.max(_lw,ctx.measureText(MN[mi][1]).width);
    var KOFF=Math.max(LH(44),Math.ceil(_kw)+LH(6));   // v18.60: the word clears the widest key
    var COLW=Math.max(LH(112),KOFF+Math.ceil(_lw)+LH(8)),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*_mr+LH(16);   // v17.76: wide enough for TACTICAL BELT beside its key; v18.17: as many rows as the list has; v18.60: and for the widest key and word
'@

SubRx @'
      ctx.fillText(MN[mi][1],cx0+LH(44),cy0);
'@ @'
      ctx.fillText(MN[mi][1],cx0+KOFF,cy0);
'@

SubRx @'
var VER='18.59';
'@ @'
var VER='18.60';
'@

$pat = "(?m)^  now:'v18\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.60: The controls panel reads CTRL / C  crouch with a clear gap, and shows the keys you set. Check 18.60 fails on v18.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
