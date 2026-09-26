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
  {v:'15.92',what:
'@ @'
  {v:'15.93',what:'the gamble history at Wirt prints what the item is worth: with the loot value setting on Lean or Rich, the row of a rolled Data Core under THE GAMBLE prints the same price the stash hover and Sell one use, ival, and not the raw table value, and on Standard it still prints the table value (credits audit finding)',
   run:function(){
     if(typeof renderGamble!=='function'||typeof ival!=='function'||typeof ITEMS==='undefined'||!ITEMS.core||typeof CFG==='undefined'||!CFG||!window.__applyLoaded||!window.__P) return 'SKIP: no Wirt history or item values in this build';
     var gl=document.getElementById('gamblelist');
     if(!gl) return 'SKIP: the roll list of the Wirt panel is not in this page';
     var bad=[], snap=null, keepLoot=CFG.lootMult, raw=ITEMS.core.val;
     if(typeof raw!=='number'||!(raw>0)) return 'SKIP: the Data Core has no table value here';
     // The price printed on the first row under THE GAMBLE after a fresh draw.
     function shown(){ renderGamble(); var v=gl.querySelector('.row .vl'); return v?String(v.textContent||'').replace(/\s+/g,' ').trim():null; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.gambleLog=['core'];
       // CONTROL: on Standard the row prints the table value, the same on either build, so the row is found and read.
       CFG.lootMult=1;
       var std=shown();
       if(std===null) return 'SKIP: THE GAMBLE listed no row for the rolled Data Core here';
       if(std!=='$'+raw.toLocaleString()) return 'SKIP: on Standard the row read "'+std+'" rather than $'+raw.toLocaleString()+', so the row cannot be read here';
       // Lean and Rich, the two settings that scale what everything is worth.
       var arms=[['Lean',0.7],['Rich',1.35]];
       for(var a=0;a<arms.length;a++){
         CFG.lootMult=arms[a][1];
         var price=ival('core');
         // CONTROL: the setting moves the Data Core off its table value, the price the stash hover and Sell one use.
         if(price===raw) return 'SKIP: the loot value setting does not move the Data Core value here';
         var got=shown();
         if(got!=='$'+price.toLocaleString()) bad.push('on '+arms[a][0]+', with the Data Core worth $'+price.toLocaleString()+', its row under THE GAMBLE reads "'+got+'"'+(got==='$'+raw.toLocaleString()?', the raw table value':''));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CFG.lootMult=keepLoot;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderGamble(); }catch(_g){}
       try{ if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
