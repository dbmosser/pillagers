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

# THE BELT CAPTION DRAWS KEYCAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.fillStyle='rgba(6,9,13,.55)'; ctx.fillRect(Math.round(W/2-_bcW/2-_bcF*0.6),Math.round(hy-LH(6)-_bcF*0.95),Math.round(_bcW+_bcF*1.2),Math.round(_bcF*1.25));
      ctx.fillStyle='#b4bfca';
      ctx.fillText(_bcT,W/2,hy-LH(6));   // v13.52: no pad button reaches V; v18.71: the key as set
'@ @'
      ctx.fillStyle='rgba(17,19,21,.72)'; ctx.fillRect(Math.round(W/2-_bcW/2-_bcF*0.6),Math.round(hy-LH(6)-_bcF*0.95),Math.round(_bcW+_bcF*1.2),Math.round(_bcF*1.25));   // vNN.xx (ui5q1n): graphite, as the HUD plate
      ctx.fillStyle='#b4bfca';
      // vNN.xx, UI REDESIGN ui5q1n (his #50 and #35, from the AAA judge of the raid HUD shot): THE BELT CAPTION DRAWS KEYCAPS. Its keys
      // were bracketed words ([FIRE] use, [V] signal) beside the keycaps of every world prompt (ui7, hudPrompt). As hudPrompt does, the
      // line is still drawn whole through the TX door (his wording and the word editor are untouched), with each bracketed key cut out
      // by a clip, and a keycap (hudKey) drawn in its place. Same words, same place, same size.
      (function(){
        var _y=hy-LH(6), _T=(typeof TX==='function')?TX(_bcT):_bcT, _tw=hudRawW(_T), _x0=W/2-_tw/2, _m=ctx.measureText(_T), _re=/\[[^\]]+\]/g, _k, _ks=[];
        var _a=(_m.actualBoundingBoxAscent>0)?_m.actualBoundingBoxAscent:_bcF*0.72;
        while((_k=_re.exec(_T))) _ks.push({i:_k.index,s:_k[0]});
        if(!_ks.length||typeof hudKey!=='function'){ ctx.fillText(_bcT,W/2,_y); return; }   // v13.52: no pad button reaches V; v18.71: the key as set
        ctx.save(); ctx.beginPath(); ctx.rect(_x0-_bcF,_y-_a-_bcF,_tw+_bcF*2,_a+_bcF*2);
        _ks.forEach(function(q){ q.x=_x0+hudRawW(_T.slice(0,q.i)); q.w=hudRawW(q.s); ctx.rect(q.x,_y-_a-_bcF,q.w,_a+_bcF*2); });
        ctx.clip('evenodd');
        try{ ctx.fillText(_bcT,W/2,_y); } finally { ctx.restore(); }
        _ks.forEach(function(q){ hudKey(q.s.slice(1,-1),q.x,_y,_a,q.w); });
        ctx.textAlign='center';
      })();
'@

SubRx @'
var VER='24.51';
'@ @'
var VER='24.52';
'@

$pat = "(?m)^  now:'v24\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.52: The caption over the belt shows its keys as keycaps. Check 24.52 fails on v24.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
