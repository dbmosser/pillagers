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

# THE GOLDEN LABEL STANDS ABOVE THE NAMEPLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  c.save(); c.textAlign='center'; c.font=hudFS(TYPE.micro); c.fillStyle='#ffd24a'; hudText('GOLDEN',s.x,s.y-R*1.9-LH(6)*z); c.restore();
'@ @'
  // v28.59 (cloud-raid-goldlabel), CLOUD HUNT 2026-10-15: GOLDEN sat on the nameplate the body wears in sight (drawn at spriteTop+8); it now stands just above that plate
  var _gph=Math.ceil(parseFloat((FS(TYPE.micro).match(/([\d.]+)px/)||[0,12])[1])*1.35), _gy=Math.min(s.y-R*1.9-LH(6)*z, w2s(e.x,0,e.y-spriteTop(e)-8-_gph+3).y-LH(3)*z);
  if(e.state==='investigate'||e.state==='chase'||e.state==='alarm') _gy-=Math.ceil(msgPx(hudFS(TYPE.head)))+LH(3)*z;   // and above the ? or ! alert mark that sits on the plate
  c.save(); c.textAlign='center'; c.font=hudFS(TYPE.micro); c.fillStyle='#ffd24a'; hudText('GOLDEN',s.x,_gy); c.restore();
'@

SubRx @'
var VER='28.58';
'@ @'
var VER='28.59';
'@

$pat = "(?m)^  now:'v28\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.59: The GOLDEN label over the golden enemy no longer prints on top of its name. Check 28.59 fails on v28.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
