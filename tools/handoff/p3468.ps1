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

# THE LOST PAD TITLE COLOURS ONLY ITS P1 OR P2 TAG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  h.textContent=padLostWords(ready,same);
  if(box){ if(same) box.setAttribute('data-who',same); else box.removeAttribute('data-who'); }

'@ @'
  // v34.68 (cw-demorcards2), the critic on j8-p1-press-a (2, a P0): amber beside the lime resume button is banned by the guide. Only the p1 or p2 tag is in its player colour now; the words stay the title colour.
  h.textContent=padLostWords(ready,same);
  if(same){
    var sp=document.createElement('span'); sp.className='pl '+same; sp.textContent=same;
    h.textContent=''; h.appendChild(sp); h.appendChild(document.createTextNode(' '+(ready?'press a':'pad lost')));
  }
'@

SubRx @'
#root #pausebox.padlost[data-who="p1"] h3{ color:#f5b73b; }
#root #pausebox.padlost[data-who="p2"] h3{ color:#5fd7e8; }
'@ @'
#root #pausebox.padlost h3 .pl.p1{ color:#f5b73b; }
#root #pausebox.padlost h3 .pl.p2{ color:#5fd7e8; }
'@

SubRx @'
var VER='34.67';
'@ @'
var VER='34.68';
'@

$pat = "(?m)^  now:'v34\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.68: On the lost pad screen only the p1 or p2 tag is coloured and the words are plain. Check 34.68 fails on v34.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
