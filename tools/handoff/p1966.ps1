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

# THE BELT HINT GROWS AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
'@ @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
// v19.66, seen on a 4K text scan (2026-10-08): the line over the belt grew 1.3 times from 1080p to 4K while the extraction lines above
// it (v19.54) and the rest of the HUD grow twice, so it read as small print. It is the larger of the slot size and the screen-grown size.
function beltCapFS(bw){ var a=beltFS(bw,0.12), b=hudFS(TYPE.micro), pa=parseFloat(((/([\d.]+)px/).exec(a)||[0,0])[1])||0, pb=parseFloat(((/([\d.]+)px/).exec(b)||[0,0])[1])||0; return (pb>pa)?b:a; }
'@

SubRx @'
      ctx.font=beltFS(bw,0.12); ctx.textAlign='center';   // v18.71: grows with the slots under it
'@ @'
      ctx.font=beltCapFS(bw); ctx.textAlign='center';   // v18.71: grows with the slots under it; v19.66: and with the screen
'@

SubRx @'
  cap=Math.round(Math.max(LH(11),bw0*0.12));   // the belt caption over the slots (v18.71)
'@ @'
  cap=Math.round(Math.max(LH(11),parseFloat(((/([\d.]+)px/).exec(beltCapFS(bw0))||[0,11])[1])||11));   // the belt caption over the slots (v18.71), at the size it is drawn (v19.66)
'@

SubRx @'
var VER='19.65';
'@ @'
var VER='19.66';
'@

$pat = "(?m)^  now:'v19\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.66: At 4K the hint over the belt is full size. Check 19.66 fails on v19.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
