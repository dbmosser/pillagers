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

if ($s.Contains("  {v:'19.06',what:")) { throw "check 19.06 is in the fixture already" }

SubRx @'
  {v:'19.05',what:
'@ @'
  {v:'19.06',what:'the pause key line never breaks an entry: every key and its words sit in one unbreakable piece',
   run:function(){
     if(typeof keysLegendApply!=='function') return 'SKIP: no pause key line here';
     var el=document.getElementById('pausekeys'), parts, sp, bad=[];
     if(!el) return 'SKIP: no pause key line';
     keysLegendApply();
     parts=String(keysLegendHtml()).split(' &nbsp; ').length;
     sp=el.querySelectorAll('span[style*="nowrap"]').length;
     if(sp<parts) bad.push(sp+' of '+parts+' entries are kept on one line');
     return bad.length?bad.join('; '):null; }},
  {v:'19.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
