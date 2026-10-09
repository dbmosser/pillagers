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

if ($s.Contains("  {v:'21.57',what:")) { throw "check 21.57 is in the fixture already" }

SubRx @'
  {v:'21.56',what:
'@ @'
  {v:'21.57',what:'on a run card that scrolls, the scrollbar track keeps clear of the rounded corners',
   run:function(){
     var i, j, ss=document.styleSheets, R, hit=false;
     for(i=0;i<ss.length&&!hit;i++){ try{ R=ss[i].cssRules||[]; }catch(e){ continue; }
       for(j=0;j<R.length;j++) if(R[j].selectorText&&R[j].selectorText.indexOf('.ocwin::-webkit-scrollbar-track')>=0&&/margin/.test(R[j].cssText)){ hit=true; break; } }
     return hit?null:'the run card scrollbar track has no margin, so its thumb runs past the rounded corners';
   }},
  {v:'21.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
