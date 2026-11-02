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

# THE TEAMMATE ROW SHOWS HIS GUN AND HIS ROUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
,hd:(G.handsT>0||p.hand)?1:0,xo:ascOut(p)?1:0};
'@ @'
,hd:(G.handsT>0||p.hand)?1:0,xo:ascOut(p)?1:0,am:Math.max(0,p.ammo|0),rs:(isFinite(rsvShow(p))?Math.max(0,Math.round(rsvShow(p))):-1)};   // v28.xx (cw-partnergun): am, rounds in his magazine; rs, his reserve as his own HUD shows it (-1 is endless)
'@

SubRx @'
g.hd=m.hd?1:0; }   // v15.79: crouched
'@ @'
g.hd=m.hd?1:0; g.am=(typeof m.am==='number'&&isFinite(m.am))?Math.max(0,Math.min(999,m.am|0)):-1; g.rs=(typeof m.rs==='number'&&isFinite(m.rs))?Math.max(-1,Math.min(99999,m.rs|0)):0; }   // v28.xx (cw-partnergun): his rounds and reserve for the teammate row; a word without them (an older window) draws no gun line   // v15.79: crouched
'@

SubRx @'
out.hd=g.hd; }   // v15.79: passed on as it came
'@ @'
out.hd=g.hd; out.am=g.am; out.rs=g.rs; }   // v15.79: passed on as it came
'@

SubRx @'
_trh=Math.max(1,_tun)*Math.round(44*_thr);
'@ @'
_trh=Math.max(1,_tun)*Math.round(56*_thr);
'@

SubRx @'
y=Math.round(H*0.30)+n*44; n++;
'@ @'
y=Math.round(H*0.30)+n*56; n++;
'@

SubRx @'
_ty=_tt+(n-1)*Math.round(44*_thr)+Math.round(15*_thr);
'@ @'
_ty=_tt+(n-1)*Math.round(56*_thr)+Math.round(15*_thr);
'@

SubRx @'
h:Math.round(n*44*_thr)};
'@ @'
h:Math.round(n*56*_thr)};
'@

SubRx @'
hudPanel(x-4,y-15,w+8,36,undefined,1);
'@ @'
hudPanel(x-4,y-15,w+8,48,undefined,1);
'@

SubRx @'
if(g.ac>0){ ctx.fillStyle='rgba(255,255,255,.10)'; ctx.fillRect(x,y+14,w,4); ctx.fillStyle='#6fb8ff'; ctx.fillRect(x,y+14,w*clamp((g.ar||0)/g.ac,0,1),4); }
'@ @'
if(g.ac>0){ ctx.fillStyle='rgba(255,255,255,.10)'; ctx.fillRect(x,y+14,w,4); ctx.fillStyle='#6fb8ff'; ctx.fillRect(x,y+14,w*clamp((g.ar||0)/g.ac,0,1),4); }
    // v28.xx (cw-partnergun), HIS ANSWER g-64 (10-25, "Add ammo and gun"): a third line under the bars, the gun he holds on the left, rounds / reserve on the right. Nothing when he holds no gun or his hands are busy.
    if(g.w&&g.w!=='fists'&&!g.hd&&g.am>=0&&WEAPONS[g.w]&&WEAPONS[g.w].mag>0){
      var _gn=String(WEAPONS[g.w].name||g.w)+forgeMk(g.fk), _ga=g.am+' / '+(g.rs<0?'\u221e':g.rs), _gw;
      ctx.font=FS(TYPE.micro); ctx.textAlign='right'; ctx.fillStyle=(g.am===0)?HUDC.danger:HUDC.dim; ctx.fillText(_ga,x+w,y+30);
      _gw=w-ctx.measureText(_ga).width-8; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim;
      while(_gn.length>3&&ctx.measureText(_gn).width>_gw) _gn=_gn.slice(0,-1);
      ctx.fillText(_gn,x,y+30);
    }
'@

SubRx @'
var VER='37.26';
'@ @'
var VER='37.27';
'@

$pat = "(?m)^  now:'v37\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.27: The teammate row under the bars shows his gun and his rounds and reserve. Watch the left column at 4K and with three or more teammates: the rows are taller now. Check 37.27 fails on v37.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
