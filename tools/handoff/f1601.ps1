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

if ($s.Contains("  {v:'16.01',what:")) { throw "check 16.01 is in the fixture already" }

SubRx @'
  {v:'16.00',what:'rain and fog draw at night strength on
'@ @'
  {v:'16.01',what:'the storm says what the lightning does: the storm line and the CONDITIONS row no longer promise that the flash shows you to the machines, which no sight rule reads, and still say it strikes',
   run:function(){
     if(typeof WEATHER==='undefined'||typeof drawHUD!=='function') return 'SKIP: this build cannot report its weather words';
     var bad=[], st=null, i, hud=String(drawHUD);
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='storm') st=WEATHER[i];
     if(!st) return 'SKIP: no storm in this build';
     if((/show you to everything/i).test(st.line)) bad.push('the storm line still says the lightning will show you to everything out there: '+st.line);
     if(!(/lightning/i).test(st.line)) bad.push('the storm line no longer names the lightning: '+st.line);
     if((/lightning shows you'/).test(hud)) bad.push('the CONDITIONS row still says lightning shows you');
     if(!(/lightning strikes/).test(hud)) bad.push('the CONDITIONS row no longer names the lightning');
     return bad.length?bad.join('; '):null; }},
  {v:'16.00',what:'rain and fog draw at night strength on
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
