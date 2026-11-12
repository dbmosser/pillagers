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

if ($s.Contains("  {v:'37.70',what:")) { throw "check 37.70 is in the fixture already" }

SubRx @'
  {v:'37.69',what:
'@ @'
  {v:'37.70',what:'title hardcore uses the shared 40 by 20 pill, centred knob and on colours while player 2 hides the choice and old saves still load',run:function(){
    var title=document.getElementById('title'),choice=document.getElementById('hcchoice'),toggle=document.getElementById('hctoggle'),settings=document.getElementById('settingsmodal');
    if(!title||!choice||!toggle||!settings)return 'missing title hardcore or settings panel';
    var pp=P,cp=Object.assign({},CFG),np=NETP2,ns=NETSLOT,sm=NET.same,ao=ARCADE.on,ss=SAVE_STALE,hr=HC_REMOVED,sl=SLOT,sk=SKEY,sq=saveCopyQueue,ws=window.storage,raw={},bad=[],ref=null,motion=null;
    var tc=title.className,sc=settings.className,cd=choice.style.display,ta=toggle.getAttribute('aria-checked'),cl=toggle.className;
    var pin=document.getElementById('pnamein'),pv=pin.value,pt=pin.__typed;
    function ok(b,m){if(!b)bad.push(m);}
    // v28.xx (cw-cx-hardcorepill): fractional menu zoom rounds resolved lengths by a few thousandths of a CSS pixel.
    function nearPx(v,n){return typeof v==='string'&&/px$/.test(v)&&Math.abs(parseFloat(v)-n)<0.05;}
    function box(e){var s=getComputedStyle(e),k=getComputedStyle(e,'::after');return {w:s.width,h:s.height,rad:s.borderRadius,bg:s.backgroundColor,rw:e.offsetWidth,rh:e.offsetHeight,kw:k.width,kh:k.height,kl:k.left,kt:k.top,kr:k.borderRadius,kbg:k.backgroundColor,tr:k.transform};}
    function dims(a,b){ok(nearPx(a.w,40)&&nearPx(a.h,20)&&nearPx(a.rad,10),'title is '+a.w+' by '+a.h+' with radius '+a.rad);ok(nearPx(a.kw,16)&&nearPx(a.kh,16)&&nearPx(a.kl,2)&&nearPx(a.kt,2)&&a.kr==='50%','knob geometry differs: '+[a.kw,a.kh,a.kl,a.kt,a.kr].join('/'));ok(Math.abs(a.rw-b.rw)<0.1&&Math.abs(a.rh-b.rh)<0.1,'title and settings reference boxes differ');ok(a.bg===b.bg&&a.kbg===b.kbg,'shared toggle colours differ');}
    try{
      for(var i=0;i<localStorage.length;i++){var k=localStorage.key(i);if(k.indexOf('salvagerun:')===0)raw[k]=localStorage.getItem(k);}
      P=JSON.parse(JSON.stringify(pp));saveCopyQueue=function(){};window.storage=null;
      __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NETP2=false;NETSLOT='';NET.same=null;ARCADE.on=false;SAVE_STALE=false;HC_REMOVED=false;
      title.classList.add('on');titleRefresh();ok(getComputedStyle(choice).display!=='none','host choice is hidden');
      // v28.xx (cw-cx-hardcorepill): Settings currently uses cycle buttons, so measure the unchanged shared class in its panel without altering a real setting.
      ref=document.createElement('button');ref.type='button';ref.className='ui-toggle';ref.style.flex='none';ref.setAttribute('aria-hidden','true');settings.appendChild(ref);settings.classList.add('on');
      motion=document.createElement('style');motion.textContent='#root .ui-toggle::after{transition:none !important;}';document.head.appendChild(motion);
      toggle.setAttribute('aria-checked','false');toggle.classList.remove('on');
      var off=box(toggle),rs=box(ref);dims(off,rs);
      var tr=toggle.getBoundingClientRect(),cr=choice.getBoundingClientRect();ok(tr.width>0&&tr.height>0&&Math.abs((tr.top+tr.bottom-cr.top-cr.bottom)/2)<1,'hardcore pill is not vertically centred');
      ok(off.tr==='none'||new DOMMatrixReadOnly(off.tr).m41===0,'off knob is shifted');
      toggle.onclick();ref.classList.add('on');var on=box(toggle),ron=box(ref);dims(on,ron);
      ok(toggle.getAttribute('aria-checked')==='true'&&toggle.classList.contains('on'),'click did not enable hardcore');
      ok(on.tr!=='none'&&Math.abs(new DOMMatrixReadOnly(on.tr).m41-20)<0.05,'on knob did not move right by 20px');
      toggle.onclick();ok(toggle.getAttribute('aria-checked')==='false'&&!toggle.classList.contains('on'),'second click did not disable hardcore');
      NETP2=true;titleRefresh();ok(getComputedStyle(choice).display==='none','player 2 gained a hardcore switch');NETP2=false;
      var legacy=JSON.parse(JSON.stringify(P));delete legacy.hardcore;delete legacy.hcBorn;legacy.credits=4321;legacy.pname='legacy pillager';legacy.stash=['scrap','wire'];
      applyLoadedProfile({value:JSON.stringify(legacy)});titleRefresh();ok(!P.hardcore&&P.credits===4321&&P.pname==='legacy pillager'&&JSON.stringify(P.stash)==='["scrap","wire"]','old normal save did not reload intact');
      return bad.length?bad.join('; '):null;
    }finally{
      try{if(G&&!G.over)__endRaid('abandon');}catch(_he){}__topClear();if(ref)ref.remove();if(motion)motion.remove();
      var ks=[];for(var j=0;j<localStorage.length;j++){var key=localStorage.key(j);if(key.indexOf('salvagerun:')===0)ks.push(key);}ks.forEach(function(k){localStorage.removeItem(k);});Object.keys(raw).forEach(function(k){localStorage.setItem(k,raw[k]);});
      P=pp;Object.assign(CFG,cp);NETP2=np;NETSLOT=ns;NET.same=sm;ARCADE.on=ao;SAVE_STALE=ss;HC_REMOVED=hr;SLOT=sl;SKEY=sk;saveCopyQueue=sq;window.storage=ws;
      title.className=tc;settings.className=sc;choice.style.display=cd;toggle.setAttribute('aria-checked',ta);toggle.className=cl;pin.value=pv;pin.__typed=pt;
    }
  }},
  {v:'37.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
