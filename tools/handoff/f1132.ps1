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
  {v:'11.31',what:'the stash on a fresh profile draws the one owned gun under ALL and does not say the stash is empty under it; with no guns and nothing stashed it does say so',
'@ @'
  {v:'11.32',what:'Copy report reports a refused clipboard as a failure that names the Recorder, and reports success only when a copy command actually succeeded',
   run:function(){
     if(!(window.__deploy&&window.__endRaid)) return 'SKIP: this fixture cannot end a raid';
     var btn=document.getElementById('oc_copy');
     if(!btn) return 'SKIP: no Copy report button in this document';
     // Force the SYNCHRONOUS fallback path by hiding navigator.clipboard, so
     // the button text can be read right after the click without awaiting a
     // microtask. If clipboard cannot be redefined here, the check cannot run.
     var desc; try{ desc=Object.getOwnPropertyDescriptor(navigator,'clipboard'); }catch(_d){ desc=null; }
     var redefined=false;
     try{ Object.defineProperty(navigator,'clipboard',{value:undefined,configurable:true}); redefined=(navigator.clipboard===undefined); }catch(_e){ redefined=false; }
     if(!redefined) return 'SKIP: navigator.clipboard cannot be hidden here, so the synchronous fallback cannot be forced';
     var bad=[], origExec=document.execCommand, copiedWord=['Copi','ed.'].join(''), couldNot=['Could not ','copy'].join('');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); __endRaid('extract');
       // ARM ONE: the copy command fails. The button must NOT say Copied.
       document.execCommand=function(){ return false; };
       btn.click();
       var t1=btn.textContent||'';
       if(t1.indexOf(copiedWord)>=0) bad.push('with the copy command failing the button said "'+t1+'"');
       if(t1.indexOf(couldNot)<0) bad.push('with the copy command failing the button did not say it could not copy: "'+t1+'"');
       // ARM TWO: the copy command succeeds. The button MAY say Copied.
       document.execCommand=function(){ return true; };
       btn.click();
       var t2=btn.textContent||'';
       if(t2.indexOf(copiedWord)<0) bad.push('control: with the copy command succeeding the button did not say Copied: "'+t2+'"');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       document.execCommand=origExec;
       try{ if(desc) Object.defineProperty(navigator,'clipboard',desc); }catch(_r){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.31',what:'the stash on a fresh profile draws the one owned gun under ALL and does not say the stash is empty under it; with no guns and nothing stashed it does say so',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
