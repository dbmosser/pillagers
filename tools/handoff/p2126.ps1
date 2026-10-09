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

# A CONTROLLER ONLY STOPS THE ATTRACT CLIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(padMenu(pressed)){ padRelease(); return; }
'@ @'
  // v21.26, from the review of 2026-10-09 (R8): WHILE THE ATTRACT CLIP PLAYS, A CONTROLLER ONLY STOPS IT. The clip watched the pad
  // only twice a second and the title menu under it took A every frame, so a tap could click the hidden menu. Any button or stick
  // now stops the clip, the press is held as already seen so it does nothing else, and the menu waits.
  if(typeof ATT!=='undefined'&&ATT&&ATT.on){
    var _atb=false, _ati;
    for(_ati=0;_ati<bt.length;_ati++) if(pressed(_ati)) _atb=true;
    for(_ati=0;_ati<ax.length;_ati++) if(Math.abs(ax[_ati]||0)>0.45) _atb=true;
    if(_atb) attPoke();
    for(_ati=0;_ati<bt.length;_ati++) PAD.prev[_ati]=pressed(_ati);
    padRelease(); return;
  }
  if(padMenu(pressed)){ padRelease(); return; }
'@

SubRx @'
var VER='21.25';
'@ @'
var VER='21.26';
'@

$pat = "(?m)^  now:'v21\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.26: A controller press during the title gameplay clip only stops the clip. Check 21.26 fails on v21.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
