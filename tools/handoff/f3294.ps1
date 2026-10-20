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

if ($s.Contains("  {v:'32.94',what:")) { throw "check 32.94 is in the fixture already" }

SubRx @'
  {v:'32.93',what:
'@ @'
  {v:'32.94',what:'the Settings daily source, restore and undo are visible and separately clickable, with a clean focus border and selected copy details directly below the title',
   run:function(){
     var old={p:P,g:G,sk:SKEY,sl:SLOT,bk:RESTORE_BACKUP_KEY,p2:NETP2,ns:NETSLOT,arc:ARCADE.on,spec:NET.specG,state:state},
         kept={},bad=[],src,buttons,row,list,detail,i,k,raw,day,sourceKey,ls,rs,rect,hit,title,hero,meta,zoom;
     function remember(key){if(!Object.prototype.hasOwnProperty.call(kept,key))kept[key]=localStorage.getItem(key);}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null;NET.specG=null;NETP2=false;NETSLOT='';ARCADE.on=0;SLOT='1';SKEY='salvagerun:profile';RESTORE_BACKUP_KEY=SKEY+':prerestore';
       dailySaveKeys(false).forEach(function(key){remember(key);});dailySaveClear(false);
       raw=JSON.stringify(P);remember(RESTORE_BACKUP_KEY);localStorage.setItem(RESTORE_BACKUP_KEY,raw);
       for(i=0;i<3;i++){day=new Date();day.setDate(day.getDate()-i);k=SKEY+':daily:'+dailySaveDate(day);remember(k);localStorage.setItem(k,raw);}
       __hubEnter();__topClear();openSettings();
       src=document.getElementById('set_restore_source');if(!src)return 'daily source absent';
       for(i=0;i<4&&src.textContent!=='yesterday';i++)src.click();
       row=src.closest('.row');list=document.getElementById('setlist');
       row.scrollIntoView({block:'center'});src.focus();row.dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
       if(window.__setDetailSync)window.__setDetailSync();
       ls=list.getBoundingClientRect();rs=row.getBoundingClientRect();
       // v28.xx (cw-cx-dailyrestoreui): the gate is 977px tall, so menu zoom turns a 44px control into about 39.8 viewport pixels.
       zoom=parseFloat(document.getElementById('settingsmodal').style.zoom)||1;
       buttons=[src,document.getElementById('set_restore'),document.getElementById('set_unrestore')];
       for(i=0;i<buttons.length;i++){
         if(!buttons[i]){bad.push('restore or undo absent');continue;}
         rect=buttons[i].getBoundingClientRect();
         if(rect.width/zoom<60||rect.height/zoom<43)bad.push(buttons[i].id+' has a small target: '+Math.round(rect.width/zoom)+'x'+Math.round(rect.height/zoom));
         if(rect.left<ls.left||rect.right>ls.right+1||rect.top<ls.top||rect.bottom>ls.bottom+1)bad.push(buttons[i].id+' is clipped or outside the list');
         if(rect.left<rs.left||rect.right>rs.right+1||rect.top<rs.top||rect.bottom>rs.bottom+1)bad.push(buttons[i].id+' does not fit its restore row');
         hit=document.elementFromPoint((rect.left+rect.right)/2,(rect.top+rect.bottom)/2);
         if(!hit||!(hit===buttons[i]||buttons[i].contains(hit)))bad.push(buttons[i].id+' is not reachable at its visible centre');
         if(i&&rect.left<buttons[i-1].getBoundingClientRect().right)bad.push('restore controls overlap');
       }
       if(row.scrollWidth>row.clientWidth+1)bad.push('restore row overflows horizontally');
       src.classList.add('padfocus');
       // v28.xx (cw-cx-dailyrestoreui): Chromium rounds borders to device pixels under CSS zoom; check the visible border and absence of the unwanted focus effects.
       var css=getComputedStyle(src);
       if(css.boxShadow!=='none'||css.outlineStyle!=='none')bad.push('source focus still has shadow '+css.boxShadow+' or outline '+css.outlineStyle);
       if(!(parseFloat(css.borderTopWidth)>0)||css.borderTopStyle!=='solid')bad.push('source focus border is missing');
       src.classList.remove('padfocus');
       detail=document.getElementById('setdetail');title=detail.querySelector('.sdk');hero=detail.querySelector('.daily-selected');meta=detail.querySelector('.daily-meta');
       if(!title||!hero||hero.textContent!=='yesterday'||!meta)bad.push('detail pane omits selected copy and saved date');
       else{
         day=new Date();day.setDate(day.getDate()-1);
         if(meta.textContent.indexOf(dailySaveDate(day))<0)bad.push('detail date differs from selected copy');
         if(hero.getBoundingClientRect().top-title.getBoundingClientRect().bottom>25)bad.push('selected backup floats far below title');
         if(meta.getBoundingClientRect().top-hero.getBoundingClientRect().bottom>25)bad.push('saved date floats far below selected backup');
       }
       src.click();src.click();if(window.__setDetailSync)window.__setDetailSync();
       hero=detail.querySelector('.daily-selected');
       if(!hero||hero.textContent!=='file'||detail.querySelector('.daily-meta'))bad.push('file choice retains a daily date');
       return bad.length?bad.join('; '):null;
     }catch(e){return 'threw: '+(e&&e.stack||e);}
     finally{
       try{if(src)src.classList.remove('padfocus');dailySaveClear(false);Object.keys(kept).forEach(function(key){if(kept[key]===null)localStorage.removeItem(key);else localStorage.setItem(key,kept[key]);});}catch(_restore){}
       try{__endRaid('abandon');}catch(_end){}__topClear();
       P=old.p;G=old.g;SKEY=old.sk;SLOT=old.sl;RESTORE_BACKUP_KEY=old.bk;NETP2=old.p2;NETSLOT=old.ns;ARCADE.on=old.arc;NET.specG=old.spec;state=old.state;
     }
   }},
  {v:'32.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
