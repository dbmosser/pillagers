$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'34.69',what:")) { throw "check 34.69 is in the fixture already" }

SubRx @'
  {v:'34.68',what:
'@ @'
  {v:'34.69',what:'the corner panels share one fill, one line and one radius (hudPlate and hudPanel read HUDPS; the critic: every corner has a differently shaped box)',
   run:function(){
     if(typeof HUDPS==='undefined') return 'no shared corner panel style (HUDPS)';
     if(HUDPS.fill!==HUDC.plate) return 'the panel fill is not the HUD plate fill';
     if(!(HUDPS.rad===4)) return 'the radius is '+HUDPS.rad+', not 4';
     var a=String(hudPlate), b=String(hudPanel);
     if(a.indexOf('HUDPS.fill')<0||a.indexOf('HUDPS.line')<0) return 'hudPlate does not read the shared fill and line';
     if(b.indexOf('HUDPS.line')<0||b.indexOf('HUDPS.rad')<0) return 'hudPanel does not read the shared line and radius';
     if(b.indexOf('lineTo')>=0) return 'hudPanel still draws a cut corner';
     return null; }},
  {v:'34.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
