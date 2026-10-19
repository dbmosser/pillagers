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

if ($s.Contains("  {v:'31.76',what:")) { throw "check 31.76 is in the fixture already" }

SubRx @'
  {v:'31.75',what:
'@ @'
  {v:'31.76',what:'detail pane stat rows are 16px with a dark --ui-line rule, not 15px with a cream rule',
   run:function(){
     var r=document.getElementById('root'); if(!r) return 'SKIP: no root';
     var d=document.createElement('div'); d.className='vdet'; d.style.cssText='position:absolute;left:-9999px;top:0';
     d.innerHTML='<div class="vstat" style="font-size:15px;padding:4px 0;border-bottom:1px solid #ddd5c4"><span>a</span><b>b</b></div>';
     r.appendChild(d);
     var cs=getComputedStyle(d.firstChild), fs=cs.fontSize, bc=cs.borderBottomColor, pd=cs.paddingTop;
     d.remove();
     if(fs!=='16px') return 'stat row font is '+fs+', not 16px';
     if(pd!=='6px') return 'stat row padding is '+pd+', not 6px';
     if(bc!=='rgb(46, 51, 55)') return 'stat row rule is '+bc+', not the --ui-line grey';
     return null; }},
  {v:'31.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
