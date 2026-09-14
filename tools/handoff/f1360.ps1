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
  {v:'13.59',what:
'@ @'
  {v:'13.60',what:'buying the Wirt lot marks as bought the window the card was drawn for: a card drawn in one window and bought after the clock moved to the next stamps the window drawn, so the next lot is not locked out, and with no change of window the stamp is that window (Undercroft audit 2026-09-14, finding 2)',
   run:function(){
     if(!window.__P||typeof renderWirtLot!=='function'||typeof wirtLotHour!=='function'||typeof wirtLotKey!=='function') return 'SKIP: no Wirt lot in this build';
     if(!document.getElementById('wirtlot')) return 'SKIP: the Wirt lot card is not in this page';
     var P2=__P(), keep={cr:P2.credits,st:(P2.stash||[]).slice(),wb:P2.wirtLotBought,gl:(P2.gambleLog||[]).slice()}, keepH=wirtLotHour, keepK=wirtLotKey;
     var bad=[], LOT=wirtLotKey(), H1=987654, H2=987655;
     function buy(drawHr,clickHr){
       P2.credits=WIRT_LOT_PRICE*3; P2.wirtLotBought=null;
       wirtLotKey=function(){ return LOT; };
       wirtLotHour=function(){ return drawHr; };
       renderWirtLot();
       var b=document.getElementById('wirtlotbtn');
       if(!b) return null;
       wirtLotHour=function(){ return clickHr; };
       b.disabled=false; b.onclick();
       return P2.wirtLotBought;
     }
     try{
       __topClear(); __cleanProfile();
       if(!LOT||!LOT.length||!ITEMS[LOT[0]]) return 'SKIP: the counter has no lot to buy';
       var same=buy(H1,H1);
       if(same===null) return 'SKIP: the lot card drew no Buy button';
       // CONTROL: no change of window, the stamp is that window.
       if(same!==H1) bad.push('control: a lot bought in the window it was drawn stamped '+same+', not '+H1);
       var moved=buy(H1,H2);
       if(moved===H2) bad.push('a lot drawn in one window and bought after the clock moved on stamped the NEXT window as bought, locking him out of a lot he never saw');
       else if(moved!==H1) bad.push('a lot bought after the window moved stamped '+moved+', neither window');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ wirtLotHour=keepH; wirtLotKey=keepK; }catch(_h){}
       try{ P2.credits=keep.cr; P2.stash=keep.st; P2.wirtLotBought=keep.wb; P2.gambleLog=keep.gl; saveProfile(); }catch(_r){}
       try{ renderWirtLot(); }catch(_w){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
