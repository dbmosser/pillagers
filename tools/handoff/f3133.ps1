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

if ($s.Contains("  {v:'31.33',what:")) { throw "check 31.33 is in the fixture already" }

SubRx @'
  {v:'31.32',what:
'@ @'
  {v:'31.33',what:'cw-gearrules: the key lists and tips name the keys as they are now: the Keys window has no H row (H does nothing, the item wheel on hold q is the only heal), the locked gun keys and the rebind note say 1 to 8 and 0, the controls tips say keys 1 to 8 and 0 and point at the item wheel (no tip teaches 1 to 4, 5-6, 7-8, 9 plate or the G, H, U, J keys), and an item hover card names the item wheel and not HEAL, THROW or PLATE keys',
   run:function(){
     if(typeof GEARRULES==='undefined'||!GEARRULES.length||typeof KEYS_ACTS==='undefined'||typeof KEYS_SECT==='undefined'||typeof keysListBody!=='function'||typeof keysBind!=='function') return 'SKIP: no tips or key list in this build';
     if(typeof GUN_CLASSES==='undefined'||typeof slotKeyName!=='function'||typeof slotKeyCode!=='function') return 'SKIP: no gun key table in this build';
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof beltInfoCard!=='function'||typeof txRecord!=='function'||typeof KEYS!=='object') return 'SKIP: this fixture cannot stage a raid and a hover card';
     var bad=[], i, k, n=GUN_CLASSES.length, codes=[], h, all='', txt='', row=-1, wrow=-1, arow=-1, wheelTxt='', armTxt='', t, note0=KEYS.note, g=null, p=null, hit, xs, f, bag0, healWas;
     function rowTxt(r){ return (typeof GEARRULES[r][1]==='function')?String(GEARRULES[r][1]()):String(GEARRULES[r][1]); }
     function kd(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function ku(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ZERO: the keys the game really gives the guns: one a kind, 1 to 8 and then 0 (key 9 does nothing)
       for(k=0;k<n;k++) codes.push(slotKeyCode(k));
       if(codes.indexOf('Digit9')>=0) bad.push('ZERO: key 9 is a gun key now, so these words need another look');
       // ONE: no row for H on the Keys list, in the table, the sections or the window
       if(KEYS_ACTS.some(function(a){ return a[0]==='KeyH'; })) bad.push('ONE: the Keys list still has an H row');
       if(KEYS_SECT.some(function(s){ return s[1].indexOf('KeyH')>=0; })) bad.push('ONE: a Keys section still lists H');
       h=keysListBody();
       if(h.indexOf('data-k="KeyH"')>=0||/heal \(tap\)|armour plate \(hold\)/i.test(h)) bad.push('ONE: the Keys window still draws an H heal row');
       if(h.indexOf('data-k="KeyQ"')<0||h.indexOf('data-k="KeyG"')<0||!/item wheel/i.test(h)) bad.push('ONE: control: the Keys window lost the Q item wheel row or the G air strike row');
       // TWO: the locked gun keys and the note a rebind onto one gives
       t=slotKeyName(0)+' - '+slotKeyName(n-2)+', '+slotKeyName(n-1);
       if(h.indexOf(t)<0) bad.push('TWO: the locked keys do not say ['+t+']');
       if(h.indexOf('1 - 9')>=0) bad.push('TWO: the locked keys still say 1 - 9');
       KEYS.note=null;
       if(keysBind('KeyR','Digit5')!==false) bad.push('TWO: a rebind onto key 5 was not refused');
       t=(KEYS.note&&KEYS.note.s)||'';
       if(!/1-8 AND 0 CANNOT BE REBOUND/.test(t)||/1-9/.test(t)) bad.push('TWO: the refusal note says ['+t+']');
       // THREE: the tips
       for(i=0;i<GEARRULES.length;i++){ all+=' | '+rowTxt(i); if(wrow<0&&GEARRULES[i][0]==='WEAPONS') wrow=i; if(row<0&&GEARRULES[i][0]==='ITEM WHEEL') row=i; if(arow<0&&GEARRULES[i][0]==='ARMOUR') arow=i; }
       if(wrow<0) bad.push('THREE: the tips have no WEAPONS rule');
       else {
         txt=rowTxt(wrow)+' '+rowTxt(wrow+1);
         t='keys '+slotKeyName(0)+' to '+slotKeyName(n-2)+' and '+slotKeyName(n-1);
         if(txt.toLowerCase().indexOf(t)<0) bad.push('THREE: the WEAPONS tip does not say ['+t+'] (it says ['+txt.trim()+'])');
         if(/\b1 to 4\b|\b1-4\b|four gun/i.test(txt)) bad.push('THREE: the WEAPONS tip still says keys 1 to 4 ['+txt.trim()+']');
         if(txt!==txt.toLowerCase()) bad.push('THREE: the WEAPONS tip is not lower case ['+txt.trim()+']');
       }
       if(row<0) bad.push('THREE: the tips have no ITEM WHEEL rule');
       else {
         wheelTxt=rowTxt(row)+' '+rowTxt(row+1);
         if(!/hold q/.test(wheelTxt)||!/grenade/.test(wheelTxt)||!/heal/.test(wheelTxt)||!/plate/.test(wheelTxt)) bad.push('THREE: the ITEM WHEEL tip does not say hold q, a grenade, a heal and a plate ['+wheelTxt.trim()+']');
         if(wheelTxt!==wheelTxt.toLowerCase()) bad.push('THREE: the ITEM WHEEL tip is not lower case ['+wheelTxt.trim()+']');
       }
       if(arow>=0){ armTxt=rowTxt(arow)+' '+rowTxt(arow+1)+' '+rowTxt(arow+2)+' '+rowTxt(arow+3); if(/on a key/.test(armTxt)) bad.push('THREE: the ARMOUR tip still says keep a plate on a key ['+armTxt.trim()+']'); }
       if(/\b5-6\b|\b7-8\b|9 plate|\bG, H\b|\bU, J\b|pick the next|Gun stays in hand|TACTICAL BELT/.test(all)) bad.push('THREE: a tip still teaches the retired belt keys ['+all.match(/\b5-6\b|\b7-8\b|9 plate|\bG, H\b|\bU, J\b|pick the next|Gun stays in hand|TACTICAL BELT/)[0]+']');
       // FOUR: the item hover card names the wheel. The belt holds guns only now, so the card is called on a stand-in cell
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       if(padOn()) return 'SKIP: a pad is the last device here';
       [['heal','bandage'],['heal','medkit'],['stim','stim'],['throw','frag'],['armor','plate']].forEach(function(q){
         var S={kind:q[0],itemKey:q[1],icon:q[1],count:2}, c={i:6,x:600,y:800,w:70,h:70}, ts;
         if(!ITEMS[q[1]]) return;
         ts=txRecord(function(){ beltInfoCard(S,c); }).map(function(x){ return String(x.t).toLowerCase(); });
         if(!ts.length) { bad.push('FOUR: the '+q[1]+' card drew no text'); return; }
         if(ts.indexOf('item wheel')<0) bad.push('FOUR: the '+q[1]+' card does not name the item wheel ('+ts.slice(-6).join('|')+')');
         if(ts.some(function(s){ return /^(heal|heal chosen|use chosen|throw|throw chosen|next|slot|plate|hold h|h|g|u|j)$/.test(s); })) bad.push('FOUR: the '+q[1]+' card still names the keys H, G, U or J ('+ts.slice(-8).join('|')+')');
       });
       // FIVE: control, the claim behind the removed H row: tapping H in a raid heals nothing and starts nothing
       bag0=g.bag.slice(); g.bag.length=0; g.bag.push('medkit'); p.hp=40; p.healQ=0; p.prep=null; keys={};
       kd('KeyH'); for(f=0;f<4;f++) __loop(performance.now()+f*17); ku('KeyH'); for(f=4;f<8;f++) __loop(performance.now()+f*17);
       if(__state()!==g||g.over) return 'the raid ended while H was tapped';
       if(p.prep||g.bag.indexOf('medkit')<0) bad.push('FIVE: tapping H still started a heal ('+(p.prep?'prepping':'bag lost the medkit')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ KEYS.note=note0; }catch(_n){}
       try{ if(typeof BELTHOV!=='undefined'){ BELTHOV.box=null; BELTHOV.i=-1; } }catch(_b){}
       try{ keys={}; if(typeof HHOLD!=='undefined') HHOLD.arm=0; }catch(_h){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'31.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
