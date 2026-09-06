$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.48 HOOKS: the real item context-menu rows, and two item-table reads so the
# check can pick a gun item the profile does not already own.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__itemMenuRows=function(key,ctx,count){ return itemMenuRows(key,ctx,count); };
window.__itemGk=function(k){ var it=(typeof ITEMS!=='undefined')&&ITEMS[k]; return it?(it.gk||null):null; };
'@

# v11.48 CHECK, inserted before the v11.47 entry.
SubRx @'
  {v:'11.47',what:'a crash caught before the profile is read never saves over the real save: it goes to its own key, and a crash after the read still lands in P.crashes',
'@ @'
  {v:'11.48',what:'right-click Equip as your gun on a stash gun moves it into the armoury and equips it, instead of removing it from the stash and then throwing so the gun is lost',
   run:function(){
     if(!(window.__itemMenuRows&&window.__itemGk&&window.__P)) return 'SKIP: this fixture cannot open the item menu';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P=window.__P(), bad=[];
     // A gun item the profile does not own yet, so the row takes the equip path
     // and not the "already yours" branch.
     var cands=['gun_smg','gun_carbine','gun_rifle','gun_shotgun','gun_scattergun','gun_pistol'], K=null, gk=null;
     for(var c=0;c<cands.length;c++){ var g=window.__itemGk(cands[c]); if(g){ K=cands[c]; gk=g; break; } }
     if(!K) return 'SKIP: no gun item in the item table to stage';
     P.stash=[K]; P.kit=[]; P.hotAssign={};
     P.weapons=(P.weapons||[]).filter(function(w){ return w!==gk; });
     var rows=window.__itemMenuRows(K,'stash',1)||[], row=null;
     for(var r=0;r<rows.length;r++){ if(/gun/i.test(String(rows[r].label||''))&&typeof rows[r].act==='function'){ row=rows[r]; break; } }
     if(!row) return 'SKIP: the stash menu offered no equip-as-gun row for '+K;
     var threw=null; try{ row.act(); }catch(e){ threw=String(e&&e.message||e); }
     var inStash=(P.stash||[]).indexOf(K)>=0, inArm=(P.weapons||[]).indexOf(gk)>=0;
     // THE FIX: the gun reaches the armoury and is equipped; it is never in neither place.
     if(!inStash&&!inArm) bad.push('the gun '+K+' is in neither the stash nor the armoury after Equip: it was lost'+(threw?(' (the row threw: '+threw.slice(0,80)+')'):''));
     else if(!inArm) bad.push('the gun stayed in the stash and never reached the armoury'+(threw?(' (the row threw: '+threw.slice(0,80)+')'):''));
     if(inArm&&P.equipped!==gk) bad.push('control: the gun reached the armoury but was not equipped (equipped is '+P.equipped+')');
     __cleanProfile(); __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.47',what:'a crash caught before the profile is read never saves over the real save: it goes to its own key, and a crash after the read still lands in P.crashes',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
