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

# THE PICKED CONTRACT LOOKS PICKED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(P._conSel===ci) row.style.borderColor='var(--amber)';
'@ @'
    if(P._conSel===ci){ row.style.borderColor='var(--amber)'; row.classList.add('sel'); }   // vNN.xx (ui5q2h): the selected row carries the rail
'@

SubRx @'
  var c=(ci!==undefined&&P.contracts[ci])?P.contracts[ci]:list[0];
'@ @'
  var c=(ci!==undefined&&P.contracts[ci])?P.contracts[ci]:list[0];
  // vNN.xx, UI REDESIGN ui5q2h (his #50, from the AAA judge of the Mainframe shot): THE PICKED CONTRACT LOOKS PICKED. The selected row
  // showed only an amber bottom hairline, which read as a divider, and a click on another row moved the card but left that hairline
  // on the first row. The row the card shows now carries the amber rail and the warm fill (the title pick, ui5q1c), and a click
  // moves both.
  try{ var _sx=P.contracts.indexOf(c); [].forEach.call(document.querySelectorAll('#contracts .crow[data-con]'),function(r){ var on=(+r.getAttribute('data-con')===_sx); r.classList.toggle('sel',on); r.style.borderColor=on?'var(--amber)':''; }); }catch(_csel){}
'@

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2h (his #50, from the AAA judge of the Mainframe shot): THE PICKED CONTRACT LOOKS PICKED: a 3px amber
     rail and the warm fill, not a bottom hairline. */
  #root .crow.sel{ background:var(--acc-dim); box-shadow:inset 3px 0 0 var(--acc); }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='25.17';
'@ @'
var VER='25.18';
'@

$pat = "(?m)^  now:'v25\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.18: The picked contract on the Mainframe has an amber edge that follows your click. Check 25.18 fails on v25.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
