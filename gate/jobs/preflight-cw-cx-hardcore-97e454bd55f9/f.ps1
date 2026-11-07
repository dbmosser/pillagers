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

if ($s.Contains("  {v:'37.49',what:")) { throw "check 37.49 is in the fixture already" }

SubRx @'
  {v:'37.48',what:
'@ @'
  {v:'37.49',what:'optional hardcore careers archive on death and remove only their own save and backups',run:function(){
    if(typeof hcFinish!=='function'||!document.getElementById('hctoggle'))return 'no hardcore creation or graveyard';
    var pp=JSON.parse(JSON.stringify(P)),sl=SLOT,sk=SKEY,ss=SAVE_STALE,hr=HC_REMOVED,ws=window.storage,nr=careerNewReload,sp=saveCopyPut,sq=saveCopyQueue,sd=saveCopyDel,np=NETP2,ns=NETSLOT,sm=NET.same,ao=ARCADE.on,st=state,raw={},base,bad=[],pin=document.getElementById('pnamein'),pv=pin.value,pt=pin.__typed,toggle=document.getElementById('hctoggle'),removed=[];
    function snap(){for(var i=0;i<localStorage.length;i++){var k=localStorage.key(i);if(k.indexOf('salvagerun:')===0)raw[k]=localStorage.getItem(k);}}
    function seed(){P=JSON.parse(base);P.runs=0;P.hardcore=0;P.autoExport=false;P.autoDownload=false;P.shareRuns=false;delete P.hcDeath;delete P.hcBorn;HC_REMOVED=false;}
    function boot(hc){
      SLOT='1';SKEY='salvagerun:profile';seed();
      for(var i=1;i<=8;i++){var k=slotKeyOf(String(i));if(i<=4)localStorage.setItem(k,JSON.stringify(P));else localStorage.removeItem(k);}
      toggle.setAttribute('aria-checked',hc?'false':'true');toggle.onclick();pin.value='grimtest';pin.__typed=1;
      document.getElementById('newgame').onclick();
      if(localStorage.getItem(slotPtrKey())!=='5')bad.push('create missed first free slot 5');
      SLOT='5';SKEY=slotKeyOf(SLOT);seed();hcTake();newNameTake();
      if((P.hardcore===1)!==hc||P.pname!=='grimtest')bad.push('boot lost hardcore choice or name');
      if(toggle.getAttribute('aria-checked')!=='false')bad.push('choice did not reset');
    }
    function raid(how,hc){
      SLOT='5';SKEY=slotKeyOf(SLOT);seed();P.hardcore=hc?1:0;P.hcBorn=Date.now()-172800000;P.pname='grimtest';P.acctName='grimtest';if(P.pil){P.pil.name='grimtest';P.pil.lvl=7;}
      P.stash=['bandage','bandage','bandage'];P.weapons=['pistol','rifle'];P.credits=5000;P.kills={warden:3};P.runs=8;saveProfile();
      var val=trStash(),before=JSON.stringify(P.stash),day=SKEY+':daily:2026-11-07';localStorage.setItem(day,localStorage.getItem(SKEY));localStorage.setItem(SKEY+':prerestore','undo');localStorage.setItem(SKEY+':precrash','[]');
      __deploy({kit:[],stash:P.stash.slice(),safe:null,mapIx:0,seed:4242});var g=__state();g.career=true;g.sim=false;g.arcade=false;g.tel.distance=12;g.tel.deathKiller='warden';g.tel.kills={warden:2};
      if(hc&&how==='dead'){
        SKEY='salvagerun:profile';if(hcCapture('dead'))bad.push('slot 1 can become hardcore');SKEY=slotKeyOf('5');
        g.sim=true;if(hcCapture('dead'))bad.push('simulation can kill a hardcore save');g.sim=false;
        g.arcade=true;if(hcCapture('dead'))bad.push('demo can kill a hardcore save');g.arcade=false;
        NETP2=true;titleRefresh();if(document.getElementById('hcchoice').style.display!=='none'||!hcCapture('dead'))bad.push('player 2 creation or death rule differs');NETP2=false;titleRefresh();
      }
      __endRaid(how);
      if(hc&&how==='dead'&&!document.querySelector('.hcfallen'))bad.push('KIA missing fallen line');
      document.getElementById('oc_btn').onclick();
      if(hc&&how==='dead'){
        if(localStorage.getItem('salvagerun:profile:5')!==null||localStorage.getItem(day)!==null||localStorage.getItem('salvagerun:profile:5:prerestore')!==null||localStorage.getItem('salvagerun:profile:5:precrash')!==null)bad.push('fallen save or backup survived');
        var a=hcGraves();if(a.length!==1||a[0].name!=='grimtest'||a[0].value!==val||a[0].level!==7||a[0].kills!==5)bad.push('grave lost stash value, level or kills');
        if(a.length&&(!hcArchived('salvagerun:profile:5',{hardcore:1,hcBorn:a[0].born})||hcArchived('salvagerun:profile',{hardcore:1,hcBorn:a[0].born})))bad.push('copy restore guard or slot 1 protection failed');
        if(removed.indexOf('salvagerun:profile:5')<0)bad.push('second copy not removed');
        titleRefresh();if(document.querySelector('#slotlist [data-slot="5"]'))bad.push('fallen save still listed');
        var r=a[0];a.push(Object.assign({},r,{name:'low',value:val-1,at:r.at-100}));a.unshift(Object.assign({},r,{name:'high',value:val+1,at:r.at+100}));localStorage.setItem(HC_KEY,JSON.stringify(a));hcGraveOpen();
        var rows=document.querySelectorAll('.hcgrave-row');if(rows.length!==3||rows[0].getAttribute('data-hc-name')!=='high'||rows[1].getAttribute('data-hc-name')!=='grimtest'||rows[2].getAttribute('data-hc-name')!=='low')bad.push('graveyard not ranked by stash');
        a.push(Object.assign({},r,{name:'earlier',at:r.at-1000}));localStorage.setItem(HC_KEY,JSON.stringify(a));hcGraveOpen();rows=document.querySelectorAll('.hcgrave-row');if(rows.length!==4||rows[1].getAttribute('data-hc-name')!=='earlier'||rows[2].getAttribute('data-hc-name')!=='grimtest')bad.push('equal stash values did not rank earlier death first');hcGraveClose();
      }else{
        var saved=JSON.parse(localStorage.getItem('salvagerun:profile:5')||'null');if(!saved||JSON.stringify(saved.stash)!==before||saved.credits!==5000||saved.weapons.indexOf('pistol')<0||saved.weapons.indexOf('rifle')<0)bad.push('control lost save, stash, guns or cash: '+how+'/'+hc);
      }
    }
    try{
      snap();saveCopyQueue=function(){};window.storage=null;__runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();base=JSON.stringify(P);NETP2=false;NETSLOT='';NET.same=null;localStorage.removeItem('salvagerun:p2live');localStorage.removeItem('salvagerun:p2raid');ARCADE.on=false;SAVE_STALE=false;careerNewReload=function(){};saveCopyPut=function(){};saveCopyDel=function(k,cb){removed.push(k);if(cb)cb(true);};
      boot(true);boot(false);localStorage.setItem('salvagerun:profile','{"credits":1234,"pname":"protected"}');var original=localStorage.getItem('salvagerun:profile');
      localStorage.setItem(HC_KEY,'broken');raid('dead',true);
      if(localStorage.getItem('salvagerun:profile')!==original)bad.push('slot 1 changed');
      localStorage.setItem(HC_KEY,'[]');raid('dead',false);raid('extract',true);raid('abandon',true);
      return bad.length?bad.join('; '):null;
    }finally{
      try{if(G&&!G.over)__endRaid('abandon');}catch(_he){}__topClear();hcGraveClose();
      var keys=[];for(var i=0;i<localStorage.length;i++){var k=localStorage.key(i);if(k.indexOf('salvagerun:')===0)keys.push(k);}keys.forEach(function(k){localStorage.removeItem(k);});Object.keys(raw).forEach(function(k){localStorage.setItem(k,raw[k]);});
      P=pp;SLOT=sl;SKEY=sk;SAVE_STALE=ss;HC_REMOVED=hr;window.storage=ws;careerNewReload=nr;saveCopyPut=sp;saveCopyQueue=sq;saveCopyDel=sd;NETP2=np;NETSLOT=ns;NET.same=sm;ARCADE.on=ao;state=st;pin.value=pv;pin.__typed=pt;toggle.setAttribute('aria-checked','false');toggle.classList.remove('on');
    }
  }},
  {v:'37.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
