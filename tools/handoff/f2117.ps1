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

if ($s.Contains("  {v:'21.17',what:")) { throw "check 21.17 is in the fixture already" }

SubRx @'
  {v:'21.16',what:
'@ @'
  {v:'21.17',what:'attract mode: on the title after the idle time a clip plays over the screen with PRESS ANY KEY, a key stops it, and off the title it never shows',
   run:function(){
     if(typeof attTick!=='function'||typeof ATT!=='object') return 'control: there is no attract mode in this build';
     var bad=[], t=document.getElementById('title'), was=t&&t.classList.contains('on'), s0=ATT.src, tr0=ATT.tried, d;
     try{
       if(!t) return 'SKIP: no title screen';
       t.classList.add('on');
       ATT.src='data:video/mp4;base64,AAAA'; ATT.tried=true; ATT.last=Date.now()-(ATTRACT_IDLE+5)*1000;
       attTick();
       d=document.getElementById('attract');
       if(!ATT.on||!d||d.style.display!=='block') bad.push('after the idle time on the title no clip showed');
       else if(!/PRESS ANY KEY/.test(d.textContent||'')) bad.push('the clip does not say PRESS ANY KEY');
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyQ',key:'q',bubbles:true}));
       if(ATT.on||(d&&d.style.display!=='none')) bad.push('a key did not stop the clip');
       if(Date.now()-ATT.last>2000) bad.push('a key did not start the idle clock again');
       t.classList.remove('on'); ATT.last=Date.now()-(ATTRACT_IDLE+5)*1000;
       attTick();
       if(ATT.on) bad.push('the clip showed off the title');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ attStop(); }catch(_s){} ATT.src=s0; ATT.tried=tr0; ATT.last=Date.now(); if(t){ if(was) t.classList.add('on'); else t.classList.remove('on'); } }
     return bad.length?bad.join('; '):null; }},
  {v:'21.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
