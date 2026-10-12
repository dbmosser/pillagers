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

if ($s.Contains("  {v:'23.85',what:")) { throw "check 23.85 is in the fixture already" }

SubRx @'
  {v:'23.84',what:
'@ @'
  {v:'23.85',what:'his #50 (UI redesign ui3): the menu type scale: window titles in the condensed family, and in Settings, the pause box and the title no text tracked past .145em or set under 13px',
   run:function(){
     var bad=[], T=document.getElementById('title'), titleWas=null, g=null, P0=document.getElementById('pausebox'), h3, f, n=0;
     function scan(root,tag){
       if(!root){ bad.push('no '+tag); return; }
       var all=[root].concat([].slice.call(root.querySelectorAll('*'))), worst=[];
       all.forEach(function(el){
         var has=false, c, s, fs, ls;
         for(c=el.firstChild;c;c=c.nextSibling) if(c.nodeType===3&&c.nodeValue.trim()){ has=true; break; }
         if(!has||!el.getClientRects().length) return;
         s=getComputedStyle(el); if(s.visibility==='hidden'||s.display==='none') return;
         fs=parseFloat(s.fontSize); ls=parseFloat(s.letterSpacing)||0; n++;
         if(ls/fs>0.145||fs<12.9) worst.push((el.id?'#'+el.id:el.tagName.toLowerCase())+' "'+el.textContent.trim().slice(0,18)+'" '+fs+'px tracked '+(ls/fs).toFixed(2)+'em');
       });
       if(worst.length) bad.push(tag+': '+worst.slice(0,4).join(', ')+(worst.length>4?' and '+(worst.length-4)+' more':''));
     }
     try{
       __topClear();
       if(typeof __hubEnter==='function') __hubEnter();
       var r=__station('dev','KeyE'); if(r&&r.err) return 'SKIP: no settings station ('+r.err+')';
       h3=document.querySelector('#settingsmodal h3');
       if(!h3) bad.push('Settings has no title');
       else { f=getComputedStyle(h3).fontFamily||''; if(!(/^"?Barlow Condensed/).test(f)) bad.push('the Settings title is set in '+f.slice(0,40)+', not Barlow Condensed'); }
       scan(document.getElementById('settingsmodal'),'Settings');
       __topClear();
       if(T){ titleWas=T.classList.contains('on'); T.classList.add('on'); scan(T,'the title'); if(!titleWas) T.classList.remove('on'); titleWas=null; }
       else bad.push('no title screen');
       if(window.__deploy&&typeof togglePauseBox==='function'&&P0){
         __topClear(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
         if(g&&!g.over){ togglePauseBox(true); scan(P0,'the pause box'); togglePauseBox(false); }
       }
       if(n<40) bad.push('only '+n+' text elements were measured');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(T&&titleWas===false) T.classList.remove('on'); }catch(_t){}
       try{ if(typeof togglePauseBox==='function') togglePauseBox(false); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
