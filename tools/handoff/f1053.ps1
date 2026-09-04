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
  {v:'10.52',what:'the prompt over a container is drawn as a callout and the items-left count under the search bar as a label, both on screen',
'@ @'
  {v:'10.53',what:'the cheat box ALL COSMETICS switch opens every rack when on, returns exactly the earned racks when off, and touches nothing earned or bought',
   run:function(){
     var bad=[];
     if(typeof cosOwned!=='function'||typeof renderCheat!=='function'||typeof COSMETICS==='undefined') return 'SKIP: no racks or cheat box in this build';
     var P2=__P();
     var keepAll=P2.cosAll, keepBought=JSON.stringify(P2.cosBought||{}), keepRuns=P2.runs, keepExt=P2.ext;
     function owned(){ var n=0; for(var i=0;i<COSMETICS.length;i++) if(cosOwned(COSMETICS[i])) n++; return n; }
     try{
       P2.cosAll=false;
       var base=owned();
       if(base>=COSMETICS.length) return 'SKIP: this profile already owns every rack ('+base+'), so the switch has nothing to open';
       renderCheat();
       var b=document.getElementById('cheatcos');
       if(!b) return 'the cheat box has no ALL COSMETICS switch';
       if(!/OFF$/.test(b.textContent)) bad.push('the switch says "'+b.textContent+'" while the flag is off');
       b.click();
       if(!P2.cosAll) bad.push('one click did not turn the flag on');
       if(!/ON$/.test(b.textContent)) bad.push('after one click the switch says "'+b.textContent+'"');
       var on=owned();
       if(on!==COSMETICS.length) bad.push('with the switch on '+on+' of '+COSMETICS.length+' racks are owned');
       b.click();
       if(P2.cosAll) bad.push('a second click did not turn the flag off');
       if(!/OFF$/.test(b.textContent)) bad.push('after two clicks the switch says "'+b.textContent+'"');
       var off=owned();
       if(off!==base) bad.push('after cutting it off '+off+' racks are owned, not the '+base+' he had earned');
       if(JSON.stringify(P2.cosBought||{})!==keepBought) bad.push('the bought list changed');
       if(P2.runs!==keepRuns||P2.ext!==keepExt) bad.push('the earned counters changed');
     } finally {
       P2.cosAll=keepAll; try{ saveProfile(); }catch(_sv){}
       var m=document.getElementById('cheatmodal'); if(m) m.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.52',what:'the prompt over a container is drawn as a callout and the items-left count under the search bar as a label, both on screen',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
