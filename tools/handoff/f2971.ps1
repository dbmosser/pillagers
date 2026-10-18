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

if ($s.Contains("  {v:'29.71',what:")) { throw "check 29.71 is in the fixture already" }

SubRx @'
  {v:'29.70',what:
'@ @'
  {v:'29.71',what:'the Undercroft credits line is not amber, the picked contract row has no amber outline, and the window sub lines are 16px',
   run:function(){
     var bad=[], el=null;
     try{
       var rp=document.getElementById('repline'), ww=document.getElementById('wallet_work');
       [rp,ww].forEach(function(n,i){ if(!n){ bad.push('missing line '+i); return; }
         var c=getComputedStyle(n).color; if(/rgb\(24[0-9],\s*18[0-9],\s*59\)/.test(c)) bad.push('line '+i+' is amber '+c); });
       if(rp&&rp.parentNode){ var fs=parseFloat(getComputedStyle(rp.parentNode).fontSize); if(fs<16) bad.push('the sub line is '+fs+'px, not 16'); }
       var rt=document.getElementById('root')||document.body, box=document.getElementById('contracts');
       if(box){
         el=document.createElement('div'); el.className='crow sel'; el.setAttribute('data-con','9'); el.style.borderColor='var(--amber)';
         el.innerHTML='<div class="cd">x</div><div class="cp"><span>0 / 1</span></div>'; el.style.display='none'; box.appendChild(el);
         var bc=getComputedStyle(el).borderBottomColor; if(/rgb\(24[0-9],\s*18[0-9],\s*59\)/.test(bc)) bad.push('the picked row keeps an amber outline '+bc);
       } else bad.push('no contracts list');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(el&&el.parentNode) el.parentNode.removeChild(el); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
