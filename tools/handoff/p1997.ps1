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

# SECTOR THUMBNAIL NAMES CLEAR THE RINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center';
'@ @'
      c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center';
      // v19.97, seen on the 4K lift screenshot (2026-10-08): a zone name was printed through an extraction ring (THE LONG DOCK, BLAST
      // LINE). A name that would touch a ring moves to the nearest clear place just above or below it, inside its own zone.
      function hits(y,hh,hw){ var j,e2,rx,ry,r2,nx,ny; if(!M.extracts) return false; for(j=0;j<M.extracts.length;j++){ e2=M.extracts[j]; if(!e2) continue; rx=ox+e2.x*sc; ry=oy+e2.y*sc; r2=Math.max(4,78*sc)+2; nx=Math.max(cx-hw,Math.min(rx,cx+hw)); ny=Math.max(y-hh,Math.min(ry,y+hh)); if((nx-rx)*(nx-rx)+(ny-ry)*(ny-ry)<r2*r2) return true; } return false; }
      function place(hh,hw){ var top=oy+z.y*sc+hh+1, bot=oy+(z.y+z.h)*sc-hh-1, cand=[cy], j, e2, ry, r2, k, y, best=null; if(M.extracts) for(j=0;j<M.extracts.length;j++){ e2=M.extracts[j]; if(!e2) continue; ry=oy+e2.y*sc; r2=Math.max(4,78*sc)+2; cand.push(ry-r2-hh-1,ry+r2+hh+1); } for(k=0;k<cand.length;k++){ y=cand[k]; if(y<top||y>bot||hits(y,hh,hw)) continue; if(best===null||Math.abs(y-cy)<Math.abs(best-cy)) best=y; } return best===null?cy:best; }
'@

SubRx @'
        c.fillText(a1,cx,cy-fs*0.5+3); c.fillText(a2,cx,cy+fs*0.5+4);
'@ @'
        cy=place(fs+1,Math.max(c.measureText(a1).width,c.measureText(a2).width)/2+2); c.fillText(a1,cx,cy-fs*0.5+3); c.fillText(a2,cx,cy+fs*0.5+4);
'@

SubRx @'
      c.fillText(nm,cx,cy+3);
    })(); }
'@ @'
      cy=place(fs*0.5+1,c.measureText(nm).width/2+2); c.fillText(nm,cx,cy+3);
    })(); }
'@

SubRx @'
var VER='19.96';
'@ @'
var VER='19.97';
'@

$pat = "(?m)^  now:'v19\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.97: On the lift page maps, zone names no longer run through the extraction rings. Check 19.97 fails on v19.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
