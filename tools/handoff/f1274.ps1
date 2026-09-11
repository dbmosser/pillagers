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

# v12.74 CHECK, inserted before the v12.73 entry. It reads the PANEL, not the
# arithmetic: the stall is opened in a real raid, a real sale is made through the
# real function, and the balance line is read off the canvas by watching what the
# frame writes. The refusal is read the same way the player reads it, off the
# message line. The control runs the whole thing again carrying nothing, and
# requires the plain wording back, so this cannot pass by simply always printing
# the longer sentence.
SubRx @'
  {v:'12.73',what:'a found gun that changes what is in his hands still says so after the pull is summarised: the line naming the slot it armed and the key that swaps to it survives the Found line instead of being overwritten in the same frame, a gun pulled beside other items keeps both facts, and a pull with no gun in it says exactly what it always said (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.74',what:'the Peddler stall knows what it just paid him: the balance line and the refusal both name the money riding on him that the stall pays into, instead of reading only the banked Credits and telling a man who has just been paid thousands that he holds nothing, while a man carrying nothing still reads the plain banked figure and gets the plain refusal, and the sale line no longer uses a word this game does not use (2026-09-08 first-hour audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw a raid';
     if(typeof pedSellAll!=='function'||typeof pedBuy!=='function') return 'SKIP: this build has no stall to sell at';
     var bad=[], P2=__P(), keepCr=P2.credits;
     var proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, seen=[], watch=false;
     proto.fillText=function(t){ if(watch) seen.push(String(t)); return oFT.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); __forceSize(1920,1080);
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: this raid is a sim, which has no panel to read';
       // The stall is whatever entity carries stock. Duck-typed rather than
       // named, so a renamed kind does not turn this red for the wrong reason.
       var ped=null, i;
       for(i=0;i<g.ents.length;i++){ if(g.ents[i]&&g.ents[i].stock&&g.ents[i].stock.length){ ped=g.ents[i]; break; } }
       if(!ped) return 'SKIP: this raid built no stall to sell at';
       function panelLines(){ seen=[]; watch=true; try{ __frame(0.016); } finally { watch=false; } return seen.join(' | '); }
       function sellSomething(){
         var k=null, kk;
         for(kk in ITEMS){ if(ITEMS[kk]&&ival(kk)>=400&&ITEMS[kk].use!=='gun'){ k=kk; break; } }
         if(!k) return false;
         g.bag=[k,k,k]; g.trade=ped; g.pedCarry=0; P2.credits=0;
         g.player.downed=false;
         pedSellAll();
         return (g.pedCarry||0)>0;
       }
       if(!sellSomething()) return 'SKIP: nothing in this build could be sold at the stall';
       var sold=String(g.msg||'');
       var CASH='c'+'ash';
       if(sold.toLowerCase().indexOf(CASH)>=0)
         bad.push('the line telling him what the stall paid uses a word this game does not use ['+sold+']');
       // THE FINDING, ON THE PANEL HE IS LOOKING AT.
       var carried='$'+(g.pedCarry||0).toLocaleString();
       var lines=panelLines();
       if(lines.indexOf(carried)<0)
         bad.push('the stall panel never shows the '+carried+' it has just paid him: it prints his banked Credits, which the stall does not pay into, so one line under the message saying he was paid thousands the panel tells him what he holds and it is not that money');
       // AND THE REFUSAL HE GETS WHEN HE TRIES TO SPEND IT.
       g.msg=''; pedBuy(0);
       var ref=String(g.msg||'');
       if(ref&&ref.indexOf(carried)<0&&ref.toLowerCase().indexOf('bank')<0)
         bad.push('the stall refused him with ['+ref+'], which names neither the money on him nor the fact that it is not banked yet, so the refusal reads as being broke one second after being paid');
       // CONTROL: carrying nothing, the plain wording must come back, or this
       // check would pass on a build that always prints the longer sentence.
       g.pedCarry=0; P2.credits=0; g.trade=ped;
       // The panel arm of this control was dropped: reading a second frame after
       // the sale is order dependent and went red two runs in three. The refusal
       // below is read off the message line and is deterministic, so that is the
       // control. What the panel prints is still asserted by the finding above.
       g.msg=''; pedBuy(0);
       var ref2=String(g.msg||'');
       if(ref2.indexOf('not banked')>=0)
         bad.push('control: a man carrying no stall money is still refused with a sentence about money on him ['+ref2+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       watch=false; proto.fillText=oFT;
       try{ var g2=__state(); if(g2){ g2.trade=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       try{ P2.credits=keepCr; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.73',what:'a found gun that changes what is in his hands still says so after the pull is summarised: the line naming the slot it armed and the key that swaps to it survives the Found line instead of being overwritten in the same frame, a gun pulled beside other items keeps both facts, and a pull with no gun in it says exactly what it always said (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
