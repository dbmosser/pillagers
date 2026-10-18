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

if ($s.Contains("  {v:'29.62',what:")) { throw "check 29.62 is in the fixture already" }

SubRx @'
  {v:'29.61',what:
'@ @'
  {v:'29.62',what:'the pause card, the end card, Settings and Keys are on the UI motion layer: each opens from clear (50 percent near 50 ms, 99 by 200), shuts within 150 ms, and the open and close sounds play for all but the end card',
   run:function(){
     if(typeof UIM!=='object'||!UIM||typeof UIM.step!=='function') return 'no motion layer (no UIM)';
     var ids=['pausebox','outcome','settingsmodal','keysmodal'], bad=[], was={}, snd=[], os=sndUi, m, i, id, op;
     function near(v,w,tol,lab){ if(!(Math.abs(v-w)<=tol)) bad.push(lab+' was '+(+v).toFixed(3)+', want '+w); }
     try{
       __topClear(); __runPrep();
       UIM.manual=true;
       sndUi=function(k){ snd.push(k); return true; };
       for(i=0;i<ids.length;i++){
         id=ids[i]; m=document.getElementById(id);
         if(!m){ if(id!=='keysmodal') bad.push('no '+id); continue; }   // the Keys window is built on first use
         if(!UIM.inScope(m)){ bad.push(id+' is not on the motion layer'); continue; }
         was[id]=m.classList.contains('on');
         m.classList.remove('on'); UIM.chg(m); UIM.clearAll(); snd.length=0;
         m.classList.add('on'); UIM.chg(m);
         op=function(){ return parseFloat(getComputedStyle(m).opacity); };
         near(op(),0,0.02,id+' opacity at 0 ms');
         UIM.step(50); near(op(),0.50,0.1,id+' opacity at 50 ms');
         UIM.step(150); near(op(),0.99,0.08,id+' opacity at 200 ms');
         UIM.step(400);
         if(m.__uim||m.style.opacity!=='') bad.push(id+' keeps its open values after 600 ms');
         if(id==='outcome'){ if(snd.indexOf('open')>=0) bad.push('the end card plays the open sweep'); }
         else if(snd.indexOf('open')<0) bad.push(id+' opens with no sound');
         snd.length=0;
         m.classList.remove('on'); UIM.chg(m);
         if(getComputedStyle(m).display==='none') bad.push(id+' is cut off at once on a close');
         UIM.step(70); near(op(),0.75,0.12,id+' opacity 70 ms into a close');
         UIM.step(80);
         if(getComputedStyle(m).display!=='none') bad.push(id+' still shows 150 ms after a close');
         if(id==='outcome'){ if(snd.indexOf('close')>=0) bad.push('the end card plays the close sweep'); }
         else if(snd.indexOf('close')<0) bad.push(id+' closes with no sound');
       }
       keysOpen(false); m=document.getElementById('keysmodal');
       if(!m||typeof m.__uimOn!=='boolean') bad.push('the Keys window is built but not on the motion layer');
       else { m.classList.remove('on'); UIM.clearAll(); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ sndUi=os; UIM.manual=false; UIM.clearAll(); ids.forEach(function(k){ var e=document.getElementById(k); if(!e) return; e.classList.remove('on'); e.__uimOn=false; if(was[k]){ e.classList.add('on'); e.__uimOn=true; } }); UIM.clearAll(); }catch(_f){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
