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

# v11.70 CHECK, inserted before the v11.68 entry.
SubRx @'
  {v:'11.68',what:'the in-raid notoriety banner at two or more names what notoriety costs rather than claiming the Peddler has shut his stall, which never shuts',
'@ @'
  {v:'11.70',what:'with Other pillagers set to None the extraction-heat row still reads its own word rather than CUSTOM, the waves are off, and they come back when pillagers return to Standard',
   run:function(){
     if(!window.__P||typeof applyGameOpts!=='function'||typeof gameOptLive!=='function'||typeof gameOptIx!=='function') return 'SKIP: no settings rows in this build';
     var bad=[], prof=__P(), keepGO=JSON.stringify(prof.gameOpts===undefined?null:prof.gameOpts), keepT=JSON.stringify(prof.tuned||{}), keepRW=CFG.raiderWaves, keepNR=CFG.nRaider;
     try{
       prof.gameOpts={}; prof.tuned={};
       prof.gameOpts.raiders=3;              // None
       applyGameOpts();
       if(CFG.raiderWaves!==0) bad.push('control: with pillagers None the waves are still on ('+CFG.raiderWaves+')');
       var lv=gameOptLive('ext');
       if(lv<0) bad.push('with pillagers None the extraction-heat row reads CUSTOM, no option matching the live dials, though nothing about the ring was changed');
       else if(lv!==gameOptIx('ext')) bad.push('the extraction-heat row reads option '+lv+' and not the chosen '+gameOptIx('ext'));
       if(gameOptLive('raiders')!==3) bad.push('control: the pillagers row does not read None after being set to it ('+gameOptLive('raiders')+')');
       prof.gameOpts.raiders=1;              // back to Standard
       applyGameOpts();
       if(CFG.raiderWaves!==1) bad.push('control: with pillagers back on Standard the waves did not return ('+CFG.raiderWaves+')');
       if(gameOptLive('raiders')!==1) bad.push('control: the pillagers row does not read Standard after being set to it ('+gameOptLive('raiders')+')');
       if(gameOptLive('ext')<0) bad.push('control: the extraction-heat row reads CUSTOM with pillagers on Standard');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var go=JSON.parse(keepGO); if(go===null) delete prof.gameOpts; else prof.gameOpts=go; prof.tuned=JSON.parse(keepT); applyGameOpts(); CFG.raiderWaves=keepRW; CFG.nRaider=keepNR; saveProfile(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.68',what:'the in-raid notoriety banner at two or more names what notoriety costs rather than claiming the Peddler has shut his stall, which never shuts',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
