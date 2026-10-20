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

if ($s.Contains("  {v:'32.35',what:")) { throw "check 32.35 is in the fixture already" }

SubRx @'
  {v:'32.34',what:
'@ @'
  {v:'32.35',what:'the extract inbound countdown line is drawn in the big-number size, not the callout size (critic 37)',
   run:function(){
     if(typeof extBanFont!=='function') return 'the extract banner has no font function (extBanFont)';
     var a=parseFloat((/([\d.]+)px/).exec(extBanFont(12))[1]), b=parseFloat((/([\d.]+)px/).exec(extBanFont(0))[1]);
     if(a<=b*1.5) return 'inbound line '+a+'px is not clearly bigger than the landed line '+b+'px';
     if(String(drawHUD).indexOf('extBanFont(G.beaconT)')<0) return 'drawHUD does not use extBanFont';
     return null;
   }},
  {v:'32.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
