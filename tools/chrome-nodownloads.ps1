# chrome-nodownloads.ps1 (10-27): dot-sourced by every script that starts a test or robot Chrome (cdp.ps1, uishots.ps1, soak4k.ps1).
# His order (10-27, via the main PC Claude): "make sure we are always getting game telemetry back from the main pc". The robots block the
# 8799 report receiver on purpose, so the game's fallback saved their blank demo notes as files, and a headless Chrome saves a file into
# the Downloads folder of whoever is signed in: 585 of them landed in his since 10-18. Before the Chrome starts, Set-NoDownloads points its
# own profile's download folder at <profile>\downloads (Chrome reads Default\Preferences when it starts; tested 10-27 on a fresh and on a
# used profile) and clears files there older than a day. It touches only that test profile: never his own Chrome, never his Downloads.
# A Preferences file it cannot read is left as it is. ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
function Set-NoDownloads([string]$prof){
  try{
    if(-not $prof){ return }
    $dl=Join-Path $prof 'downloads'
    New-Item -ItemType Directory -Force -Path (Join-Path $prof 'Default'),$dl | Out-Null
    Get-ChildItem -LiteralPath $dl -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } | Remove-Item -Force -ErrorAction SilentlyContinue
    $pf=Join-Path $prof 'Default\Preferences'; $o=$null
    if(Test-Path -LiteralPath $pf){
      try{ $o=[IO.File]::ReadAllText($pf) | ConvertFrom-Json }catch{ return }
      if(-not $o){ return }
      if($o.download -and $o.download.default_directory -eq $dl -and $o.download.prompt_for_download -eq $false){ return }
    } else { $o=New-Object PSObject }
    foreach($k in @('download','savefile')){ if(-not $o.PSObject.Properties[$k]){ $o | Add-Member -NotePropertyName $k -NotePropertyValue (New-Object PSObject) } }
    $o.download | Add-Member -NotePropertyName default_directory -NotePropertyValue $dl -Force
    $o.download | Add-Member -NotePropertyName prompt_for_download -NotePropertyValue $false -Force
    $o.download | Add-Member -NotePropertyName directory_upgrade -NotePropertyValue $true -Force
    $o.savefile | Add-Member -NotePropertyName default_directory -NotePropertyValue $dl -Force
    [IO.File]::WriteAllText($pf,($o | ConvertTo-Json -Depth 100 -Compress),(New-Object Text.UTF8Encoding $false))
  }catch{}
}
