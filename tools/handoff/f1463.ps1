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

SubRx @'
  {v:'14.62',what:
'@ @'
  {v:'14.63',what:'a second copy of the gun in his hands shows in the backpack: with a belt key bound to the gun he holds, a copy of that gun in the backpack is a backpack stack, while a Medkit bound to a key is still claimed by it (backpack audit finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof bagStacks!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no backpack stacks in this build';
     var bad=[], g0=null, keepWep=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; keepWep=p.wep;
       var gk=null; for(var k in WEAPONS){ if(k!=='fists'&&ITEMS['gun_'+k]&&WEAPONS[k]&&WEAPONS[k].id===k){ gk=k; break; } }
       if(!gk) return 'SKIP: no gun with an item form';
       var has=function(key){ return bagStacks().some(function(st){ return st.key===key; }); };
       // CONTROL: a Medkit bound to a key is claimed by it and not shown as a stack.
       g.bag=['medkit']; g.hotAssign={4:'medkit'};
       if(has('medkit')) return 'SKIP: a Medkit bound to a belt key was still shown as a backpack stack, so a claim cannot be seen here';
       // THE FIX: the gun in his hands is bound to key 5, and a second copy of it is in the backpack.
       p.wep=WEAPONS[gk]; g.bag=['gun_'+gk]; g.hotAssign={4:'gun_'+gk};
       if(!has('gun_'+gk)) bad.push('with the '+gk+' in his hands on belt key 5, a second '+gk+' in the backpack was claimed by that key and shown nowhere');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ if(g0.player&&keepWep) g0.player.wep=keepWep; g0.bag=[]; g0.hotAssign={}; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
