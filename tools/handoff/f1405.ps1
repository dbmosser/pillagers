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
  {v:'14.04',what:
'@ @'
  {v:'14.05',what:'the crash catcher stops saving every frame and keeps older crashes: two errors alternating twenty times save the profile at most three times and leave an older, different crash on the list, while a genuinely new error is still saved (saving, profile and settings audit 2026-09-15, finding 4)',
   run:function(){
     if(!window.__P||typeof noteCrash!=='function'||typeof saveProfile!=='function') return 'SKIP: no crash catcher in this build';
     if(typeof PLOADED!=='undefined'&&!PLOADED) return 'SKIP: the profile is not loaded, so the catcher writes to its boot key';
     var bad=[], P2=__P(), keepCr=JSON.stringify(P2.crashes||[]), realSave=saveProfile, saves=0;
     try{
       P2.crashes=[{v:VER,t:Date.now()-1000,kind:'error',msg:'PROBE OLD CRASH',n:1}];
       try{ noteCrash.savedAt=0; }catch(_s0){}
       saveProfile=function(){ saves++; };
       // THE FINDING: two errors taking turns, twenty times.
       for(var i=0;i<20;i++){ noteCrash('error','PROBE ERROR A',''); noteCrash('error','PROBE ERROR B',''); }
       var old=false; for(var j=0;j<P2.crashes.length;j++) if(P2.crashes[j]&&P2.crashes[j].msg==='PROBE OLD CRASH') old=true;
       if(saves>3) bad.push('two errors alternating twenty times saved the whole profile '+saves+' times');
       if(!old) bad.push('two alternating errors pushed the older, different crash off the list');
       // CONTROL: a genuinely new error is still saved.
       var before=saves;
       try{ noteCrash.savedAt=0; }catch(_s1){}
       noteCrash('error','PROBE ERROR C','');
       if(!(saves>before)) bad.push('control: a new error was not saved, so the fix went too far');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ saveProfile=realSave; }catch(_r){}
       try{ P2.crashes=JSON.parse(keepCr); saveProfile(); }catch(_k){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
