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

if ($s.Contains("  {v:'32.92',what:")) { throw "check 32.92 is in the fixture already" }

SubRx @'
  {v:'32.91',what:
'@ @'
  {v:'32.92',what:'daily save copies keep three dates per slot, leave the main bytes alone, exclude demo and second windows, survive quota errors, and restore with undo from Settings',
   run:function(){
     if(typeof dailySaveCopy!=='function') return 'automatic daily save backup is missing';
     var desc=Object.getOwnPropertyDescriptor(window,'localStorage'), data={}, writes=[], removed=[], fail=null,
         pp=P,sk=SKEY,sl=SLOT,bk=RESTORE_BACKUP_KEY,p2=NETP2,ns=NETSLOT,ao=ARCADE.on,ss=SAVE_STALE,ws=window.storage,
         oGet=storeGet,oApply=applyLoadedProfile,oBytes=dailySaveBytes,oReport=DAILY_SAVE_REPORT,oTimer=window.setTimeout,
         oldG=G,oldSpec=NET.specG,oldReload=RESTORE_RELOAD,oldTimer=RESTORE_TIMER,bad=[],i,raw,day,n,source,btn,loaded=0;
     var fake={getItem:function(k){return Object.prototype.hasOwnProperty.call(data,k)?data[k]:null;},
       setItem:function(k,v){writes.push(k);if(fail&&fail(k)){var e=new Error('full');e.name='QuotaExceededError';throw e;}data[k]=String(v);},
       removeItem:function(k){removed.push(k);delete data[k];},key:function(i){return Object.keys(data)[i]||null;}};
     Object.defineProperty(fake,'length',{get:function(){return Object.keys(data).length;}});
     function same(n,msg){if(writes.length!==n)bad.push(msg+' ('+writes.length+' writes)');}
     function tick(date){return dailySaveCopy({key:SKEY,value:data[SKEY]},new Date(2026,9,date,12));}
     function thenNow(v){return {then:function(fn){return thenNow(fn(v));},catch:function(){return this;}};}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       Object.defineProperty(window,'localStorage',{configurable:true,value:fake});
       window.storage=null;NETP2=false;NETSLOT='';ARCADE.on=0;SAVE_STALE=false;SLOT='1';SKEY='salvagerun:profile';RESTORE_BACKUP_KEY=SKEY+':prerestore';
       P=JSON.parse(JSON.stringify(P));P.credits=901;P.runs=120;raw=JSON.stringify(P);data[SKEY]=raw;
       if(!tick(20))bad.push('first daily copy missing');same(1,'new day must write exactly one side key');
       if(data[SKEY+':daily:2026-10-20']!==raw)bad.push('copy changed stored bytes');
       tick(20);same(1,'second load the same day wrote again');
       for(i=21;i<=23;i++)tick(i);
       if(dailySaveKeys(false).length!==3||data[SKEY+':daily:2026-10-20']!==undefined)bad.push('fourth day did not drop the oldest');
       if(data[SKEY]!==raw)bad.push('main profile bytes changed during backup');
       n=writes.length;NETP2=true;tick(24);NETP2=false;NETSLOT='A';tick(24);NETSLOT='';ARCADE.on=1;tick(24);ARCADE.on=0;
       SKEY=netP2Key();data[SKEY]=raw;tick(24);SKEY='salvagerun:profile';same(n,'demo, netslot or player 2 wrote a copy');
       SKEY='salvagerun:profile:2';data[SKEY]=raw;tick(20);
       if(dailySaveKeys(false).length!==1||fake.getItem('salvagerun:profile:daily:2026-10-21')!==raw)bad.push('slot copies are not independent');
       SKEY='salvagerun:profile';
       // v28.xx (cw-cx-dailysave): the real loadProfile entry takes the raw copy before its migration callback.
       dailySaveClear(false);writes=[];storeGet=function(){return thenNow({key:SKEY,value:data[SKEY]});};
       applyLoadedProfile=function(r){loaded++;if(dailySaveKeys(false).length!==1)bad.push('load migrated before its raw daily copy');};
       loadProfile();same(1,'first actual profile load');loadProfile();same(1,'second actual profile load');
       if(loaded!==2)bad.push('normal load callback was lost');applyLoadedProfile=oApply;
       // v28.xx (cw-cx-dailysave): quota errors evict the oldest, retry once, then skip without touching the main value.
       dailySaveClear(false);tick(20);tick(21);writes=[];n=0;
       fail=function(k){return k===SKEY+':daily:2026-10-22'&&++n===1;};
       if(!tick(22)||n!==2||data[SKEY+':daily:2026-10-20']!==undefined)bad.push('quota did not evict oldest and retry once');
       fail=function(k){return k===SKEY+':daily:2026-10-23';};writes=[];
       if(tick(23)||writes.length!==2||DAILY_SAVE_REPORT.state.indexOf('skipped:')!==0)bad.push('persistent quota did not quietly skip after one retry');
       if(data[SKEY]!==raw)bad.push('quota path touched main profile');fail=null;
       if(buildExport().indexOf('daily save backup: skipped:')<0)bad.push('run report omits skipped backup');
       dailySaveBytes=function(){return 5*1024*1024;};writes=[];tick(24);same(0,'size guard attempted an oversized copy');dailySaveBytes=oBytes;
       // v28.xx (cw-cx-dailysave): normal main saves reclaim backup storage on a setItem quota exception.
       tick(20);n=0;fail=function(k){return k===SKEY&&++n===1;};storeSet(raw);
       if(n!==2||dailySaveKeys(true).length||data[SKEY]!==raw)bad.push('main save did not reclaim daily copies and retry');fail=null;
       // v28.xx (cw-cx-dailysave): press the restore controls using the normal profile loader and migrations.
       P=JSON.parse(raw);G=null;NET.specG=null;window.setTimeout=function(){return 0;};
       day=new Date();day.setDate(day.getDate()-1);dailySaveCopy({value:raw},day);
       day.setDate(day.getDate()-1);dailySaveCopy({value:raw},day);
       P.credits=12345;P.runs=121;data[SKEY]=JSON.stringify(P);renderSettings();
       source=document.getElementById('set_restore_source');btn=document.getElementById('set_restore');
       if(!source||!btn)bad.push('Settings restore source control missing');
       else{
         source.onclick();if(source.textContent!=='yesterday'||btn.textContent!=='restore')bad.push('yesterday missing from existing restore row');
         source.onclick();if(source.textContent!=='2 days ago')bad.push('2 days ago missing');
         source.onclick();if(source.textContent!=='file'||btn.textContent!=='pick file')bad.push('file restore choice lost');source.onclick();
         btn.onclick();
         if(P.credits!==901||JSON.parse(data[SKEY]).credits!==901||JSON.parse(data[RESTORE_BACKUP_KEY]).credits!==12345||RESTORE_RELOAD!==1)bad.push('daily restore or outgoing undo copy failed');
         btn=document.getElementById('set_unrestore');if(!btn)bad.push('daily restore offered no undo');
         else{btn.onclick();if(JSON.parse(data[SKEY]).credits!==12345||JSON.parse(data[RESTORE_BACKUP_KEY]).credits!==901)bad.push('daily restore could not be undone');}
       }
       return bad.length?bad.join('; '):null;
     }catch(e){return 'threw: '+(e&&e.stack||e);}
     finally{
       Object.defineProperty(window,'localStorage',desc);window.storage=ws;storeGet=oGet;applyLoadedProfile=oApply;dailySaveBytes=oBytes;window.setTimeout=oTimer;
       P=pp;SKEY=sk;SLOT=sl;RESTORE_BACKUP_KEY=bk;NETP2=p2;NETSLOT=ns;ARCADE.on=ao;SAVE_STALE=ss;DAILY_SAVE_REPORT=oReport;
       G=oldG;NET.specG=oldSpec;RESTORE_RELOAD=oldReload;RESTORE_TIMER=oldTimer;
       try{__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'32.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
