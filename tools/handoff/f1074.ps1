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
  {v:'10.73',what:'the title screen uses a wide monitor instead of painting a narrow column down the middle, and its prose keeps a readable measure',
'@ @'
  {v:'10.74',what:'the two buttons at the end of a raid stay inside the card, with a full bag and with an empty one, whether the ledger is scrolled to the top or the bottom',
   run:function(){
     var bad=[];
     if(!(window.__deploy&&window.__endRaid&&window.__P&&window.__state)) return 'SKIP: this build cannot deploy and die';
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var oc=document.getElementById('outcome');
     if(!oc) return 'SKIP: this build has no run report';
     var win=oc.querySelector('.ocwin');
     if(!win) return 'SKIP: the run report has no window to measure';
     var P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),weapons:(P2.weapons||[]).slice(),
               eq:P2.equipped,sec:P2.equippedSec,safe:P2.safe,hot:P2.hotAssign,free:P2.freeKit,auto:P2.autoExport};
     function seat(bag,guns,extra){
       if(window.__cleanProfile) __cleanProfile();
       __pinDPR(1); __forceSize(1920,1080);
       P2.freeKit=0; P2.hotAssign={}; P2.autoExport=false; P2.safe=null;
       P2.stash=bag.slice(); P2.kit=bag.slice();
       P2.weapons=guns.slice(); P2.equipped=guns[0]||'fists'; P2.equippedSec=guns[1]||'none';
       try{ saveProfile(); }catch(_s){}
       __deploy({kit:bag.slice(),safe:null,mapIx:0,seed:4242});
       var g=__state();
       for(var i=0;i<extra;i++) g.bag.push('scrap');
       __endRaid('dead');
       if(typeof applyMenuZoom==='function') applyMenuZoom();
       return win.getBoundingClientRect();
     }
     // Both buttons, measured against the card they live in rather than against
     // the window: the card is the thing that scrolls.
     function look(where){
       var wr=win.getBoundingClientRect(), out={where:where,scrolls:win.scrollHeight>win.clientHeight+2,off:[]};
       ['oc_btn','oc_copy'].forEach(function(id){
         var b=document.getElementById(id);
         if(!b){ out.off.push(id+' is not on the card at all'); return; }
         var br=b.getBoundingClientRect();
         if(br.height<=0) out.off.push(id+' has no height');
         else if(br.bottom>wr.bottom+1) out.off.push(id+' sits '+Math.round(br.bottom-wr.bottom)+' pixels below the bottom of the card');
         else if(br.top<wr.top-1) out.off.push(id+' sits '+Math.round(wr.top-br.top)+' pixels above the top of the card');
       });
       return out;
     }
     try{
       // 1. A FULL BAG, which is the case that broke: ten packed, eight more
       //    picked up, dying with two of his own guns. Measured on v10.73 the
       //    card ran 945 pixels of content in an 826 pixel box and both buttons
       //    were off the end.
       var FULL=['medkit','medkit','plate','plate','servo','scrap','wire','bandage','smoke','frag'];
       seat(FULL,['smg','carbine'],8);
       var top=look('a full bag, scrolled to the top');
       if(!top.scrolls) bad.push('control: a full bag did not make the card scroll, so this check is not testing what it says');
       win.scrollTop=0;
       top=look('a full bag, scrolled to the top');
       if(top.off.length) bad.push('with a full bag, '+top.off.join(' and '));
       // 2. AND AT THE BOTTOM, where they naturally sit, so pinning them has not
       //    pushed them past the end instead.
       win.scrollTop=win.scrollHeight;
       var bot=look('a full bag, scrolled to the bottom');
       if(bot.off.length) bad.push('scrolled to the bottom with a full bag, '+bot.off.join(' and '));
       // 3. A SHORT CARD must be untouched: one item, no guns, nothing to scroll.
       seat(['medkit'],[],0);
       var small=look('one item');
       if(small.scrolls) bad.push('control: a one item card scrolls, so the short case cannot be told from the long one');
       if(small.off.length) bad.push('on a card with one item, '+small.off.join(' and '));
     } finally {
       oc.classList.remove('on');
       win.scrollTop=0;
       P2.stash=keep.stash; P2.kit=keep.kit; P2.weapons=keep.weapons; P2.equipped=keep.eq;
       P2.equippedSec=keep.sec; P2.safe=keep.safe; P2.hotAssign=keep.hot; P2.freeKit=keep.free; P2.autoExport=keep.auto;
       try{ saveProfile(); }catch(_s2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.73',what:'the title screen uses a wide monitor instead of painting a narrow column down the middle, and its prose keeps a readable measure',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
