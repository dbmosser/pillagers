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

if ($s.Contains("  {v:'32.95',what:")) { throw "check 32.95 is in the fixture already" }

SubRx @'
  {v:'32.94',what:
'@ @'
  {v:'32.95',what:'daily restore has one primary action, a source stepper and clear undo, a correct saves navigation marker, compact dated details and readable nearby key hints',
   run:function(){
     var old={p:P,g:G,sk:SKEY,sl:SLOT,bk:RESTORE_BACKUP_KEY,p2:NETP2,ns:NETSLOT,arc:ARCADE.on,spec:NET.specG,state:state},
       kept={},bad=[],i,k,day,raw,src,row,list,primary,undo,detail,hero,title,meta,nav,zoom,css,other;
     function remember(key){if(!Object.prototype.hasOwnProperty.call(kept,key))kept[key]=localStorage.getItem(key);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();P=JSON.parse(JSON.stringify(P));P.runs=0;
       G=null;NET.specG=null;NETP2=false;NETSLOT='';ARCADE.on=0;SLOT='1';SKEY='salvagerun:profile';RESTORE_BACKUP_KEY=SKEY+':prerestore';
       dailySaveKeys(false).forEach(function(key){remember(key);});dailySaveClear(false);
       raw=JSON.stringify(P);remember(RESTORE_BACKUP_KEY);localStorage.setItem(RESTORE_BACKUP_KEY,raw);
       for(i=0;i<3;i++){day=new Date();day.setDate(day.getDate()-i);k=SKEY+':daily:'+dailySaveDate(day);remember(k);localStorage.setItem(k,raw);}
       __hubEnter();__topClear();openSettings();src=document.getElementById('set_restore_source');
       for(i=0;i<4&&src.textContent!=='yesterday';i++)src.click();
       row=src.closest('.row');list=document.getElementById('setlist');row.scrollIntoView({block:'center'});src.focus();row.dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
       if(window.__setDetailSync)window.__setDetailSync();setSecSpy(list);
       nav=list.querySelector('.setjump button[data-sec="SAVES AND TOOLS"]');
       if(!nav||!nav.classList.contains('on'))bad.push('daily restore still highlights the display section');
       if(list.querySelectorAll('.setjump button[data-sec="SAVES AND TOOLS"]').length!==1||list.querySelectorAll('#setsec_SAVES_AND_TOOLS').length!==1)bad.push('save section navigation or header duplicated');
       primary=document.getElementById('set_restore');undo=document.getElementById('set_unrestore');zoom=parseFloat(document.getElementById('settingsmodal').style.zoom)||1;
       // v28.xx (cw-cx-dailyrestorefinish): evaluate the final focus colours synchronously instead of sampling a 120ms CSS transition.
       [src,primary,undo].forEach(function(b){b.style.setProperty('transition','none','important');});
       css=getComputedStyle(primary);other=getComputedStyle(src);
       if(css.backgroundColor!==other.borderTopColor||css.color===other.color||primary.getBoundingClientRect().height/zoom<55)bad.push('restore is not the 56px primary action');
       if(getComputedStyle(undo).backgroundColor===css.backgroundColor)bad.push('undo competes with the primary action');
       if(getComputedStyle(src,'::before').content==='none'||getComputedStyle(src,'::after').content==='none')bad.push('source choice has no stepper affordance');
       detail=document.getElementById('setdetail');hero=detail.querySelector('.daily-selected');title=detail.querySelector('.sdk');meta=detail.querySelector('.daily-meta');
       if(!hero||!title||parseFloat(getComputedStyle(hero).fontSize)>parseFloat(getComputedStyle(title).fontSize))bad.push('relative day label still dominates the title');
       if(!meta||meta.textContent.indexOf('runs')>=0)bad.push('zero-run copy still shows empty career statistics');
       if(detail.textContent.indexOf('undo last restore')<0)bad.push('undo hint does not name the action');
       var hints=list.querySelectorAll('.save-key-hint kbd');
       if(hints.length!==2)bad.push('nearby key hints lack keycaps');
       for(i=0;i<hints.length;i++)if(parseFloat(getComputedStyle(hints[i]).fontSize)<16)bad.push('key hint is below 16px');
       var display=list.querySelector('.setjump button[data-sec="DISPLAY"]');
       display.onclick();if(nav.classList.contains('on'))bad.push('leaving saves keeps its section marker');
       nav.onclick();if(!nav.classList.contains('on'))bad.push('saves navigation does not mark its section');
       return bad.length?bad.join('; '):null;
     }catch(e){return 'threw: '+(e&&e.stack||e);}
     finally{
       try{if(document.activeElement&&list&&list.contains(document.activeElement))document.activeElement.blur();dailySaveClear(false);Object.keys(kept).forEach(function(key){if(kept[key]===null)localStorage.removeItem(key);else localStorage.setItem(key,kept[key]);});}catch(_restore){}
       try{__endRaid('abandon');}catch(_end){}__topClear();
       P=old.p;G=old.g;SKEY=old.sk;SLOT=old.sl;RESTORE_BACKUP_KEY=old.bk;NETP2=old.p2;NETSLOT=old.ns;ARCADE.on=old.arc;NET.specG=old.spec;state=old.state;
     }
   }},
  {v:'32.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
