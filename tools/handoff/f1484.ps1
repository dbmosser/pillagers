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
  {v:'14.83',what:
'@ @'
  {v:'14.84',what:'a heal on a belt key does not take Medical away from the other heals: with a Medkit on key 8 and a Bandage carried, the belt still has a Medical cell, and with only the Medkit carried it does not (belt audit finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof hotbarSlots!=='function'||!ITEMS.medkit||!ITEMS.bandage) return 'SKIP: no belt in this build';
     var bad=[], g0=null;
     function medical(g){ return (hotbarSlots()||[]).filter(function(c){ return c&&c.kind==='heal'&&!c.assigned; }).length; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g; g.hotAuto={};
       // CONTROL: with only the Medkit carried and on key 8, Medical is blanked, and key 8 is his Medkit key.
       g.hotAssign={7:'medkit'}; g.bag=['medkit'];
       var sl=hotbarSlots();
       if(!sl[7]||!sl[7].assigned||sl[7].itemKey!=='medkit') return 'SKIP: key 8 is not his Medkit key here';
       if(medical(g)) return 'SKIP: Medical still shows with every heal carried on a key';
       g.bag=['medkit','bandage'];
       if(!medical(g)) bad.push('with a Medkit on key 8 and a Bandage carried the belt has no Medical cell, so the Bandage cannot be used');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0&&!g0.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
