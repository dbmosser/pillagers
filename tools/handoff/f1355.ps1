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
  {v:'13.54',what:
'@ @'
  {v:'13.55',what:'an extract-carrying item contract counts only what the run found: two of the item carried up from the stash do not complete it, while two of the item found in the raid still do (end-of-raid audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof contractExtract!=='function') return 'SKIP: no contract extraction in this build';
     var ITEM='optic';
     if(!ITEMS[ITEM]) return 'SKIP: no Optic item in this build';
     var bad=[], P2=__P(), keepC=(P2.contracts||[]).slice();
     function card(){ return {type:'exItem',item:ITEM,n:2,prog:0,reward:250,desc:'item card staged by check 13.55'}; }
     function run(carriedUp){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       var c=card(); P2.contracts=[c];
       g.bag=[ITEM,ITEM];
       g.carriedKit=carriedUp?[ITEM,ITEM]:[];
       g.carriedIn=carriedUp?ival(ITEM)*2:0;
       contractExtract(g.bag,ival(ITEM)*2);
       return c.prog;
     }
     try{
       var up=run(true);
       if(up===null) return 'SKIP: no live raid to extract from';
       if(up>=2) bad.push('two Optics carried up from his own stash and walked straight back out completed an extract-carrying card for two, which then pays on every refill');
       // CONTROL: found in the raid, the card completes.
       var found=run(false);
       if(found<2) bad.push('control: two Optics found in the raid no longer complete a card for two, so this build broke the card rather than what it counts');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.contracts=keepC; saveProfile(); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
