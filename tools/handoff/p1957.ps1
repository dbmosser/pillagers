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

# THE COOK, RELOAD AND SEARCH BARS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var cs2=w2s(p.x,30,p.y);
    if(cs2){
'@ @'
    var cs2=w2s(p.x,30,p.y);
    if(cs2){
      var _hsK=hudAtIn(cs2.x,cs2.y);   // v19.57, seen on the 4K screenshots (2026-10-08): the cook countdown grows with the screen, plate and bar with it
'@

SubRx @'
        ctx.font=FS(TYPE.micro); ctx.textAlign='left';
      }
    }
  }
// v4.05:
'@ @'
        ctx.font=FS(TYPE.micro); ctx.textAlign='left';
      }
      if(_hsK) ctx.restore();
    }
  }
// v4.05:
'@

SubRx @'
    if(_rb){
      ctx.fillStyle='rgba(6,9,13,.72)';
      ctx.fillRect(_rb.x-27,_rb.y-LH(10),54,LH(8));
      bar(_rb.x-25,_rb.y-LH(9),50,LH(5),clamp(1-p.reloading/p.wep.reload,0,1),'#ffc04a');
    }
'@ @'
    if(_rb){
      var _hsB=hudAtIn(_rb.x,_rb.y);   // v19.57: the reload bar grows with the screen
      ctx.fillStyle='rgba(6,9,13,.72)';
      ctx.fillRect(_rb.x-27,_rb.y-LH(10),54,LH(8));
      bar(_rb.x-25,_rb.y-LH(9),50,LH(5),clamp(1-p.reloading/p.wep.reload,0,1),'#ffc04a');
      if(_hsB) ctx.restore();
    }
'@

SubRx @'
      var _bc='#ffc04a';
      bar(s2.x-30,s2.y-8,60,6,G.searchT/_sc.time,_bc);
'@ @'
      var _bc='#ffc04a';
      var _hsS=hudAtIn(s2.x,s2.y);   // v19.57: the search bar and its count grow with the screen
      bar(s2.x-30,s2.y-8,60,6,G.searchT/_sc.time,_bc);
'@

SubRx @'
        ctx.fillText(_lbl,s2.x,s2.y-LH(15));
        ctx.textAlign='left';
      }
'@ @'
        ctx.fillText(_lbl,s2.x,s2.y-LH(15));
        ctx.textAlign='left';
      }
      if(_hsS) ctx.restore();
'@

SubRx @'
var VER='19.56';
'@ @'
var VER='19.57';
'@

$pat = "(?m)^  now:'v19\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.57: At 4K the cook countdown, reload bar and search bar over your operator are full size. Check 19.57 fails on v19.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
