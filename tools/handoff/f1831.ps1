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

if ($s.Contains("  {v:'18.31',what:")) { throw "check 18.31 is in the fixture already" }

SubRx @'
  {v:'18.30',what:
'@ @'
  {v:'18.31',what:'stage D of the styling pass: the run card is a rounded glass card with a drop shadow, the outcome word glows, the feel tags are pills and LOG RUN AND RETURN is a gradient primary button',
   run:function(){
     var w=document.querySelector('#outcome .ocwin'), h=document.getElementById('oc_title'), b=document.getElementById('oc_btn'), tw=document.getElementById('tagwrap'), t=document.createElement('span'), bad=[], s, o=document.getElementById('outcome'), was=o&&o.classList.contains('on');
     if(!w||!h||!b||!tw) return 'SKIP: no run card here';
     t.className='tag'; t.textContent='x'; tw.appendChild(t);
     try{
       if(o&&!was) o.classList.add('on');
       s=getComputedStyle(w); if(parseFloat(s.borderTopLeftRadius)<10) bad.push('the card corners are '+s.borderTopLeftRadius); if(!/rgba\(0, 0, 0/.test(s.boxShadow)) bad.push('the card has no drop shadow');
       s=getComputedStyle(h); if(!s.textShadow||s.textShadow==='none') bad.push('the outcome word has no glow');
       s=getComputedStyle(t); if(parseFloat(s.borderTopLeftRadius)<12) bad.push('the feel tags are square ('+s.borderTopLeftRadius+')');
       s=getComputedStyle(b); if(!/gradient/.test(s.backgroundImage)) bad.push('LOG RUN AND RETURN is flat');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ tw.removeChild(t); }catch(_r){} if(o&&!was) o.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
