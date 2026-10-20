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

if ($s.Contains("  {v:'32.09',what:")) { throw "check 32.09 is in the fixture already" }

SubRx @'
  {v:'32.08',what:
'@ @'
  {v:'32.09',what:'the pad picture marks each control with a dot and keeps lime off the key names (critic: lime was decoration on 20 labels)',
   run:function(){
     if(typeof padPictureHtml!=='function') return 'SKIP: no pad picture';
     var h=padPictureHtml();
     if(h.indexOf('<tspan fill="var(--acc')>=0) return 'key names are still lime';
     if((h.match(/<circle cx="\d+" cy="\d+" r="5"/g)||[]).length<16) return 'the leaders have no dots';
     return null; }},
  {v:'32.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
