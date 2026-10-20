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

if ($s.Contains("  {v:'32.98',what:")) { throw "check 32.98 is in the fixture already" }

SubRx @'
  {v:'32.97',what:
'@ @'
  {v:'32.98',what:'server co-op and its coming later tag are hidden on the host title; arrows and pad skip the retained row (his 2.R6 b)',
   run:function(){
     var title=document.getElementById('title'), srv=document.getElementById('modecoopsrv'), wrap=srv&&srv.parentNode, tag=wrap&&wrap.querySelector('span');
     if(!title||!srv||!tag) return 'server row or tag missing: retain the wired elements';
     if(typeof netTitleRows!=='function'||typeof netTitleMove!=='function'||typeof padFocusables!=='function'||typeof padStep!=='function') return 'no title navigation';
     var cls=title.className, style=title.style.cssText, focus=PAD.focus, bad=[], rows, list, cur, next, i, dir, seen={}, beforeX=window.scrollX, beforeY=window.scrollY;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(typeof NETP2!=='undefined'&&NETP2) return 'stage this check in the host window';
       title.classList.add('on'); title.style.display='';
       if(!document.getElementById('titlestart').getClientRects().length) return 'host title staging is not visible';
       if(getComputedStyle(wrap).display!=='none') bad.push('server row wrapper is still shown on the host');
       if(srv.getClientRects().length||tag.getClientRects().length) bad.push('server co-op button or coming later tag is visible');
       rows=netTitleRows();
       if(rows.indexOf(srv)>=0) bad.push('server row is in the arrow list');
       var expected=['titlestart','modecoop','modearcade','modearcade1'];
       for(i=0;i<expected.length;i++) if(!rows.some(function(el){return el.id===expected[i];})) bad.push('playable mode missing: '+expected[i]);
       for(dir=-1;dir<=1;dir+=2){
         padSetFocus(document.getElementById('titlestart'));
         for(i=0;i<rows.length+1;i++){
           if(!netTitleMove(dir)) bad.push('title arrow did not move');
           if(PAD.focus===srv) bad.push('title arrow landed on server co-op');
           if(PAD.focus) seen[PAD.focus.id]=true;
         }
       }
       for(i=0;i<expected.length;i++) if(!seen[expected[i]]) bad.push('arrows never reached '+expected[i]);
       list=padFocusables(title);
       if(list.indexOf(srv)>=0) bad.push('server row is in the pad list');
       cur=document.getElementById('titlestart');
       for(i=0;i<list.length+1;i++){
         next=padStep(list,cur,0,1); if(!next) break;
         if(next===srv) bad.push('pad down landed on server co-op');
         cur=next;
       }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); title.className=cls; title.style.cssText=style;
       padSetFocus(null); PAD.focus=null; if(focus) padSetFocus(focus);
       window.scrollTo(beforeX,beforeY);
     } }},
  {v:'32.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
