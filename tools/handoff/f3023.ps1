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

if ($s.Contains("  {v:'30.23',what:")) { throw "check 30.23 is in the fixture already" }

SubRx @'
  {v:'30.22',what:
'@ @'
  {v:'30.23',what:'modal cards are a plain rectangle with a 36 wide accent tab, no chamfer (critic 49 pause card)',
   run:function(){
     var m, cs, bg, cp, bs;
     m=document.createElement('div'); m.className='modal on'; m.id='__cwflat'; m.style.visibility='hidden';
     (document.getElementById('root')||document.body).appendChild(m);
     try{
       cs=getComputedStyle(m,'::before'); cp=String(cs.clipPath); bs=String(cs.backgroundSize);
       if(cp!=='none') return 'the modal card still has a chamfer: '+cp.slice(0,40);
       if(bs.indexOf('36px 2px')!==0) return 'the accent tab is not 36 x 2: '+bs.slice(0,40);
       bg=String(cs.backgroundImage);
       if(/135deg/.test(bg)) return 'the corner tick gradient is still drawn';
     }finally{ try{ m.remove(); }catch(e){} }
     return null; }},
  {v:'30.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
