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

if ($s.Contains("  {v:'22.65',what:")) { throw "check 22.65 is in the fixture already" }

SubRx @'
  {v:'22.64',what:
'@ @'
  {v:'22.65',what:'the backpack cue under the gun card follows key changes: with the backpack moved from B to K it reads K / I  BACKPACK, and with the keys unmoved B / I  BACKPACK as before',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof keysOf!=='function') return 'SKIP: no raid HUD or key table in this fixture';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var bad=[], seen=[], oFT=ctx.fillText, km, padOnK=(typeof PAD!=='undefined'&&PAD)?PAD.on:false, cue;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function draw(){ seen.length=0; ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); }; try{ drawHUD(); }catch(_h){ seen.push('THREW '+_h.message); } finally{ unspy(); }
       for(var j=0;j<seen.length;j++) if(/ \/ .*  BACKPACK$/.test(seen[j])) return seen[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       km=P.keymap;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       G.bagOpen=false; G.mapOpen=false; if(typeof PAD!=='undefined'&&PAD) PAD.on=false;
       P.keymap={};
       cue=draw();
       if(cue===null) return 'SKIP: staging: the gun card drew no backpack cue';
       if(cue!==['B','/','I'].join(' ')+'  BACKPACK') bad.push('with the keys unmoved the cue reads '+JSON.stringify(cue));
       P.keymap={KeyB:'KeyK'};
       if(keysOf('KeyB')!=='KeyK') return 'SKIP: staging: the key table did not take the move';
       cue=draw();
       if(cue!=='K / I  BACKPACK') bad.push('with the backpack moved to K the cue reads '+JSON.stringify(cue));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       unspy();
       try{ P.keymap=km; if(km===undefined) delete P.keymap; }catch(_k){}
       try{ if(typeof PAD!=='undefined'&&PAD) PAD.on=padOnK; }catch(_p){}
       try{ __endRaid('abandon'); }catch(_c){}
       keys={}; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
