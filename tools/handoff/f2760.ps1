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

if ($s.Contains("  {v:'27.60',what:")) { throw "check 27.60 is in the fixture already" }

SubRx @'
  {v:'27.59',what:
'@ @'
  {v:'27.60',what:'cloud-menus-f1-list-moved-keys: the F1 full controls list names HOLD Q, CAPS, NUM + -, - = and 0 as set after CHANGE KEYS moves them (v25.71, v26.52); with no keys moved every row reads exactly its default text',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof legendKeys!=='function'||typeof LEGEND==='undefined'||typeof keysBind!=='function'||typeof keysOf!=='function'||typeof drawLegend!=='function') return 'SKIP: no key map here';
     var bad=[], g=null, kKM=JSON.stringify(P.keymap||{}), hadKM=Object.prototype.hasOwnProperty.call(P,'keymap'), kKV=P.keymapV, kNote=(typeof KEYS==='object'&&KEYS)?KEYS.note:null,
         kPON=(typeof PAD==='object'&&PAD)?PAD.on:false, oF=ctx.fillText, kLO, want, got, i, j, rows=[], tx;
     function drawn(){ tx=[]; g.legendOn=2; ctx.fillText=function(s){ tx.push(String(s)); return oF.apply(this,arguments); }; try{ drawLegend(1); }finally{ ctx.fillText=oF; } return tx; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.player.iv=99; g.bagOpen=false; g.mapOpen=false; kLO=g.legendOn; if(typeof PAD==='object'&&PAD) PAD.on=false;
       P.keymap={}; KEYS.inv=null; keysInv();
       for(i=0;i<LEGEND.length;i++) for(j=0;j<LEGEND[i][1].length;j++) rows.push(LEGEND[i][1][j][0]);
       for(i=0;i<rows.length;i++){ got=legendKeys(rows[i]); if(got!==rows[i]) bad.push('no keys moved: the row '+rows[i]+' reads '+got); }
       tx=drawn(); ['HOLD Q','CAPS','NUM + -','- =','0'].forEach(function(t){ if(tx.indexOf(t)<0) bad.push('no keys moved: the drawn list has no '+t); });
       if(!keysBind('KeyQ','KeyK')||!keysBind('CapsLock','KeyL')||!keysBind('Equal','KeyJ')||!keysBind('NumpadAdd','KeyU')||!keysBind('Digit0','KeyY')) bad.push('control: a key would not move ('+JSON.stringify(P.keymap)+')');
       if(legendKeys('Q')!=='K') bad.push('control: the Q row reads '+legendKeys('Q'));
       want={'HOLD Q':'HOLD K','CAPS':'L','- =':'- / J','NUM + -':'U / NUM -','0':'Y'};
       tx=drawn();
       for(i in want){ if(rows.indexOf(i)<0){ bad.push('the full list has no row '+i); continue; } if(tx.indexOf(want[i])<0) bad.push('moved: the drawn row '+i+' does not read '+want[i]+' (reads '+legendKeys(i)+')'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       ctx.fillText=oF;
       try{ if(hadKM) P.keymap=JSON.parse(kKM); else delete P.keymap; if(kKV===undefined) delete P.keymapV; else P.keymapV=kKV; KEYS.note=kNote; KEYS.inv=null; keysInv(); if(typeof keysLegendApply==='function') keysLegendApply(); saveProfile(); }catch(_k){}
       try{ if(typeof PAD==='object'&&PAD) PAD.on=kPON; }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.legendOn=kLO; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
