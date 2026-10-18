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

if ($s.Contains("  {v:'29.59',what:")) { throw "check 29.59 is in the fixture already" }

SubRx @'
  {v:'29.58',what:
'@ @'
  {v:'29.59',what:'the Keys window has no separate Rebind box: the key cap is the control, and it waits for a press',
   run:function(){
     if(typeof keysOpen!=='function') return 'SKIP: no Keys window here';
     var bad=[], l, rb, kb, sec, s, wasWait;
     try{
       keysOpen(); l=document.getElementById('keyslist');
       if(!l) return 'SKIP: the Keys window did not build';
       rb=l.querySelector('.rebind'); kb=l.querySelector('.keybtn[data-k="KeyE"]'); sec=l.querySelector('.keysec');
       if(rb&&getComputedStyle(rb).display!=='none') bad.push('a Rebind box still shows beside the key cap');
       if(sec&&getComputedStyle(sec).color===getComputedStyle(document.documentElement).getPropertyValue('--acc').trim()) bad.push('a section head is still amber');
       if(sec&&!(parseFloat(getComputedStyle(sec).fontSize)>=16)) bad.push('a section head is '+getComputedStyle(sec).fontSize);
       if(!kb) bad.push('no key cap for the search key'); else { kb.click(); if(KEYS.waiting!=='KeyE') bad.push('the key cap did not wait for a press'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ KEYS.waiting=null; var m=document.getElementById('keysmodal'); if(m) m.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
