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

if ($s.Contains("  {v:'28.06',what:")) { throw "check 28.06 is in the fixture already" }

SubRx @'
  {v:'28.05',what:
'@ @'
  {v:'28.06',what:'his 2026-10-14 note (UI cleanup uic1): the abandon confirm is a two button question: armed, the pause box shows YES, ABANDON and NO, KEEP PLAYING and nothing else, and every button stays inside the box frame (it ran about 110 px out of the frame on both sides)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof disarmAbandon!=='function') return 'SKIP: no pause box in this build';
     var ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon'), pb=document.getElementById('pausebox');
     if(!ab||!cb||!pb||typeof ab.onclick!=='function') return 'SKIP: no abandon button or confirm in this build';
     var bad=[], g=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'SKIP: the pause box did not open here';
       ab.onclick.call(ab);
       if(cb.style.display==='none') return 'SKIP: the press did not arm the confirm here';
       var fr=pb.getBoundingClientRect(), bs=pb.querySelectorAll('button'), i, r, shown=[];
       for(i=0;i<bs.length;i++){
         if(!bs[i].getClientRects().length) continue;
         r=bs[i].getBoundingClientRect(); if(r.width<2||r.height<2) continue;
         shown.push(bs[i].id||bs[i].textContent);
         if(r.left<fr.left-1||r.right>fr.right+1) bad.push((bs[i].id||bs[i].textContent)+' is '+Math.round(Math.max(fr.left-r.left,r.right-fr.right))+'px outside the box frame');
       }
       if(shown.length!==2||shown.indexOf('confirmabandon')<0||shown.indexOf('abandonbtn')<0) bad.push('armed, the box shows '+shown.join(', ')+' and not just YES and NO');
       disarmAbandon();
       var back=0; for(i=0;i<bs.length;i++) if(bs[i].id==='resumebtn'&&bs[i].getClientRects().length) back=1;
       if(!back) bad.push('disarming did not bring RESUME RUN back');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ disarmAbandon(); }catch(_d){}
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_t){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'28.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
