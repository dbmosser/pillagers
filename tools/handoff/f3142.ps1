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

if ($s.Contains("  {v:'31.42',what:")) { throw "check 31.42 is in the fixture already" }

SubRx @'
  {v:'31.41',what:
'@ @'
  {v:'31.42',what:'cw-gunkeys19: the gun keys are named 1-8, 0 wherever they are named, never 1-9 (key 9 does nothing, key 0 is the rocket launcher): the controls list, the compact list, the pause line, the demo controls card and the stash key row read the keys the game really gives the guns, a gun on the wrong key is refused in words that say 1 to 8 and 0, and with a gun under the cursor on the stash key 0 binds the ninth gun key and key 9 binds nothing',
   run:function(){
     if(typeof LEGEND==='undefined'||typeof LEGEND_MINI==='undefined'||typeof keysLegendHtml!=='function'||typeof GUN_CLASSES==='undefined'||typeof slotKeyName!=='function') return 'SKIP: this build has no gun key table or controls lists';
     var bad=[], i, n=GUN_CLASSES.length, label=slotKeyName(0)+'-'+slotKeyName(n-2)+', '+slotKeyName(n-1), old=['1','-9'].join(''), gear=null, row=null, mini=-1, html='', w='', rows=null, sg=null, kb=null, ha, prof, hub=document.getElementById('hub');
     var stK=state, gaK=(G?G.arcade:undefined), press=function(k){ document.dispatchEvent(new KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true})); };
     // ZERO: the label is read off the key table, so it follows the keys the game gives the guns (one a kind, 1 to 8 and then 0)
     if(label!=='1-8, 0') bad.push('ZERO: the gun key table reads '+label+', so these words need another look');
     // ONE: the controls list (F1)
     for(i=0;i<LEGEND.length;i++) if(LEGEND[i][0]==='GEAR') gear=LEGEND[i][1];
     if(!gear) return 'SKIP: the controls list has no GEAR heading';
     gear.forEach(function(r){ if(/a gun for each kind/.test(r[1])) row=r; if(r[0]===old) bad.push('ONE: the controls list has a '+old+' row ('+r[1]+')'); });
     if(!row) bad.push('ONE: the controls list has no row for the gun keys');
     else if(row[0]!==label) bad.push('ONE: the controls list names the gun keys '+row[0]+', not '+label);
     // TWO: the compact list on the screen
     for(i=0;i<LEGEND_MINI.length;i++){ if(LEGEND_MINI[i][1]==='guns') mini=i; if(LEGEND_MINI[i][0]===old) bad.push('TWO: the compact list has a '+old+' row'); }
     if(mini<0) bad.push('TWO: the compact list has no guns row');
     else if(LEGEND_MINI[mini][0]!==label) bad.push('TWO: the compact list names the gun keys '+LEGEND_MINI[mini][0]+', not '+label);
     // THREE: the pause line in a raid (a pad as the last device writes the pad line instead)
     if(!padOn()){
       try{ state='raid'; if(G) G.arcade=0; html=String(keysLegendHtml()); } finally{ state=stK; if(G) G.arcade=gaK; }
       if(html.indexOf('>'+label+'</b> guns')<0) bad.push('THREE: the pause line does not say '+label+' guns');
       if(html.indexOf('>'+old+'</b>')>=0) bad.push('THREE: the pause line still says '+old);
     }
     // FOUR: the demo controls card
     if(typeof arcadeCardRows==='function'){
       try{ rows=arcadeCardRows(); }catch(_a){ rows=null; }
       if(rows){ rows.forEach(function(r){ if(r&&r[0]==='SWITCH GUN') sg=r; }); if(!sg) bad.push('FOUR: the demo controls card has no SWITCH GUN row'); else if(sg[1]!==label) bad.push('FOUR: the demo controls card names the gun keys '+sg[1]+', not '+label); }
     }
     // FIVE: the stash key row and what a refused gun is told
     kb=document.getElementById('invkeybar');
     if(kb){ w=(kb.textContent||'').replace(/\s+/g,' '); if(w.indexOf(label+' bind to key')<0) bad.push('FIVE: the stash key row does not say '+label+' bind to key ('+w.slice(-40)+')'); if(w.indexOf(old+' ')>=0) bad.push('FIVE: the stash key row still says '+old); }
     if(typeof beltClassWord==='function'){ w=String(beltClassWord('gun')); if(!/KEYS 1 TO 8 AND 0$/.test(w)) bad.push('FIVE: a gun on the wrong key is told "'+w+'", not guns go on keys 1 to 8 and 0'); }
     // SIX: with a gun under the cursor on the stash, key 0 binds the ninth gun key (the rocket launcher) and key 9 binds nothing; key 1 binds the first as it always did
     if(typeof INVHOVER!=='undefined'&&hub&&ITEMS.gun_rocket&&ITEMS.gun_pistol&&window.__P&&window.__hubEnter&&n===9){
       function arm(k,item){ prof.stash=[item]; prof.kit=[]; prof.hotAssign={}; prof.junk={}; try{ renderHub(); }catch(_r){} hub.classList.add('on'); INVHOVER=item; press(k); return JSON.stringify(prof.hotAssign); }
       try{
         __topClear(); __cleanProfile(); prof=__P();
         try{ __hubEnter(); }catch(_h){}
         ha=arm('1','gun_pistol'); if(ha!=='{"0":"gun_pistol"}') bad.push('SIX: control: key 1 over the pistol bound '+ha+', not the first gun key');
         ha=arm('0','gun_rocket'); if(ha!=='{"8":"gun_rocket"}') bad.push('SIX: key 0 over the rocket launcher bound '+ha+', not the ninth gun key');
         ha=arm('9','gun_rocket'); if(ha!=='{}') bad.push('SIX: key 9 over the rocket launcher bound '+ha+', but key 9 does nothing');
       }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
       finally{ try{ INVHOVER=null; }catch(_i){} try{ hub.classList.remove('on'); }catch(_o){} try{ if(prof){ prof.junk={}; prof.hotAssign={}; prof.kit=[]; } }catch(_j){} __topClear(); __cleanProfile(); }
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'31.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
