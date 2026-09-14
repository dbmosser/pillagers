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
  {v:'14.53',what:
'@ @'
  {v:'14.54',what:'a note is at most 400 characters: a 2,000 character pause box note banked in a raid, and a 2,000 character outcome note put on a run already logged, are each stored at 400 (report audit finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function') return 'SKIP: no pause box in this build';
     var bad=[], g0=null, LONG=new Array(201).join('zqxnote12'), _sp=saveProfile, _ae=(typeof autoExport==='function')?autoExport:null;
     var pn=document.getElementById('pausenote'), on=document.getElementById('oc_note');
     try{
       saveProfile=function(){}; if(_ae) autoExport=function(){};
       // ARM 1: the pause box note in a raid.
       if(pn){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var g=__state(); g0=g;
         if(g&&g.tel){
           var before=(g.tel.notes||[]).length;
           pn.value=LONG; togglePauseBox(true); togglePauseBox(false);
           var got=(g.tel.notes||[])[before];
           if(!got) bad.push('control: closing the pause box did not bank the note');
           else if(String(got.txt).length>400) bad.push('a pause box note was banked at '+String(got.txt).length+' characters');
         }
       }
       // ARM 2: an outcome note put on a run already logged.
       if(on&&typeof ocCommit==='function'&&typeof committedRun!=='undefined'&&typeof pendingRun!=='undefined'&&pendingRun===null){
         var keepCR=committedRun, fake={tags:[],note:''};
         try{
           committedRun=fake; on.value=LONG;
           ocCommit();
           if(fake.note===''&&!(fake.tags&&fake.tags.length)) bad.push('control: the outcome note did not reach the logged run');
           else if(String(fake.note).length>400) bad.push('an outcome note was stored on the run at '+String(fake.note).length+' characters');
         } finally { committedRun=keepCR; on.value=''; }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp; if(_ae) autoExport=_ae;
       try{ if(pn) pn.value=''; }catch(_p){}
       try{ if(g0&&!g0.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
