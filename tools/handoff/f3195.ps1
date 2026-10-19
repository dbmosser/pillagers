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

if ($s.Contains("  {v:'31.95',what:")) { throw "check 31.95 is in the fixture already" }

SubRx @'
  {v:'31.94',what:
'@ @'
  {v:'31.95',what:'pad name letters, next/back/done, new-save boot and reload, stash name and safe text focus (J4)',
   run:function(){
     var ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),ns=NET.same,ao=ARCADE.on,at=ATT.on,st=state;
     var pp=P,slot=SLOT,sk=SKEY,ss=SAVE_STALE,nr=typeof careerNewReload==='function'?careerNewReload:null,storage=window.storage,top=document.getElementById('title'),tc=top.className;
     var pin=document.getElementById('pnamein'),iv=pin.value,it=pin.__typed,records={},bad=[],pad,navs=0,target='',snap,baseline,probe;
     var ptr=slotPtrKey(),nk=NEWNAME_KEY+':'+ptr;
     function remember(k){records[k]=localStorage.getItem(k);}
     function poll(b){pad={connected:true,index:0,id:'Xbox J4',mapping:'standard',axes:[0,0,0,0],buttons:[]};for(var i=0;i<17;i++)pad.buttons.push({pressed:i===b,value:i===b?1:0});pollPad();}
     function tap(b){poll(-1);poll(b);poll(b);poll(-1);}
     function focus(id){padSetFocus(document.getElementById(id));PAD.focusMd=top;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile(); baseline=JSON.stringify(P);
       NET.same=null;ARCADE.on=false;ATT.on=false;SAVE_STALE=false;window.storage=null;state='title';top.classList.add('on');
       remember(ptr);remember(nk);for(var i=1;i<=8;i++)remember(i===1?'salvagerun:profile':'salvagerun:profile:'+i);
       navigator.getGamepads=function(){return [pad];};PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.announced=true;PAD.focus=null;
       pin.value='pillager';pin.__typed=0;focus('pnamein');tap(0);
       if(typeof PADNAME==='undefined'||!PADNAME)return 'A on the career name has no pad letter picker';
       tap(12);if(PADNAME.l[0]!=='q')bad.push('up did not change p to q once');
       tap(13);if(PADNAME.l[0]!=='p')bad.push('down did not restore p once');
       tap(0);if(PADNAME.pos!==1)bad.push('A did not move to letter 2 once');
       tap(1);if(PADNAME.pos!==0)bad.push('B did not step back once');
       tap(12);tap(9);
       if(PADNAME||pin.value!=='qillager'||!pin.__typed)bad.push('Menu did not keep the typed lower case name');
       // Pressing A straight through a pre-filled name needs no letter changes.
       focus('pnamein');tap(0);for(i=0;i<16;i++)tap(0);
       if(PADNAME||pin.value!=='qillager')bad.push('A straight through did not keep the pre-filled name');
       if(nr)careerNewReload=function(){navs++;};
       for(i=1;i<=8;i++){var k=String(i);if(k!==SLOT&&!slotBlocked(k)){localStorage.removeItem(i===1?'salvagerun:profile':'salvagerun:profile:'+i);break;}}
       focus('newgame');tap(0);target=localStorage.getItem(ptr);
       if(navs!==1||target===slot)bad.push('pad A did not create a new save on a fresh slot');
       var pending=JSON.parse(localStorage.getItem(nk)||'null');
       if(!pending||pending.n!=='qillager'||pending.s!==target)bad.push('new save did not carry the pad name through navigation');
       // Follow the fresh page boot using the same name consumer, then reload its saved profile through the actual loader.
       SLOT=target;SKEY=target==='1'?'salvagerun:profile':'salvagerun:profile:'+target;P=JSON.parse(baseline);P.runs=0;
       if(newNameTake()!=='qillager')bad.push('fresh save boot lost the pad name');
       snap=localStorage.getItem(SKEY);if(!snap||JSON.parse(snap).pname!=='qillager')bad.push('fresh save did not persist the pad name');
       P.pname='changed';applyLoadedProfile({value:snap});if(P.pname!=='qillager')bad.push('reload lost the pad name');
       renderHub();if(!document.getElementById('stashname')||document.getElementById('stashname').textContent!=='qillager')bad.push('stash does not show the saved name');
       // Use real visible fields as well as a visible synthetic panel for fields hidden behind other screens.
       probe=document.createElement('div');probe.innerHTML='<input id="j4text"><textarea id="j4feedback"></textarea><input type="password"><input type="search"><input type="number"><button>back</button>';
       probe.className='modal on';probe.style.cssText='position:absolute;left:20px;top:20px;z-index:999;display:block';document.getElementById('root').appendChild(probe);
       if(padFocusables(probe).some(function(e){return e.tagName==='INPUT'||e.tagName==='TEXTAREA';}))bad.push('pad focus reaches a text field without a pad route');
       PAD.focus=null;PAD.focusMd=null;for(i=0;i<6;i++){tap(i%2?12:13);if(PAD.focus&&/^(INPUT|TEXTAREA)$/.test(PAD.focus.tagName))bad.push('pad navigation landed on an unsupported text field');}
       var list=padFocusables(top);if(list.indexOf(pin)<0)bad.push('career name was removed from pad focus');
       var hub=document.getElementById('hub');hub.classList.add('on');
       if(padFocusables(hub).some(function(e){return e.id==='stashsearch';}))bad.push('pad reaches stash search');hub.classList.remove('on');
       return bad.length?bad.join('; '):null;
     }finally{
       if(typeof PADNAME!=='undefined'&&PADNAME)padNameClose(false);if(probe)probe.remove();
       if(nr)careerNewReload=nr;if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(records).forEach(function(k){if(records[k]===null)localStorage.removeItem(k);else localStorage.setItem(k,records[k]);});
       P=pp;SLOT=slot;SKEY=sk;SAVE_STALE=ss;window.storage=storage;NET.same=ns;ARCADE.on=ao;ATT.on=at;state=st;pin.value=iv;pin.__typed=it;top.className=tc;
       try{__endRaid('abandon');}catch(e){}__topClear();Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'31.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
