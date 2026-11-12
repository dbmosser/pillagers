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

if ($s.Contains("  {v:'37.73',what:")) { throw "check 37.73 is in the fixture already" }

SubRx @'
  {v:'37.72',what:
'@ @'
  {v:'37.73',what:'title graveyard and close buttons work by click without page errors, restore focus and preserve old normal saves',run:function(){
    var title=document.getElementById('title'),button=document.getElementById('hcgraves'),grave=document.getElementById('hcgrave'),close=document.getElementById('hcgraveclose'),list=document.getElementById('hcgravelist');
    if(!title||!button||!grave||!close||!list)return 'missing graveyard controls';
    var pp=P,cp=Object.assign({},CFG),np=NETP2,ns=NETSLOT,sm=NET.same,ao=ARCADE.on,ss=SAVE_STALE,hr=HC_REMOVED,sl=SLOT,sk=SKEY,sq=saveCopyQueue,ws=window.storage,raw={},bad=[],caught=[];
    var tc=title.className,gc=grave.className,gd=button.style.display,lh=list.innerHTML,active=document.activeElement,choice=document.getElementById('hcchoice'),cd=choice.style.display;
    var pin=document.getElementById('pnamein'),pv=pin.value,pt=pin.__typed;
    function ok(b,m){if(!b)bad.push(m);}
    function onErr(e){caught.push(String((e&&e.message)||e));}
    function click(e){e.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,view:window}));}
    try{
      for(var i=0;i<localStorage.length;i++){var k=localStorage.key(i);if(k.indexOf('salvagerun:')===0)raw[k]=localStorage.getItem(k);}
      P=JSON.parse(JSON.stringify(pp));saveCopyQueue=function(){};window.storage=null;
      __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NETP2=false;NETSLOT='';NET.same=null;ARCADE.on=false;SAVE_STALE=false;HC_REMOVED=false;
      var legacy=JSON.parse(JSON.stringify(P));delete legacy.hardcore;delete legacy.hcBorn;legacy.credits=4321;legacy.pname='legacy pillager';legacy.stash=['scrap','wire'];
      applyLoadedProfile({value:JSON.stringify(legacy)});
      ok(!P.hardcore&&P.credits===4321&&P.pname==='legacy pillager'&&JSON.stringify(P.stash)==='["scrap","wire"]','old normal save did not reload intact');
      var at=Date.now(),record={slot:'salvagerun:profile:5',born:at-864000000,at:at,name:'grim',look:{},value:42600,level:12,runs:24,extractions:17,kills:83,best:6800,days:10,by:'a warden',clock:372,period:'night'};
      var archived=JSON.stringify([record]);localStorage.setItem(HC_KEY,archived);
      grave.classList.remove('on');title.classList.add('on');titleRefresh();
      ok(getComputedStyle(button).display!=='none'&&button.getBoundingClientRect().width>0,'title graveyard button is hidden with a record');
      window.addEventListener('error',onErr);
      // v28.xx (cw-cx-graveclick): DOM click dispatch exercises the actual button bindings and catches inline scope errors.
      button.focus();click(button);
      ok(grave.classList.contains('on'),'clicking graveyard did not open the panel');
      ok(caught.length===0,'graveyard click threw: '+caught.join(' / '));caught.length=0;
      var rows=list.querySelectorAll('.hcgrave-row');
      ok(rows.length===1&&rows[0].getAttribute('data-hc-name')==='grim'&&rows[0].getAttribute('data-hc-value')==='42600','click did not render the staged graveyard record');
      ok(document.activeElement===close,'open did not focus close');
      click(close);
      ok(!grave.classList.contains('on'),'clicking close did not close the panel');
      ok(caught.length===0,'close click threw: '+caught.join(' / '));
      ok(document.activeElement===button,'close did not return focus to graveyard');
      ok(button.getAttribute('onclick')===null&&close.getAttribute('onclick')===null,'graveyard still has inline handlers');
      ok(typeof window.hcGraveOpen==='undefined'&&typeof window.hcGraveClose==='undefined','graveyard functions leaked to the page global scope');
      ok(localStorage.getItem(HC_KEY)===archived,'clicking changed the archive');
      ok(!P.hardcore&&P.credits===4321&&P.pname==='legacy pillager'&&JSON.stringify(P.stash)==='["scrap","wire"]','clicking changed the normal save');
      return bad.length?bad.join('; '):null;
    }finally{
      window.removeEventListener('error',onErr);
      try{if(G&&!G.over)__endRaid('abandon');}catch(_he){}__topClear();
      var ks=[];for(var j=0;j<localStorage.length;j++){var key=localStorage.key(j);if(key.indexOf('salvagerun:')===0)ks.push(key);}ks.forEach(function(k){localStorage.removeItem(k);});Object.keys(raw).forEach(function(k){localStorage.setItem(k,raw[k]);});
      P=pp;Object.assign(CFG,cp);NETP2=np;NETSLOT=ns;NET.same=sm;ARCADE.on=ao;SAVE_STALE=ss;HC_REMOVED=hr;SLOT=sl;SKEY=sk;saveCopyQueue=sq;window.storage=ws;
      title.className=tc;grave.className=gc;button.style.display=gd;list.innerHTML=lh;choice.style.display=cd;pin.value=pv;pin.__typed=pt;
      if(active&&document.contains(active))active.focus();
    }
  }},
  {v:'37.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
