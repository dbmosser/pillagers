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

# ACTIVE RELOAD CHAIN STATUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {id:'stim',  nm:'STIM',       col:'#ffd25a', bad:0},
'@ @'
  {id:'stim',  nm:'STIM',       col:'#ffd25a', bad:0},
  // v28.xx (cw-cx-reloadstatus), HIS WORDS (2026-10-28): active reload bonus stacks should be shown as a status.
  {id:'ar',    nm:'active reload x1', col:'#9fe8b0', bad:0},
'@

SubRx @'
    } else if(E.id==='rest'){
'@ @'
    } else if(E.id==='ar'){
      // v28.xx (cw-cx-reloadstatus): this window owns the chain; no timer or copied network count can outlive its reset.
      k=p.arStk||0;
      if(k>=1){
        E.on=true;
        t='active reload x'+k; if(E.nm!==t){ E.nm=t; E.nf=''; }
        // v28.xx (cw-cx-reloadstatus): a chain survives a swap or an empty magazine; only claim damage while the bonus applies.
        t=(p.arBonus&&p.wep===p.arGun&&p.ammo>0&&!(p.reloading>0))?'+'+Math.round(((p.arMul||AR_BONUS)-1)*100)+'% damage':'chain ready';
        if(E.vk!==t){ E.vk=t; E.v=t; }
      }
    } else if(E.id==='rest'){
'@

SubRx @'
function statusGlyph(id,cx,cy,u,col){
  ctx.beginPath();
  if(id==='heal'){
'@ @'
function statusGlyph(id,cx,cy,u,col){
  ctx.beginPath();
  if(id==='ar'){
    // v28.xx (cw-cx-reloadstatus): a reload arrow in the same plain-path family as the other status glyphs.
    ctx.lineWidth=u*0.27; ctx.lineCap='round'; ctx.arc(cx,cy,u*0.78,0.35,4.7); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx+u*0.35,cy-u*0.78); ctx.lineTo(cx-u*0.18,cy-u*1.10); ctx.lineTo(cx-u*0.18,cy-u*0.46); ctx.closePath(); ctx.fill();
    ctx.lineCap='butt';
  } else if(id==='heal'){
'@

SubRx @'
var VER='36.16';
'@ @'
var VER='36.17';
'@

$pat = "(?m)^  now:'v36\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.17: the active reload chain shows as a status with its count Check 36.17 fails on v36.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
