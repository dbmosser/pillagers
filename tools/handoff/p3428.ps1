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

# RAID HUD TYPE IS COUCH SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudFineFS(){
'@ @'
// v28.xx (cw-h103type), the critic on screen 21 ('a wrapping contract'): a contract line that wraps is shortened (Q8: shorter wording, same meaning) when the short form fits on one line. Run info only; the contract itself keeps its words.
function runInfoShort(t){ return String(t).replace(/^extract with a haul worth (\$[\d,]+) or more/i,'haul over $1').replace(/^extract carrying /i,'carry ').replace(/^search (\d+) containers in /i,'search $1 in '); }
// v28.xx (cw-h103type), the critic on screens 21 and 19 ('several fonts are too small to read from a couch'): the style guide floor is 16 px on the screen. The belt key numbers were 14.8, so the belt fonts are raised to 16 on the screen (the size is divided by the HUD zoom in force at the call).
function hudFloor16(f){ var m=/([\d.]+)px/.exec(f); if(!m) return f; var a=(typeof ctx==='object'&&ctx&&ctx.getTransform)?ctx.getTransform().a:1; if(!(a>0)) a=1; var need=Math.ceil(16/a*10)/10; return (parseFloat(m[1])<need)?f.replace(/([\d.]+)px/,need+'px'):f; }
function hudFineFS(){
'@

SubRx @'
return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
'@ @'
return hudFloor16((want>n)?f.replace((/([\d.]+)px/),want+'px'):f); }
'@

SubRx @'
best=greedy(inner); n=best.length; lo=inner*0.4; hi=inner;
'@ @'
best=greedy(inner);
      if(best.length>1){ var _t0=t, _b2; t=runInfoShort(t); if(t!==_t0){ _b2=greedy(inner); if(_b2.length<best.length) best=_b2; else t=_t0; } }   // v28.xx (cw-h103type): one line when the short form fits
      n=best.length; lo=inner*0.4; hi=inner;
'@

SubRx @'
ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=HUDC.dim;
'@ @'
ctx.font=hudFloor16(hudFS(TYPE.micro)); ctx.textAlign='center'; ctx.fillStyle=HUDC.dim;   // v28.xx (cw-h103type): the north mark on the minimap is 16 px on the screen too
'@

SubRx @'
var VER='34.27';
'@ @'
var VER='34.28';
'@

$pat = "(?m)^  now:'v34\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.28: The belt key numbers are bigger. A long contract in the run info box is worded shorter so it stays on one line. Check 34.28 fails on v34.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
