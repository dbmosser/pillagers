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

# PIXEL FIGHT STATES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!st||iv>0||OPX.inScr) return false;   // v33.78 (cw-pixhurt): low health is drawn in pixels now; v33.81 (cw-pixgear): armour too
'@ @'
  if(!st||OPX.inScr) return false;   // v28.xx (cw-cx-pixfight): invulnerability and the wall ghost keep the cached pixel silhouette
'@

SubRx @'
  if(hurt||lw){
    fx={wc:'',wa:0,ra:0};
'@ @'
  if(hurt||lw||iv>0){
    fx={wc:'',wa:0,ra:0,iv:iv>0};   // v28.xx (cw-cx-pixfight): a cached teal mask preserves the invulnerability cue, under the hit flash
'@

SubRx @'
  a0=wc.globalAlpha;
  if(fx.wa>0){ wc.globalAlpha=a0*fx.wa; pxBlit(pxTint(spr,fx.wc),wx,wy,m); }
'@ @'
  a0=wc.globalAlpha;
  if(fx.iv){ wc.globalAlpha=a0*0.35; pxBlit(pxTint(spr,'#2a6a5e'),wx,wy,m); }   // v28.xx (cw-cx-pixfight): silhouette only; inherit the wall ghost alpha
  if(fx.wa>0){ wc.globalAlpha=a0*fx.wa; pxBlit(pxTint(spr,fx.wc),wx,wy,m); }
'@

SubRx @'
var VER='33.89';
'@ @'
var VER='33.90';
'@

$pat = "(?m)^  now:'v33\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.90: Invulnerable pillagers keep their pixel silhouette and teal cue. The wall ghost keeps its transparency. Check 33.90 fails on v33.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
