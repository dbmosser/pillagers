$files = @('C:\claudecode\dark raiders\tools\handoff\f1021.ps1', 'C:\claudecode\dark raiders\tools\mkfixture.ps1')
$old1 = "var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,cosFace:P2.cosFace,cosHat:P2.cosHat};`r`n     P2.runs=999; P2.ext=999; P2.kills={warden:9}; P2.cosHat='none';"
$new1 = "var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,cosFace:P2.cosFace,cosHat:P2.cosHat,cosBeard:P2.cosBeard};`r`n     P2.runs=999; P2.ext=999; P2.kills={warden:9}; P2.cosHat='none'; P2.cosBeard='clean';   // a beard left worn by an earlier check hid mud and freckles"
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f)
  $o = $old1; $nw = $new1
  if ($t.IndexOf($o) -lt 0) { $o = $old1.Replace("`r`n", "`n"); $nw = $new1.Replace("`r`n", "`n") }
  $c = ([regex]::Matches($t, [regex]::Escape($o))).Count
  if ($c -ne 1) { Write-Output "$f : matched $c"; continue }
  $t = $t.Replace($o, $nw)
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "$f : beard staged"
}
