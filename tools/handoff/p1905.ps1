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

# THE EXTRACTION CARD SHOWS THE HAUL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    lines.push('You extracted with '+Math.round(G.player.hp)+' of 100 health');
'@ @'
    // v19.05, seen on the extraction card screenshot (2026-10-07): the card said how many items were secured and for how much, but
    // never showed them. A strip of their pictures now sits under that line, most valuable first, up to twelve and then a count,
    // the same pictures the backpack and stash use. Issued Bandages handed back are not shown, as they are not counted.
    (function(){ var keys=G.bag.slice(), iss=(_issN||0), k, s='', n=0;
      for(k=keys.length-1;k>=0&&iss>0;k--) if(keys[k]==='bandage'){ keys.splice(k,1); iss--; }
      keys.sort(function(a,b){ return ival(b)-ival(a); });
      for(k=0;k<keys.length&&k<12;k++){ if(ITEMS[keys[k]]){ s+='<span title="'+escHtml(ITEMS[keys[k]].name)+'" style="display:inline-block;margin:2px;border-radius:6px;background:rgba(0,0,0,.25);border:1px solid '+(RCOL[dispR(keys[k])||ITEMS[keys[k]].r]||'rgba(127,146,216,.35)')+'">'+iconImgHTML(keys[k],34)+'</span>'; n++; } }
      if(keys.length>12) s+='<span style="color:var(--ash);margin-left:6px">+'+(keys.length-12)+' more</span>';
      if(n) lines.push('<span class="haulstrip" style="display:inline-block;margin:4px 0 2px">'+s+'</span>');
    })();
    lines.push('You extracted with '+Math.round(G.player.hp)+' of 100 health');
'@

SubRx @'
var VER='19.04';
'@ @'
var VER='19.05';
'@

$pat = "(?m)^  now:'v19\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.05: The EXTRACTED card shows pictures of what you brought home. Check 19.05 fails on v19.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
