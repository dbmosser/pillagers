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

if ($s.Contains("  {v:'29.53',what:")) { throw "check 29.53 is in the fixture already" }

SubRx @'
  {v:'29.52',what:
'@ @'
  {v:'29.53',what:'the end card has a 56px hero total, a near-solid scrim and a quiet feedback link (critic: no hero line, HUD bleeds, third control; screens 35 38 77)',
   run:function(){
     var oc=document.getElementById('outcome'), win=oc&&oc.querySelector('.ocwin'), fb=document.getElementById('fbhead'), d, res=null, a;
     if(!oc||!win||!fb) return 'SKIP: no end card here';
     d=document.createElement('div'); d.className='haultot'; win.appendChild(d);
     try{
       if(parseFloat(getComputedStyle(d).fontSize)<56) res='the haul total is '+getComputedStyle(d).fontSize+', not 56px';
     }finally{ win.removeChild(d); }
     if(res) return res;
     a=/rgba?\([^)]*?,\s*([\d.]+)\)/.exec(getComputedStyle(oc).backgroundColor);
     if(!a||parseFloat(a[1])<0.9) return 'the scrim is '+getComputedStyle(oc).backgroundColor+', the HUD reads through';
     if(getComputedStyle(fb).borderTopWidth!=='0px') return 'the feedback prompt still has a box';
     return null;
   }},
  {v:'29.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
