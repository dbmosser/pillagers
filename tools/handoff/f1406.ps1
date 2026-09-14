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

SubRx @'
  {v:'14.05',what:
'@ @'
  {v:'14.06',what:'a restore code keeps the character it replaces for UNDO: pasting a code through the real READ and REPLACE buttons leaves the replaced character in the UNDO backup, while the code itself is applied (saving, profile and settings audit 2026-09-15, finding 2)',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot load a profile';
     if(typeof restoreMake!=='function'||!document.getElementById('resread')||!document.getElementById('resgo')||!document.getElementById('rescode')||!document.getElementById('resword')) return 'SKIP: no restore code panel in this page';
     var bad=[], keep=JSON.parse(JSON.stringify(__P()));
     var BK=(typeof RESTORE_BACKUP_KEY!=='undefined')?RESTORE_BACKUP_KEY:(SKEY+':prerestore');
     var keepBk=null; try{ keepBk=localStorage.getItem(BK); }catch(_k){}
     function el(id){ return document.getElementById(id); }
     try{
       __topClear(); __cleanProfile();
       try{ localStorage.removeItem(BK); }catch(_r){}
       var P2=__P();
       P2.pname='PROBESOURCE'; P2.credits=4242;
       var code=restoreMake();
       if(typeof code!=='string'||!code) return 'SKIP: restoreMake made no code';
       P2.pname='BEFORECODE'; P2.credits=1717;
       el('rescode').value=code; el('resread').click();
       el('resword').value='restore'; el('resgo').click();
       try{ clearTimeout(RESTORE_TIMER); RESTORE_RELOAD=0; }catch(_t){}
       // CONTROL: the code was applied.
       if(__P().pname!=='PROBESOURCE') return 'SKIP: the code was not applied through the panel, so nothing here can be measured';
       var d=null; try{ d=JSON.parse(localStorage.getItem(BK)||'null'); }catch(_j){}
       if(!(d&&d.pname==='BEFORECODE')) bad.push('pasting a restore code kept no backup of the character it replaced, so UNDO cannot bring it back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearTimeout(RESTORE_TIMER); RESTORE_RELOAD=0; }catch(_t2){}
       try{ if(keepBk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,keepBk); }catch(_b){}
       try{ var rc=el('rescode'); if(rc) rc.value=''; }catch(_v){}
       try{ __applyLoaded(keep); saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
