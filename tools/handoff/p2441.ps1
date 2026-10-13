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

# THE DAMAGE NUMBER STAYS IN THE HEALTH BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // The number that was just taken off, floating clear of the bar and fading.
  if(p.dmgPopT>0&&p.lastDmg>0){
    var dpa=clamp(p.dmgPopT/1.05,0,1);
    ctx.save();
    ctx.font=FS(TYPE.title);
    ctx.fillStyle='rgba(232,86,70,'+dpa+')';
    ctx.fillText('-'+p.lastDmg,16+HBW+14,by+18-(1-dpa)*14);
    ctx.restore();
  }
'@ @'
  // The number that was just taken off, fading.
  // vNN.xx, UI REDESIGN ui5q1l (his #50 and #35, from the AAA judge of the raid fight shot): THE DAMAGE NUMBER STAYS IN THE HEALTH BAR.
  // It floated out past the right end of the bar, at 1080p straight over the frame of belt key 1. It is drawn inside the right end of
  // the bar now, over the lost health that it names, light red with a dark halo, never taller than the bar; it still fades.
  if(p.dmgPopT>0&&p.lastDmg>0){
    var dpa=clamp(p.dmgPopT/1.05,0,1), _dpf=FS(TYPE.title), _dpx=parseFloat((/([\d.]+)px/.exec(_dpf)||[0,20])[1]);
    if(_dpx>HBH*0.86) _dpf=_dpf.replace(/[\d.]+px/,(Math.round(HBH*0.86*10)/10)+'px');
    ctx.save();
    ctx.font=_dpf; ctx.textAlign='right'; ctx.textBaseline='middle';
    ctx.shadowColor='rgba(0,0,0,.85)'; ctx.shadowBlur=3;
    ctx.fillStyle='rgba(255,138,122,'+dpa+')';
    ctx.fillText('-'+p.lastDmg,16+HBW-8,by+HBH/2+1);
    ctx.restore();
  }
'@

SubRx @'
var VER='24.40';
'@ @'
var VER='24.41';
'@

$pat = "(?m)^  now:'v24\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.41: The damage number sits inside the right end of the health bar instead of over the belt. Check 24.41 fails on v24.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
