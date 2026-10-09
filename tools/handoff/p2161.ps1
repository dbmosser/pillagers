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

# THE DOWNED SCREEN SHOWS YOUR EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      '['+keyLabel('KeyF','F')+'] SELF-REVIVE, one per raid',W/2,_rowY);
'@ @'
      '['+keyLabel('KeyF','F')+'] SELF-REVIVE, one per raid',W/2,_rowY);
    // v21.61, HIS NOTE (2026-10-09): "when downed and holding E to extract, there's no clear progress bar on the downed screen that tells
    // you that you are extracting". The ring prompt and its hold bars are drawn only for a player on his feet, so a downed player
    // holding E in a ring saw nothing move. The downed screen now shows the hold itself, as large as the bleed bar above it.
    if(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)){
      var _xp=(padZ.pullT||0)>0, _xf=_xp?clamp(padZ.pullT/1.4,0,1):clamp(padZ.callT/1.6,0,1), _xc=_xp?'#7fc4a0':'#4de3d0';
      _rowY+=Math.round(_hD*1.35);
      ctx.font=_fD; ctx.fillStyle=_xc;
      ctx.fillText(_xp?'EXTRACTING':'CALLING EXTRACTION',W/2,_rowY);
      bar(W/2-100,_rowY+Math.round(_hD*0.4),200,10,_xf,_xc);
      _rowY+=Math.round(_hD*0.4)+10;
    }
'@

SubRx @'
var VER='21.60';
'@ @'
var VER='21.61';
'@

$pat = "(?m)^  now:'v21\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.61: Downed and holding E in an extraction ring, the downed screen shows a clear EXTRACTING bar. Check 21.61 fails on v21.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
