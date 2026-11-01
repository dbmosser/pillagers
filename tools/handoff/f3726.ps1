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

if ($s.Contains("  {v:'37.26',what:")) { throw "check 37.26 is in the fixture already" }

SubRx @'
  {v:'37.25',what:
'@ @'
  {v:'37.26',what:'cw-m1bonusgap: the extraction bonus line on the extracted card is its own block with at least 20px under it, so it no longer sits against the stat strip (critic on screen 38)',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     var saved=P, oldStore=storeSet, oldSave=saveProfile, bad=[], g, el, cs, t;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.merc=''; P.terms=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) throw new Error('no live raid');
       g.bag=['core','titan']; g.carriedIn=0; g.carriedKit=[]; g.issuedBandages=0; g.player.downed=false; g.player.hp=100;
       __endRaid('extract');
       t=String((document.getElementById('oc_manifest')||{}).textContent||'').toLowerCase();
       if(t.indexOf('extraction bonus')<0) bad.push('control: the extracted card has no extraction bonus line');
       el=document.querySelector('#oc_manifest .ocbonus');
       if(!el) bad.push('the bonus line is not its own .ocbonus block');
       else { cs=getComputedStyle(el); if(cs.display==='inline'||!(parseFloat(cs.marginBottom)>=20)) bad.push('the bonus line is '+cs.display+' with '+cs.marginBottom+' under it, not a block with 20px or more'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }catch(_pr){}
       try{ g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
