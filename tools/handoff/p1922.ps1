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

# THE RAID LABELS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
'@ @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
// v19.22, seen on the 4K raid screenshot (2026-10-08): a HUD font grown with the screen (hudRes), for the few raid labels drawn
// straight in screen pixels that stayed their 1080p size at 4K.
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
'@

SubRx @'
    var zlab=zoneBadge(zz2);   // v11.54, HIS NOTE: his four states, his words
    ctx.font=FS(TYPE.label);
'@ @'
    var zlab=zoneBadge(zz2);   // v11.54, HIS NOTE: his four states, his words
    ctx.font=hudFS(TYPE.label);   // v19.22: grows with the screen, as the world under it does
'@

SubRx @'
    var zsy=hudDodge(zcx,zs.y,zwid/2+6,LH(15),0);
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6,zsy-LH(11),zwid+12,LH(15));
'@ @'
    var _zr=Math.max(1,hudRes());
    var zsy=hudDodge(zcx,zs.y,zwid/2+6*_zr,LH(15)*_zr,0);
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6*_zr,zsy-LH(11)*_zr,zwid+12*_zr,LH(15)*_zr);
'@

SubRx @'
    } else if(_cr){ clab='PARTLY HIDDEN  \u00b7  CROUCHED'; ccol='#ffc04a'; }
    ctx.font=FS(TYPE.head);
'@ @'
    } else if(_cr){ clab='PARTLY HIDDEN  \u00b7  CROUCHED'; ccol='#ffc04a'; }
    ctx.font=hudFS(TYPE.head);   // v19.22: grows with the screen, as the weapon panel under it does
'@

SubRx @'
    if(typeof hudPanel==='function') hudPanel(W-16-cw2-8,_cyb-LH(20),cw2+16,LH(20),0.78); else { ctx.fillRect(W-16-cw2-8,_cyb-LH(20),cw2+16,LH(20)); }
    ctx.fillStyle=ccol; ctx.fillText(clab,W-24,_cyb-LH(6));
'@ @'
    var _cr2=Math.max(1,hudRes());
    if(typeof hudPanel==='function') hudPanel(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2,0.78); else { ctx.fillRect(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2); }
    ctx.fillStyle=ccol; ctx.fillText(clab,W-8-8*_cr2,_cyb-LH(6)*_cr2);   // v19.22: centred in its panel
'@

SubRx @'
var VER='19.21';
'@ @'
var VER='19.22';
'@

$pat = "(?m)^  now:'v19\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.22: At 4K the hiding chip and the ring labels are readable from the couch. Check 19.22 fails on v19.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
