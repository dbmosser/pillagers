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
  {v:'14.42',what:
'@ @'
  {v:'14.43',what:'a save the game cannot read is not quietly replaced: unreadable data given to the loader is copied aside under its own key, and a save holding unreadable data is listed on the title instead of read as empty (title and saves audit finding 3)',
   run:function(){
     if(typeof applyLoadedProfile!=='function'||typeof SKEY==='undefined') return 'SKIP: no profile loader in this build';
     var bad=[], RAW='{zqx this is not a save', UK=SKEY+':unreadable', K8='salvagerun:profile:8', had8=null;
     try{
       __topClear();
       try{ had8=localStorage.getItem(K8); }catch(_h){}
       if(had8!==null) return 'SKIP: save 8 already holds data in this browser';
       try{ localStorage.removeItem(UK); }catch(_u){}
       // THE FIX, the loader: unreadable data is kept before boot can save over it.
       try{ applyLoadedProfile({value:RAW}); }catch(_le){}
       var kept=null; try{ kept=localStorage.getItem(UK); }catch(_g){}
       if(kept!==RAW) bad.push('the loader ignored unreadable save data without keeping a copy, so boot saves a fresh character over it');
       // AND the title: a save holding unreadable data is not listed as empty.
       if(typeof titleRefresh==='function'&&document.getElementById('slotlist')){
         localStorage.setItem(K8,RAW);
         titleRefresh();
         if(!document.querySelector('#slotlist [data-slot="8"]')) bad.push('save 8 holds unreadable data and the title does not list it, so CREATE A NEW SAVE treats it as empty and writes over it');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ localStorage.removeItem(UK); if(had8===null) localStorage.removeItem(K8); if(typeof titleRefresh==='function') titleRefresh(); }catch(_c){}
       try{ __topClear(); __cleanProfile(); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
