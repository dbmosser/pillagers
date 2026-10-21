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

# PAD BACK KEEPS THE SAVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(md.id==='title') tap(1);
'@ @'
  // v28.xx (cw-cx-saveback): J3 hub crawl: B cancels an open save deletion; the title itself stays up.
  // J4 keeps the destructive word keyboard only. B uses KEEP and never authorizes an erase.
  if(md.id==='title'&&tap(1)){
    var dc=document.getElementById('delconfirm'), dn=document.getElementById('delno');
    if(dc&&dn&&dc.getBoundingClientRect().height>0){ dn.click(); padSetFocus(null); PAD.focus=null; }
  }
'@

SubRx @'
var VER='33.39';
'@ @'
var VER='33.40';
'@

$pat = "(?m)^  now:'v33\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.40: B cancels the save delete confirmation through the existing keep action. Check 33.40 fails on v33.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
