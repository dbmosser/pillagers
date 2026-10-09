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

if ($s.Contains("  {v:'20.69',what:")) { throw "check 20.69 is in the fixture already" }

SubRx @'
  {v:'20.68',what:
'@ @'
  {v:'20.69',what:'ESC or TAB in the stash search box clears the words first and then closes the stash, and with the box empty the first press closes it',
   run:function(){
     var hub=document.getElementById('hub'), bad=[], sq=null, oq=(typeof STASH_Q==='string')?STASH_Q:'', hubWas, pb;
     if(!hub||typeof renderHub!=='function'||typeof backOut!=='function'||typeof stashFilterApply!=='function') return 'SKIP: no stash screen here';
     if(document.querySelector('.modal.on')) return 'SKIP: a window is open over the page';
     pb=document.getElementById('pausebox'); if(pb&&pb.classList.contains('on')) return 'SKIP: the pause box is up';
     hubWas=hub.classList.contains('on');
     function key(el,c){ var e=new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true}); el.dispatchEvent(e); return e; }
     function open(){ renderHub(); hub.classList.add('on'); var s=document.getElementById('stashsearch'); if(s){ try{ s.focus(); }catch(_f){} } return s; }
     try{
       __topClear(); __cleanProfile();
       sq=open(); if(!sq) return 'SKIP: no stash search box';
       sq.value='zqxh31'; STASH_Q='zqxh31'; stashFilterApply();
       key(sq,'Escape');
       if(sq.value!==''||STASH_Q!=='') bad.push('ESC did not clear the search words');
       if(!hub.classList.contains('on')) bad.push('ESC with words in the box closed the stash before clearing them');
       else { key(sq,'Escape'); if(hub.classList.contains('on')) bad.push('a second ESC, with the words cleared, left the stash open'); }
       sq=open(); if(!sq) return 'SKIP: the search box did not come back';
       sq.value=''; STASH_Q='';
       key(sq,'Escape');
       if(hub.classList.contains('on')) bad.push('ESC in an empty search box left the stash open');
       sq=open(); if(!sq) return 'SKIP: the search box did not come back';
       sq.value=''; STASH_Q='';
       key(sq,'Tab');
       if(hub.classList.contains('on')) bad.push('TAB in an empty search box left the stash open');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var s2=document.getElementById('stashsearch'); if(s2) s2.blur(); }catch(_b){}
       try{ STASH_Q=oq; stashFilterApply(); }catch(_q){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
