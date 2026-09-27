param([string]$Key,[int]$New,[string]$Now)
$ErrorActionPreference='Stop'
$sp=Split-Path -Parent $MyInvocation.MyCommand.Definition
$H='C:\claudecode\dark raiders\tools\handoff'
$d=Get-Content -Raw (Join-Path $sp ("draft-"+$Key+".json")) | ConvertFrom-Json
$prev=$New-1
$V=('{0}.{1:00}' -f [math]::Floor($New/100),($New%100)); $PV=('{0}.{1:00}' -f [math]::Floor($prev/100),($prev%100))
$edits=@($d.edits)
$hdr=(Get-Content (Join-Path $H ("p"+$prev+".ps1")) -TotalCount 13) -join "`n"
$p=$hdr+"`n`n# "+$d.title+" (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).`n"
foreach($e in $edits){
  $a=([string]$e.anchor).Replace("`r",''); $r=([string]$e.replacement).Replace("`r",'').Replace('v16.xx','v'+$V)
  if($a -match "(?m)^'@" -or $r -match "(?m)^'@"){ throw 'here-string terminator inside an edit' }
  $p+="`nSubRx @'`n"+$a+"`n'@ @'`n"+$r+"`n'@`n"
}
$p+="`nSubRx @'`nvar VER='"+$PV+"';`n'@ @'`nvar VER='"+$V+"';`n'@`n"
$p+="`n`$pat = `"(?m)^  now:'v"+$PV.Replace('.','\.')+":.*`$`"`n`$c = ([regex]::Matches(`$s, `$pat)).Count`nif (`$c -ne 1) { throw `"DEVNOW now line matched `$c times, expected 1`" }`n"
$p+="`$new = `"  now:'v"+$V+": "+$Now+" Check "+$V+" fails on v"+$PV+"',`"`n"
$p+="`$s = [regex]::Replace(`$s, `$pat, { param(`$m) `$new })`nif (([regex]::Matches(`$s, `"(?m)^  now:'`")).Count -ne 1) { throw `"more than one now key in DEVNOW`" }`n`$script:s = `$s`n"
$p+="`n`$src = [IO.File]::ReadAllText(`$MyInvocation.MyCommand.Definition)`n`$want = ([regex]::Matches(`$src, `"(?m)^SubRx @'`")).Count`nif (`$n -ne `$want) { throw `"expected `$want edits, made `$n`" }`n[IO.File]::WriteAllText(`$p, `$script:s, (New-Object Text.UTF8Encoding `$false))`nWrite-Output `"OK, `$n edits applied plus DEVNOW`"`n"
$fh=(Get-Content (Join-Path $H ("f"+$prev+".ps1")) -TotalCount 13) -join "`n"
$chk=([string]$d.check).Replace("`r",'').Replace("{v:'VER'","{v:'"+$V+"'").TrimEnd()
if($chk -match "(?m)^'@"){ throw 'here-string terminator inside the check' }
$f=$fh+"`n`nif (`$s.Contains(`"  {v:'"+$V+"',what:`")) { throw `"check "+$V+" is in the fixture already`" }`n`nSubRx @'`n  {v:'"+$PV+"',what:`n'@ @'`n"+$chk+"`n  {v:'"+$PV+"',what:`n'@`n"
$f+="`n`$src = [IO.File]::ReadAllText(`$MyInvocation.MyCommand.Definition)`n`$want = ([regex]::Matches(`$src, `"(?m)^SubRx @'`")).Count`nif (`$n -ne `$want) { throw `"expected `$want edits, made `$n`" }`n[IO.File]::WriteAllText(`$p, `$script:s, (New-Object Text.UTF8Encoding `$false))`nWrite-Output `"OK, `$n edits applied`"`n"
foreach($t in @($p,$f)){ foreach($ch in $t.ToCharArray()){ if([int]$ch -gt 126){ throw ('non-ASCII character '+[int]$ch) } } }
[IO.File]::WriteAllText((Join-Path $H ("p"+$New+".ps1")),$p,(New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText((Join-Path $H ("f"+$New+".ps1")),$f,(New-Object Text.UTF8Encoding $false))
$w=[string]$d.why
[IO.File]::WriteAllText((Join-Path $H ("cm"+$New+".txt")),("v"+$V+": "+$d.title.ToLower()+"`n`n"+$Now+"`n`nCheck "+$V+". Fails on v"+$PV+".`n`nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`n"),(New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText((Join-Path $H ("a"+$New+".txt")),("| "+$d.title+" | v"+$V+" | STABILITY (drafted and reviewed by agents 2026-09-27). MEASURED: "+$V+" passes, fails on v"+$PV+" |`n"),(New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText((Join-Path $H ("d"+$New+".txt")),("## v"+$V+" - "+$d.title+"`n`nStability pass before his co-op session. "+$w+"`n`nMEASURED. Check "+$V+" passes, and fails on v"+$PV+".`n"),(New-Object Text.UTF8Encoding $false))
"generated p$New f$New cm a d ($($edits.Count) edits)"
