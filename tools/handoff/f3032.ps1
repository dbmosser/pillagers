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

if ($s.Contains("  {v:'30.32',what:")) { throw "check 30.32 is in the fixture already" }

SubRx @'
  {v:'30.31',what:
'@ @'
  {v:'30.32',what:'the 2 player demo asks once about easy mode after a second death with no extraction, keys Y/N and pad A/B answer it, yes takes a third off damage (his answer Q66)',
   run:function(){
     if(typeof easyAskMaybe!=='function'||typeof easyKey!=='function'||typeof easyPad!=='function'||typeof easyDmgMul!=='function') return 'no easy mode question (easyAskMaybe, easyKey, easyPad or easyDmgMul missing)';
     var bad=[], oSay=say, sv={}, k, keys=['on','solo','deaths','ext','easy','easyAsk','easyAsked'], gA, ev=function(code){ return {type:'keydown',code:code,repeat:false,preventDefault:function(){},stopImmediatePropagation:function(){}}; };
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: no raid';
       say=function(){};
       for(k=0;k<keys.length;k++) sv[keys[k]]=ARCADE[keys[k]];
       gA=G.arcade;
       ARCADE.on=1; ARCADE.solo=0; ARCADE.easy=0; ARCADE.easyAsk=null; ARCADE.easyAsked=0; ARCADE.ext=0; G.arcade=1;
       ARCADE.deaths=1;
       if(easyAskMaybe('dead')) bad.push('asked after one death');
       ARCADE.deaths=2; ARCADE.ext=1;
       if(easyAskMaybe('dead')) bad.push('asked after an extraction');
       ARCADE.ext=0; ARCADE.solo=1;
       if(easyAskMaybe('dead')) bad.push('asked in the 1 player demo');
       ARCADE.solo=0;
       if(!easyAskMaybe('dead')||!easyLive()) bad.push('not asked after the second death');
       if(easyAskMaybe('dead')) bad.push('asked twice');
       if(easyDmgMul()!==1) bad.push('damage changed before yes');
       if(easyKey(ev('KeyW'))||!ARCADE.easyAsk) bad.push('a movement key answered it');
       if(!easyKey(ev('KeyN'))||ARCADE.easyAsk||ARCADE.easy) bad.push('N did not answer no');
       if(easyAskMaybe('dead')) bad.push('asked again after a no');
       ARCADE.easyAsked=0; easyAskMaybe('dead');
       if(!easyKey(ev('KeyY'))||ARCADE.easyAsk||!ARCADE.easy) bad.push('Y did not turn easy mode on');
       if(Math.abs(easyDmgMul()-0.7)>1e-9) bad.push('damage multiplier after yes is '+easyDmgMul());
       ARCADE.easy=0; ARCADE.easyAsked=0; easyAskMaybe('dead');
       if(!easyPad([0])||ARCADE.easyAsk||!ARCADE.easy) bad.push('pad A did not turn easy mode on');
       ARCADE.easy=0; ARCADE.easyAsked=0; easyAskMaybe('dead');
       if(!easyPad([1])||ARCADE.easyAsk||ARCADE.easy) bad.push('pad B did not answer no');
       if(!/easyAskMaybe/.test(String(arcadeRespawn))) bad.push('arcadeRespawn does not ask');
       if(!/easyKey/.test(String(arcadeKeyAtt))) bad.push('arcadeKeyAtt does not pass keys');
       if(!/easyHud/.test(String(arcadeHud))) bad.push('arcadeHud does not draw the card');
       if(!/easyDmgMul/.test(String(damagePlayer))) bad.push('damagePlayer ignores easy mode');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay;
       try{ for(k=0;k<keys.length;k++) ARCADE[keys[k]]=sv[keys[k]]; G.arcade=gA; }catch(_r){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
