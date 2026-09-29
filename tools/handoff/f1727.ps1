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

if ($s.Contains("  {v:'17.27',what:")) { throw "check 17.27 is in the fixture already" }

SubRx @'
  {v:'17.26',what:
'@ @'
  {v:'17.27',what:'with two controllers and no picks each window keeps the controller it plays: when the player 2 controller drops player 1 keeps his and player 2 is handed none, a controller that comes back to a lower slot goes to the side with none and swaps nothing, and the window that takes a handed-over state keeps the same sides when it comes to the front; a fresh pair still sets them in his order, player 2 on the first controller',
   run:function(){
     if(typeof NET==='undefined'||!NET||typeof netPadFor!=='function'||typeof netPadTick!=='function'||typeof netSameOnMsg!=='function'||typeof netPadNow!=='function'||typeof NET.padIx!=='number') return 'SKIP: this build has no same machine controllers';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     var bad=[], keep={}, ks=[], k, q, r, h, msg=null;
     var ch={posted:[],onmessage:null,postMessage:function(m){ this.posted.push(m); },close:function(){}};
     function pd(ix){ var bts=[], j; for(j=0;j<17;j++) bts.push({pressed:j===ix,value:(j===ix)?1:0,touched:j===ix}); return {connected:true,id:'probe pad '+ix,index:ix,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts}; }
     function handed(){ var o=[], j; for(j=0;j<ch.posted.length;j++) if(ch.posted[j]&&ch.posted[j].t==='pad') o.push(ch.posted[j]); return o; }
     function side(same,pair){ NET.same=same; NET.pair=pair; NET.mode='coop'; NET.bc=ch; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null; NET.padTs={}; }
     function tick(gps){ ch.posted=[]; NET.padLiveAt=netPadNow(); return netPadTick(gps); }
     function nm(g){ return g?('pad '+g.index):'no controller'; }
     function to(){ var o=handed(); return o.length?('pad '+o[o.length-1].ix):'nothing'; }
     for(k in NET) keep[k]=NET[k];
     try{
       var P0=pd(0), P1=pd(1), both=[P0,P1], gone0=[null,P1];
       // ONE, the player 1 window in front: his order at the start, then the player 2 controller drops, then comes back.
       side('host','zqxpadstick1');
       r=tick(both);
       if(r!==P1||to()!=='pad 0') bad.push('control: at the start player 1 is not on the second controller and player 2 on the first (player 1 plays '+nm(r)+', player 2 handed '+to()+')');
       r=tick(gone0);
       if(r!==P1) bad.push('the player 2 controller dropped and player 1 lost his own controller (he plays '+nm(r)+')');
       if(handed().length) bad.push('the player 2 controller dropped and player 1 handed his own controller to the player 2 window ('+to()+')');
       r=tick(both);
       if(r!==P1||to()!=='pad 0') bad.push('the player 2 controller came back and the sides are not as before (player 1 plays '+nm(r)+', player 2 handed '+to()+')');
       // TWO, the player 2 window in front: its controller drops, and it must not take the player 1 controller.
       side('p2','zqxpadstick2');
       r=tick(both);
       if(r!==P0||to()!=='pad 1') bad.push('control: at the start the player 2 window in front is not on the first controller with player 1 handed the second (plays '+nm(r)+', handed '+to()+')');
       r=tick(gone0);
       if(r) bad.push('the player 2 controller dropped and the player 2 window took the player 1 controller ('+nm(r)+')');
       if(to()!=='pad 1') bad.push('the player 2 controller dropped and player 1 was no longer handed his own controller ('+to()+')');
       // THREE, the player 2 window in front on the second slot with player 1 on none: a controller comes back to slot 0.
       side('p2','zqxpadstick3');
       r=tick(gone0);
       if(r!==P1||handed().length) bad.push('control: the player 2 window with one controller in slot 2 does not play it alone (plays '+nm(r)+', handed '+to()+')');
       r=tick(both);
       if(r!==P1) bad.push('a controller came back to a lower slot and the player 2 window moved off its own controller to it ('+nm(r)+')');
       if(to()!=='pad 0') bad.push('a controller came back to a lower slot and was not handed to player 1, the side with none ('+to()+')');
       h=handed(); msg=h.length?h[h.length-1]:null;
       // FOUR, the player 1 window takes that state while not in front, then comes to the front: it keeps the same sides.
       side('host','zqxpadstick4');
       if(!msg) bad.push('staging: the player 2 window handed nothing over');
       else {
         msg.pair='zqxpadstick4';
         r=netSameOnMsg(msg);
         if(r!=='pad') bad.push('control: the player 1 window refused the state the player 2 window handed over ('+r+')');
         r=tick(both);
         if(r!==P0) bad.push('the player 1 window came to the front and took '+nm(r)+', not the controller the player 2 window left it on, so the two controllers swapped windows');
         if(to()!=='pad 1') bad.push('the player 1 window came to the front and handed player 2 '+to()+', not the controller player 2 was playing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in NET) if(!Object.prototype.hasOwnProperty.call(keep,k)) ks.push(k); for(q=0;q<ks.length;q++) delete NET[ks[q]]; for(k in keep) NET[k]=keep[k]; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
