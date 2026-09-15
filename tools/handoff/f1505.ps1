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
  {v:'15.04',what:
'@ @'
  {v:'15.05',what:'the Gamble button reads its price with a thousands separator, like every other price in the Wirt panel: with the money line reading 2,500 per roll, the button reads Gamble 2,500 and not Gamble 2500 (wirt audit finding)',
   run:function(){
     if(typeof renderGamble!=='function'||typeof GAMBLE_PRICE!=='number'||!window.__applyLoaded||!window.__P) return 'SKIP: no Wirt counter in this build';
     var gb=document.getElementById('gamblebtn'), wg=document.getElementById('wallet_gamble');
     if(!gb||!wg) return 'SKIP: the Gamble button or the money line of the Wirt panel is not in this page';
     // CONTROL: this browser groups the digits, or both builds print the same thing.
     if(GAMBLE_PRICE.toLocaleString()===String(GAMBLE_PRICE)) return 'SKIP: this browser prints '+GAMBLE_PRICE+' with no thousands separator, so the two builds read the same';
     var fmt='$'+GAMBLE_PRICE.toLocaleString();
     var bad=[], snap=null, keepB=gb.textContent, keepW=wg.textContent;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       gb.textContent=''; wg.textContent='';
       renderGamble();
       // CONTROL: the draw reached the panel: the money line prints the price with its separator and the button was written.
       if(String(wg.textContent).indexOf(fmt+' per roll')<0) return 'SKIP: the money line of the Wirt panel did not read '+fmt+' per roll here: '+String(wg.textContent).slice(0,80);
       if(!gb.textContent) return 'SKIP: the draw did not write the Gamble button here';
       var t=String(gb.textContent).replace(/\s+/g,' ').trim();
       if(t.indexOf(fmt)<0) bad.push('the Gamble button reads "'+t+'" while the money line above it reads '+fmt+' per roll');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ gb.textContent=keepB; wg.textContent=keepW; }catch(_x){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.04',what:
'@
SubRx @'
     if(gb&&!/2500/.test(gb.textContent)) bad.push('the gamble button reads "'+gb.textContent+'" and the price is 2500');
'@ @'
     // v15.05: the button prints its price with a thousands separator (Gamble $2,500), which /2500/ does not match.
     if(gb&&!/2\D?500/.test(gb.textContent)) bad.push('the gamble button reads "'+gb.textContent+'" and the price is 2,500');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
