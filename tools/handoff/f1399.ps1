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
  {v:'13.98',what:
'@ @'
  {v:'13.99',what:'a belt key does not point at something that stayed behind: going up with two Bandages while a Medkit is still bound to a key drops that binding in the raid and leaves a Medical cell holding the Bandages, while a bound Bandage that did come up keeps its key (deploy and loadout audit 2026-09-15, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof hotbarSlots!=='function'||!ITEMS.medkit||!ITEMS.bandage) return 'SKIP: no belt or medical items in this build';
     var bad=[], P2=__P(), keep=JSON.stringify(P2.hotAssign||{});
     function go(bound){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.hotAssign={}; P2.hotAssign[7]=bound;
       __deploy({kit:['bandage','bandage'],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var heal=0, sl=hotbarSlots();
       for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='heal'&&(sl[i].count||0)>=2) heal++;
       var r={kept:!!(g.hotAssign&&g.hotAssign[7]===bound), heal:heal, len:sl.length};
       if(!g.over) __endRaid('abandon');
       return r;
     }
     try{
       // CONTROL: a bound Bandage that came up keeps its key in the raid.
       var C=go('bandage');
       if(C===null) return 'SKIP: no live raid';
       if(C.len<=7) return 'SKIP: the belt has no key 8 in this build';
       if(!C.kept) return 'SKIP: the belt plan did not reach the raid, so nothing here can be measured';
       // THE FINDING: a Medkit still bound, and none came up.
       var A=go('medkit');
       if(A&&A.kept) bad.push('key 8 in the raid still points at a Medkit that stayed behind');
       if(A&&!A.heal) bad.push('with a Medkit bound that did not come up, the belt has no Medical cell for the two Bandages that did');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.hotAssign=JSON.parse(keep); saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
