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

SubRx @'
      // there is genuinely nothing to do about it.
if(!p.fired||p.wep.auto){
        if(p.reserve>0&&p.reloading<=0){
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim){ say('Reloading...'); blip('reload'); }   // v10.56
        } else if(p.reserve<=0&&!p.fired){ say('Out of ammo.'); if(!G.sim) blip('dry'); }   // v10.56: an empty gun clicks
'@ @'
      // there is genuinely nothing to do about it.
      // v15.30, sound audit finding: AN AUTOMATIC GUN THAT RUNS DRY ON A HELD TRIGGER CLICKS ONCE. The dry click and Out of
      // ammo below waited for a fresh pull (!p.fired), and an automatic keeps p.fired set from its last round until the trigger
      // is let go, so holding the trigger through the last rounds with nothing left in the backpack just stopped the gun: no
      // click, no line, only NO AMMO by the crosshair. The click keeps its own flag now (dryTold), set when it plays and cleared
      // on release, so an empty automatic clicks and says it once per pull, as a single shot gun always did on its pull, and
      // neither repeats while the trigger stays held. The same sound and the same line; no seeded draw.
if(!p.fired||p.wep.auto){
        if(p.reserve>0&&p.reloading<=0){
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim){ say('Reloading...'); blip('reload'); }   // v10.56
        } else if(p.reserve<=0&&!p.dryTold){ p.dryTold=1; say('Out of ammo.'); if(!G.sim) blip('dry'); }   // v10.56: an empty gun clicks
'@
SubRx @'
      releaseCook();   // v13.42, HIS RULING: the last one thrown leaves its cell selected; he brings the gun up himself
    }
    p.fired=false;
'@ @'
      releaseCook();   // v13.42, HIS RULING: the last one thrown leaves its cell selected; he brings the gun up himself
    }
    p.fired=false;
    p.dryTold=0;   // v15.30, sound audit finding: AN AUTOMATIC GUN THAT RUNS DRY ON A HELD TRIGGER CLICKS ONCE. Let go, and the next pull on an empty gun clicks again.
'@
SubRx @'
var VER='15.29';
'@ @'
var VER='15.30';
'@

$pat = "(?m)^  now:'v15\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.30: AN AUTOMATIC GUN THAT RUNS DRY ON A HELD TRIGGER CLICKS ONCE. Holding the trigger of an automatic through its last rounds with no ammo left in the backpack just stopped the gun, with no dry click and no Out of ammo line, because both waited for a fresh pull. The click keeps its own flag now, cleared when the trigger is let go, so an empty automatic clicks and says Out of ammo once and neither repeats while held. Check 15.30 holds an automatic through its last two rounds and four empty frames and requires one dry click and one line, and a fresh pull after letting go clicks again; it fails on v15.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
