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

# v11.63 CHECK, inserted before the v11.62 entry.
SubRx @'
  {v:'11.62',what:'reviving a pillager you downed clears the kill attribution on him, so a later death at other hands is not credited to you; the revive itself still stands him up friendly',
'@ @'
  {v:'11.63',what:'a tag and a note chosen after Copy report reach the run that Copy already logged when Log run and return is pressed afterwards, and the run is not logged twice',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&document.getElementById('tagwrap')&&document.getElementById('oc_copy')&&document.getElementById('oc_btn'))) return 'SKIP: this fixture cannot end a raid and press the card';
     // Force the SYNCHRONOUS copy path, as check 11.32 does, so Copy report has
     // committed by the time click() returns.
     var desc; try{ desc=Object.getOwnPropertyDescriptor(navigator,'clipboard'); }catch(_d){ desc=null; }
     var redefined=false;
     try{ Object.defineProperty(navigator,'clipboard',{value:undefined,configurable:true}); redefined=(navigator.clipboard===undefined); }catch(_e){ redefined=false; }
     if(!redefined) return 'SKIP: navigator.clipboard cannot be hidden here, so Copy report cannot be pressed synchronously';
     var bad=[], origExec=document.execCommand, prof, keepAE, lateNote='ZQX late note 4471';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       prof=__P(); keepAE=prof.autoExport; prof.autoExport=false;   // a check must not start a download
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0;
       __endRaid('extract');
       document.execCommand=function(){ return true; };
       var n0=(prof.log||[]).length;
       document.getElementById('oc_copy').click();   // logs the run, with no tags yet
       var log=prof.log||[], rec=log[log.length-1];
       if(log.length!==n0+1||!rec) bad.push('control: Copy report did not log the run ('+(log.length-n0)+' rows added)');
       else {
         if((rec.tags||[]).length) bad.push('control: the row Copy wrote already carries tags '+rec.tags.join(', ')+', so a late tag proves nothing');
         var cells=document.getElementById('tagwrap').querySelectorAll('.tag');
         if(cells.length<2) bad.push('control: the card drew '+cells.length+' tag buttons');
         else {
           var lateTag=String(cells[1].textContent);
           cells[1].click();                                   // chosen AFTER Copy report
           document.getElementById('oc_note').value=lateNote;  // typed AFTER Copy report
           document.getElementById('oc_btn').click();          // Log run and return
           var log2=prof.log||[], rec2=log2[log2.length-1];
           if(log2.length!==n0+1) bad.push('control: Log run and return added '+(log2.length-n0-1)+' extra row(s), so the run was logged twice');
           var got=(rec2&&rec2.tags||[]).map(function(x){ return String(x).toUpperCase(); }).join(' | ');
           if(got.indexOf(lateTag.toUpperCase())<0) bad.push('the tag '+lateTag+' chosen after Copy report did not reach the run (tags: '+(got||'none')+')');
           if(((rec2&&rec2.note)||'')!==lateNote) bad.push('the note typed after Copy report did not reach the run (note: "'+((rec2&&rec2.note)||'')+'")');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       document.execCommand=origExec;
       try{ if(desc) Object.defineProperty(navigator,'clipboard',desc); }catch(_r){}
       try{ if(prof) prof.autoExport=keepAE; }catch(_a){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.62',what:'reviving a pillager you downed clears the kill attribution on him, so a later death at other hands is not credited to you; the revive itself still stands him up friendly',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
