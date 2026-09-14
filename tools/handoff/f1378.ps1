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
  {v:'13.77',what:
'@ @'
  {v:'13.78',what:'the EXTRACTED card counts only what was secured: extracting with the two issued Bandages and one find prints 1 item secured, while the same backpack with nothing issued prints 3 (downed and extraction audit 2026-09-14, finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(!document.getElementById('oc_manifest')||!ITEMS.bandage) return 'SKIP: no run report manifest or Bandage in this page';
     var bad=[], X=null, k, P2=__P(), keepSt=(P2.stash||[]).slice();
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to carry beside the Bandages';
     var SEC=' secured for ';
     function run(issued){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       g.ents.length=0; g.player.downed=false; g.pedCarry=0; g.pedSold=0; g.hotAssign={};
       g.bag=['bandage','bandage',X]; g.issuedBandages=issued; g.bandSeen=undefined;
       __endRaid('extract');
       return String(document.getElementById('oc_manifest').textContent||'');
     }
     try{
       // THE FINDING: the issued pair and one find.
       var A=run(2);
       if(A===null) return 'SKIP: no live raid to extract from';
       if(A.indexOf(SEC)<0) return 'SKIP: the card printed no secured line to read';
       if(A.indexOf('1 item'+SEC)<0) bad.push('with the 2 issued Bandages handed back and 1 find banked, the card read: '+(A.match(/\d+ items?[^.]*secured for \$[\d,]+/)||['?'])[0]);
       // CONTROL: nothing issued, all three are secured.
       var B=run(0);
       if(B!==null&&B.indexOf('3 items'+SEC)<0) bad.push('control: with nothing issued the card did not read 3 items secured, so this check cannot read the count');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.stash=keepSt; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
