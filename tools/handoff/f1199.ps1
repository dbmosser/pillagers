$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.99 CHECK, inserted before the v11.98 entry. The pane is put at 4K, the
# item menu is opened on a stash Bandage through the real opener, and its
# zoom must equal the windows' zoom with the menu wholly on screen.
SubRx @'
  {v:'11.98',what:'a boarding hold that began before the window shut still extracts while E is held, and the ship can be called from the edge of the ring (his orders of 2026-09-06)',
'@ @'
  {v:'11.99',what:'the stash right-click menu takes the menu zoom like every window, so at 4K it is not a 1080p-sized menu under a 4K stash (his note of 2026-09-06)',
   run:function(){
     if(!(window.__forceSize&&window.__hubEnter&&window.__showScreen&&window.__P)) return 'SKIP: this fixture cannot resize';
     if(typeof openItemMenu!=='function'||typeof closeItemMenu!=='function'||typeof titleRes!=='function') return 'SKIP: no item menu in this build';
     var bad=[], P2=__P(), keepStash=(P2.stash||[]).slice(), keepKit=(P2.kit||[]).slice();
     try{
       __topClear(); __runPrep(); __cleanProfile();
       G=null; __showScreen('hub'); __hubEnter();
       __forceSize(3840,2160);
       if(!(W>=3000)) return 'SKIP: the pane would not go to 4K ('+W+'x'+H+')';
       P2.stash=['bandage']; saveProfile();
       openItemMenu(400,400,'bandage','stash',1);
       var m=document.querySelector('.imenu');
       if(!m) bad.push('control: no menu opened');
       else {
         var hubEl=document.getElementById('hub');
         var want=(hubEl&&hubEl.classList.contains('on')&&parseFloat(hubEl.style.zoom)>0)?parseFloat(hubEl.style.zoom):Math.max(1,(P2.menuZoom||1))*titleRes();
         var z=parseFloat(m.style.zoom||'1')||1;
         if(Math.abs(z-want)>0.05) bad.push('the menu zoom is '+z+' where the windows are at '+want.toFixed(2));
         var r=m.getBoundingClientRect();
         if(r.width<186*want*0.9) bad.push('the menu is only '+Math.round(r.width)+' px wide at 4K');
         if(window.innerWidth>=1200&&(r.left<0||r.top<0||r.right>window.innerWidth+1||r.bottom>window.innerHeight+1)) bad.push('the menu is off the viewport at '+Math.round(r.left)+','+Math.round(r.top)+' to '+Math.round(r.right)+','+Math.round(r.bottom));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ closeItemMenu(); }catch(_c){} P2.stash=keepStash; P2.kit=keepKit; try{ saveProfile(); }catch(_s){} try{ __forceSize(1920,1080); }catch(_f){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.98',what:'a boarding hold that began before the window shut still extracts while E is held, and the ship can be called from the edge of the ring (his orders of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
