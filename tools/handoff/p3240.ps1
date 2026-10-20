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

# READABLE FORGE PRICES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function forgeOpen(){
'@ @'
// v28.xx (cw-cx-forgeread): the forge uses the guide's full head and label sizes, with a quiet dollar price.
function drawForgePrompt(x,y){
  var info=forgePromptInfo();
  return hudPromptDraw(info.line,x,y,{sub:info.sub,subCol:info.short?UIC.danger:UIC.tx_1,accent:info.short?UIC.danger:UIC.acc});
}
function forgeOpen(){
'@

SubRx @'
    hudPrompt(_fi.line,_fpp.x,_fpp.y,{sub:_fi.sub,subCol:_fi.short?UIC.danger:UIC.acc,accent:_fi.short?UIC.danger:FORGE_GOLD});
'@ @'
    drawForgePrompt(_fpp.x,_fpp.y);
'@

SubRx @'
  G.gunCard={gk:nw.id,w:nw,vs:w,route:tag+'  -'+forgeMoney(o.cost),t0:G.t||0};
'@ @'
  G.gunCard={gk:nw.id,w:nw,vs:w,route:'cost '+forgeMoney(o.cost),t0:G.t||0};   // v28.xx (cw-cx-forgeread): name the debit as the upgrade cost.
'@

SubRx @'
var VER='32.39';
'@ @'
var VER='32.40';
'@

$pat = "(?m)^  now:'v32\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.40: The forge action and dollar price use full HUD font sizes. The gun card names the upgrade cost. Check 32.40 fails on v32.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
