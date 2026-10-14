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

if ($s.Contains("  {v:'26.10',what:")) { throw "check 26.10 is in the fixture already" }

SubRx @'
  {v:'26.09',what:
'@ @'
  {v:'26.10',what:'his rule, CLOSE and ESC on every menu: the feedback window has a way out that says CLOSE, and ESC closes it',
   run:function(){
     var m=document.getElementById('fbmodal'), bad=[], b, on0;
     if(!m||typeof fbOpen!=='function'||typeof fbClose!=='function') return 'SKIP: no feedback window here';
     on0=m.classList.contains('on');
     try{
       b=m.querySelector('[data-esc]');
       if(!b) bad.push('the feedback window has no way out marked for ESC');
       else if(b.textContent.trim()!=='CLOSE') bad.push('the way out of the feedback window says '+JSON.stringify(b.textContent.trim())+', not CLOSE');
       fbOpen();
       if(!m.classList.contains('on')) return 'SKIP: the feedback window would not open here';
       document.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       if(m.classList.contains('on')) bad.push('ESC did not close the feedback window');
       fbOpen();
       if(b) b.click();
       if(m.classList.contains('on')) bad.push('the way out of the feedback window did not close it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ fbClose(); }catch(_e){} if(on0) m.classList.add('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'26.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
