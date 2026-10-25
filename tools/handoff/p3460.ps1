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

# AIR STRIKE PLATE CLEARS THE CHIPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  E=[HUDBOX.gear,handPlateBox(),(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.pick:null,
'@ @'
  E=[HUDBOX.gear,handPlateBox(),(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.chips:null,(typeof EDGEBOX==='object'&&EDGEBOX)?EDGEBOX.pick:null,   /* v28.xx (cw-airchips): the power-up chips are an obstacle too; at 4K four chips reached the plate at the right end of the gun bar */ 
'@

SubRx @'
    x0=Math.round(W/2-tot/2); y0=Math.round(miny-24*z);
'@ @'
    x0=Math.round(W/2-tot/2); y0=Math.round(miny-24*z); EDGEBOX.chips={x:x0,y:y0,w:tot,h:Math.round(24*z)};   // v28.xx (cw-airchips): where the chip row is, so the air strike plate keeps clear of it
'@

SubRx @'
  sc=w2s(p.x,0,p.y); n=0;
'@ @'
  sc=w2s(p.x,0,p.y); n=0; EDGEBOX.chips=null;   // v28.xx (cw-airchips): cleared each frame, set again below while chips show
'@

SubRx @'
var VER='34.59';
'@ @'
var VER='34.60';
'@

$pat = "(?m)^  now:'v34\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.60: At 4K the air strike plate no longer sits on the power-up chips. Check 34.60 fails on v34.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
