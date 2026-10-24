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

# DOWNED CARD: BIGGER LABEL, LIME KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.font=_fD; ctx.fillStyle=UIC.danger; ctx.fillText('DOWN',W/2,_dy-Math.round((_hH-_hD)*0.5));
'@ @'
ctx.font=FS(TYPE.title); ctx.fillStyle=UIC.danger; ctx.fillText('DOWN',W/2,_dy-Math.round((_hH-_dpx(FS(TYPE.title)))*0.5));   // v34.40 (cw-downedcard2), critic on screen 34 (P1 'the small down label is easy to miss'): the danger label is the title size (26), the timer stays the one hero
'@

SubRx @'
ctx.fillText(p.revived?'Bleeding out. Crawl to an open extraction point.':
      '['+keyLabel('KeyF','F')+'] SELF-REVIVE, one per raid',W/2,_rowY);
'@ @'
if(p.revived) ctx.fillText('Bleeding out. Crawl to an open extraction point.',W/2,_rowY);
    else{   // v34.40 (cw-downedcard2), critic on screen 34 (P1 'make the self-revive prompt the lime action'): the live key is the accent, the rest is the text colour
      var _k1='['+keyLabel('KeyF','F')+']', _k2=' SELF-REVIVE, one per raid', _kw=ctx.measureText(_k1.toLowerCase()).width, _kx=W/2-(_kw+ctx.measureText(_k2.toLowerCase()).width)/2;
      ctx.textAlign='left'; ctx.fillStyle=UIC.acc; ctx.fillText(_k1,_kx,_rowY); ctx.fillStyle=UIC.tx_1; ctx.fillText(_k2,_kx+_kw,_rowY); ctx.textAlign='center';
    }
'@

SubRx @'
var VER='34.40';
'@ @'
var VER='34.41';
'@

$pat = "(?m)^  now:'v34\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.41: On the downed card the word down is bigger and the self-revive key shows in lime. Check 34.41 fails on v34.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
