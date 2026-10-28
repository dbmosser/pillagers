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

if ($s.Contains("  {v:'36.10',what:")) { throw "check 36.10 is in the fixture already" }

SubRx @'
  {v:'36.09',what:
'@ @'
  {v:'36.10',what:'the 15 audited sentence callouts use short text without periods; revive limit and packed core detail remain',
   run:function(){
     var bad=[], realSay=say, g, p, said=[];
     function source(fn,text,label){ if(String(fn).indexOf(text)<0) bad.push(label+' still has the old wording'); }
     function has(m,sub){ return said.some(function(x){return x.m===m&&(sub===undefined||x.sub===sub);}); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       source(bagHeldGun,"say('nothing to pick up');",'empty hands');
       source(selfRevive,"say('self-revive spent','info',{sub:'one per raid'});",'spent revive');
       source(selfRevive,"sub:'back on your feet'",'revive success');
       source(typeof _tpl==='function'?_tpl:updatePlayer,"sub:'seal payout dropped'",'seal payout');
       source(tickHot,"sub:'check map'",'hot ground');
       source(netWorldTake,"sub:'check map'",'shared hot ground');
       source(buildRack,"say('mainframe wall full');",'rack limit');
       source(buildRack,"say('not enough parts: '+rackCostLine());",'rack parts');
       source(importGhost,"say('name required');",'friend name');
       source(importGhost,"say('invalid pillagers run report');",'friend report');
       source(slotCore,"say('core already slotted: next raid');",'core already slotted');
       source(slotCore,"say('no data core: rare containers / elite pillagers');",'no core');
       source(slotCore,"say('core slotted: next raid intel'+(_cp?' / '+_cp+' packed data core used':''));",'core success');
       source(netAidHold,"sub:'bandage, medkit or armour plate'",'heal choices');
       source(renderSettingsInner,"say('no previous profile');",'previous profile');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'staging: no live raid';
       p=g.player; say=function(m,k,o){said.push({m:String(m),sub:o&&o.sub||''});};
       p.downed=true; p.revived=false; selfRevive();
       if(p.downed||!p.revived||!has('SELF-REVIVE USED','back on your feet')) bad.push('revive success lost its callout');
       p.downed=true; said=[];
       if(selfRevive()!==false||!has('self-revive spent','one per raid')) bad.push('spent revive lost its limit detail');
       p.downed=false;
       P.intel=1; said=[]; slotCore();
       if(!has('core already slotted: next raid')) bad.push('slotted core guard wording');
       P.intel=0; P.stash=[]; said=[]; slotCore();
       if(!has('no data core: rare containers / elite pillagers')) bad.push('missing core lost its source detail');
       P.freeKit=0; P.kitSaved=null; P.stash=['core']; P.kit=['core']; P.hotAssign={}; said=[]; slotCore();
       if(!P.intel||P.stash.indexOf('core')>=0||P.kit.indexOf('core')>=0||!has('core slotted: next raid intel / 1 packed data core used')) bad.push('packed core callout lost next raid intel or the spent packed item');
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{say=realSay; try{if(g&&g.player)g.player.downed=false; __endRaid('abandon');}catch(e){} __topClear(); __cleanProfile();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
