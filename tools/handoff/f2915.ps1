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

if ($s.Contains("  {v:'29.15',what:")) { throw "check 29.15 is in the fixture already" }

SubRx @'
  {v:'29.14',what:
'@ @'
  {v:'29.15',what:'the gun keys: no marksman, 7 sniper, 8 energy, 0 the Rocket class (the ninth cell), 9 does nothing, and a saved table with the marksman class is kept as 8 plus the rocket (his order 2026-10-18)',
   run:function(){
     if(typeof slotKeyName!=='function'||typeof gunKeysMigrate!=='function') return 'no slotKeyName or gunKeysMigrate: the gun keys are not renumbered';
     var g=null, bad=[], sh=setHot, sz=(typeof setZoom==='function')?setZoom:null, hots=[], zooms=0, svk, want, t, i;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       svk=P.gunKeys;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       want='pistol,smg,rifle,carbine,lmg,shotgun,sniper,energy,rocket';
       P.gunKeys=undefined; t=gunKeyTable().join(',');
       if(t!==want) bad.push('the key table is '+t);
       if(GUN_CLASSES.indexOf('marksman')>=0) bad.push('the marksman class is still a key');
       if(gunClassKey('sniper')!==6||gunClassKey('energy')!==7||gunClassKey('rocket')!==8) bad.push('sniper '+gunClassKey('sniper')+' energy '+gunClassKey('energy')+' rocket '+gunClassKey('rocket'));
       P.gunKeys=['pistol','smg','rifle','carbine','lmg','shotgun','marksman','sniper','energy'];
       t=gunKeyTable().join(',');
       if(t!=='pistol,smg,rifle,carbine,lmg,shotgun,sniper,energy,rocket') bad.push('a saved table with the marksman became '+t);
       P.gunKeys=['energy','smg','rifle','carbine','lmg','shotgun','marksman','sniper','pistol'];
       t=gunKeyTable().join(',');
       if(t!=='energy,smg,rifle,carbine,lmg,shotgun,sniper,pistol,rocket') bad.push('a custom saved table became '+t);
       if(slotKeyName(8)!=='0'||slotKeyName(0)!=='1'||slotKeyName(6)!=='7'||slotKeyCode(8)!=='Digit0'||slotKeyCode(7)!=='Digit8') bad.push('the key names are wrong');
       setHot=function(i){ hots.push(i); };
       if(sz) setZoom=function(){ zooms++; };
       ['Digit1','Digit7','Digit8','Digit0','Digit9'].forEach(function(c){ try{ raidKey(c,false,null); }catch(_e){} keys[c]=false; });
       if(hots.join(',')!=='0,6,7,8') bad.push('keys 1 7 8 0 9 chose cells '+hots.join(',')+' (want 0,6,7,8: 0 is the ninth cell, 9 nothing)');
       if(sz){ raidKey('Numpad0',false,null); keys.Numpad0=false; if(zooms!==1) bad.push('zoom to 100 ran '+zooms+' times after Digit0 and Numpad0 (want once, from the numpad)'); }
       return bad.length?bad.join('; '):null;
     } finally {
       setHot=sh; if(sz) setZoom=sz;
       try{ P.gunKeys=svk; }catch(_e2){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
