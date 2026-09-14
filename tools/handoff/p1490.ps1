$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v14.90, words audit finding 2: HIS WORDS ON THE ITEM AND GUN MENUS. Both menus are added outside #root, and his edits are
# applied only inside #root, so a reworded row was saved and exported but the menu drew the original words every time it opened.
SubRx @'
    m.appendChild(row);
  });
  document.body.appendChild(m);
'@ @'
    m.appendChild(row);
  });
  document.body.appendChild(m); try{ txDom(m); }catch(_txm){}   // v14.90: his words, outside #root
'@
SubRx @'
  row((W.auto?'Automatic':'Semi automatic'), W.mag+' round magazine', true, function(){});
  document.body.appendChild(m);
'@ @'
  row((W.auto?'Automatic':'Semi automatic'), W.mag+' round magazine', true, function(){});
  document.body.appendChild(m); try{ txDom(m); }catch(_txg){}   // v14.90: his words, outside #root
'@
SubRx @'
var VER='14.89';
'@ @'
var VER='14.90';
'@

$pat = "(?m)^  now:'v14\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.90: HIS WORDS SHOW ON THE ITEM AND GUN MENUS. Both right-click menus are added outside the part of the page his edits are applied to, so a reworded menu row was saved and exported but the menu opened with the original words. His edits are now applied to both menus as they open. Check 14.90 rewords a row of the item menu and opens it; it fails on v14.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
