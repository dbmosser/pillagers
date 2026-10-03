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

if ($s.Contains("  {v:'17.99',what:")) { throw "check 17.99 is in the fixture already" }

SubRx @'
  {v:'17.98',what:
'@ @'
  {v:'17.99',what:'a Settings change keeps its place: with the list scrolled and a button focused, a rebuild leaves the scroll where it was, the same button focused and the pad highlight on it',
   run:function(){
     if(typeof renderSettings!=='function'||typeof setKeep!=='function') return 'a Settings change still rebuilds the list from the top';
     var md=document.getElementById('settingsmodal'), host=document.getElementById('setlist'), bad=[], got, b, was=md&&md.classList.contains('on'), mh, ov;
     if(!md||!host) return 'SKIP: no Settings list in this fixture';
     mh=host.style.maxHeight; ov=host.style.overflowY;
     try{
       md.classList.add('on'); renderSettings();
       host.style.maxHeight='220px'; host.style.overflowY='auto';
       host.scrollTop=150; got=host.scrollTop;
       if(got<100) return 'SKIP: the list would not scroll in this pane ('+got+')';
       b=document.getElementById('set_kb'); if(!b) return 'SKIP: no kid row to focus';
       try{ b.focus({preventScroll:true}); }catch(_f){ b.focus(); }
       if(typeof padSetFocus==='function') padSetFocus(b);
       host.scrollTop=got;
       renderSettings();
       if(Math.abs(host.scrollTop-got)>2) bad.push('a rebuild moved the list from '+got+' to '+host.scrollTop);
       if(!document.activeElement||document.activeElement.id!=='set_kb') bad.push('the focused button was lost (now '+((document.activeElement&&document.activeElement.id)||'nothing')+')');
       if(typeof PAD==='object'&&PAD&&(!PAD.focus||PAD.focus.id!=='set_kb'||!PAD.focus.isConnected)) bad.push('the pad highlight was lost');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ host.style.maxHeight=mh; host.style.overflowY=ov; try{ if(typeof padSetFocus==='function') padSetFocus(null); }catch(_p){} try{ if(document.activeElement&&document.activeElement.blur) document.activeElement.blur(); }catch(_b){} if(!was) md.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'17.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
