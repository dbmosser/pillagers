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

if ($s.Contains("  {v:'19.37',what:")) { throw "check 19.37 is in the fixture already" }

SubRx @'
  {v:'19.36',what:
'@ @'
  {v:'19.37',what:'the run card button strip sits on the card edge: on a card that scrolls, nothing shows between the pinned buttons and the bottom of the card',
   run:function(){
     var oc=document.getElementById('outcome'), w=oc&&oc.querySelector('.ocwin'), a=oc&&oc.querySelector('.ocacts'), was=oc&&oc.classList.contains('on'), mh, bad=[], wr, ar, bw;
     if(!oc||!w||!a) return 'SKIP: no run card here';
     try{
       oc.classList.add('on'); mh=w.style.maxHeight; w.style.maxHeight='260px'; w.scrollTop=0;
       if(w.scrollHeight<=w.clientHeight+4) return 'SKIP: the card does not scroll even at 260 px';
       wr=w.getBoundingClientRect(); ar=a.getBoundingClientRect(); bw=parseFloat(getComputedStyle(w).borderBottomWidth)||0;
       if(wr.bottom-bw-ar.bottom>8) bad.push('there is a '+Math.round(wr.bottom-bw-ar.bottom)+' px band under the pinned buttons where the card shows through');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(w) w.style.maxHeight=mh||''; if(!was) oc.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
