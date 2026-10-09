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

if ($s.Contains("  {v:'21.26',what:")) { throw "check 21.26 is in the fixture already" }

SubRx @'
  {v:'21.25',what:
'@ @'
  {v:'21.26',what:'while the attract clip plays, the controller poll stops the clip and never reaches the title menu',
   run:function(){
     if(typeof pollPad!=='function'||typeof ATT!=='object') return 'SKIP: no attract mode here';
     var src=String(pollPad), i=src.indexOf('padMenu(pressed)'), j=src.indexOf('ATT.on');
     if(i<0) return 'SKIP: the pad menu hand off moved';
     if(j<0||j>i) return 'a controller press during the attract clip still reaches the hidden title menu';
     return null; }},
  {v:'21.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
