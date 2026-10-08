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

# THE WORLD PROMPTS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
'@ @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
// v19.55, seen on the 4K ring screenshot (2026-10-08): the prompts drawn at a place in the world ([E] CALL FOR EXTRACTION, [E] SEARCH,
// UNLOCK, REVIVE) kept their 1080p size at 4K, small beside a world drawn twice as big. hudAtIn scales whatever follows about that
// point (words, plates, bars together); the caller restores when it returns true.
function hudAtIn(x,y){ var r=Math.max(1,(typeof hudRes==='function')?hudRes():1); if(r===1||!isFinite(x)||!isFinite(y)) return false; ctx.save(); ctx.translate(x,y); ctx.scale(r,r); ctx.translate(-x,-y); return true; }
'@

SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle=haveKey?'#7fc4a0':'#ff8a76';
'@ @'
      var _hsD=hudAtIn(dsc.x,dsc.y);   // v19.55: grows with the screen
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle=haveKey?'#7fc4a0':'#ff8a76';
'@

SubRx @'
      ctx.textAlign='left';
    }
  }
  // A man on the floor is an interaction
'@ @'
      ctx.textAlign='left';
      if(_hsD) ctx.restore();
    }
  }
  // A man on the floor is an interaction
'@

SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle='#ffc04a';
      // v14.12, HUD audit
'@ @'
      var _hsR=hudAtIn(ds3.x,ds3.y);   // v19.55: grows with the screen
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle='#ffc04a';
      // v14.12, HUD audit
'@

SubRx @'
        '  '+_rvLeft.toFixed(0)+'s',ds3.x,ds3.y);
      ctx.textAlign='left';
'@ @'
        '  '+_rvLeft.toFixed(0)+'s',ds3.x,ds3.y);
      ctx.textAlign='left';
      if(_hsR) ctx.restore();
'@

SubRx @'
      ctx.font=FS(TYPE.head); ctx.textAlign='center';   // v10.52, his note: the prompt was too small
      ctx.fillStyle='#ffc04a';
'@ @'
      var _hsC=hudAtIn(s.x,s.y);   // v19.55: grows with the screen
      ctx.font=FS(TYPE.head); ctx.textAlign='center';   // v10.52, his note: the prompt was too small
      ctx.fillStyle='#ffc04a';
'@

SubRx @'
          ctx.fillText(dit.name,s.x,s.y+LH(17)); }
      }
      ctx.textAlign='left';
'@ @'
          ctx.fillText(dit.name,s.x,s.y+LH(17)); }
      }
      ctx.textAlign='left';
      if(_hsC) ctx.restore();
'@

SubRx @'
    var _rHold=(RZ.hold!==undefined&&RZ.hold!==null&&RZ.hold>0);
    ctx.font=FS(TYPE.label); ctx.textAlign='center';
'@ @'
    var _rHold=(RZ.hold!==undefined&&RZ.hold!==null&&RZ.hold>0);
    var _hsZ=hudAtIn(rs.x,rs.y);   // v19.55: grows with the screen
    ctx.font=FS(TYPE.label); ctx.textAlign='center';
'@

SubRx @'
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y);
    ctx.textAlign='left';
'@ @'
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y);
    ctx.textAlign='left';
    if(_hsZ) ctx.restore();
'@

SubRx @'
    var ps=w2s(padZ.x,26,padZ.y);
    if(ps){
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
'@ @'
    var ps=w2s(padZ.x,26,padZ.y);
    if(ps){
      var _hsP=hudAtIn(ps.x,ps.y);   // v19.55: grows with the screen
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
'@

SubRx @'
        if(padZ.callT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
      }
      ctx.textAlign='left';
'@ @'
        if(padZ.callT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
      }
      ctx.textAlign='left';
      if(_hsP) ctx.restore();
'@

SubRx @'
var VER='19.54';
'@ @'
var VER='19.55';
'@

$pat = "(?m)^  now:'v19\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.55: At 4K the search, door, revive and extraction prompts in the world are full size. Check 19.55 fails on v19.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
