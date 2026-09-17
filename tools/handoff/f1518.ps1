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
  {v:'15.17',what:
'@ @'
  {v:'15.18',what:'BUILD A RACK says how many packed parts it took out of the backpack: with scrap, cells and boards packed, the rack line names the packed cells and boards the loose ones could not cover and no packed scrap, loose parts are still spent first, and a rack built with nothing packed says nothing of the backpack (mainframe audit finding 3)',
   run:function(){
     if(typeof buildRack!=='function'||typeof spendHeld!=='function'||typeof packedCount!=='function'||typeof heldCount!=='function'||typeof rackAfford!=='function'||typeof RACK_COST==='undefined'||!window.__applyLoaded) return 'SKIP: no mainframe racks or packing in this build';
     if(!(RACK_COST.scrap>0&&RACK_COST.cell>=4&&RACK_COST.board>0)) return 'SKIP: the rack cost has no scrap, four cells and boards in this build';
     var bad=[], snap=null, _say=say, said=[];
     var nm=function(k){ return (ITEMS[k]&&ITEMS[k].name)||k; };
     var fill=function(Q,extra){ Q.stash=[]; for(var fk in RACK_COST){ for(var fj=0;fj<RACK_COST[fk]+(extra[fk]||0);fj++) Q.stash.push(fk); } };
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     try{
       __topClear(); __cleanProfile();
       // A raid an earlier check ended leaves G set, and say then writes G.msg rather than the Undercroft toast, so the line
       // is read from say itself: in the Undercroft the toast shows that text word for word.
       if(G&&!G.over) return 'SKIP: a raid is running, and a rack is built in the Undercroft';
       snap=JSON.parse(JSON.stringify(__P()));
       say=function(m){ said.push(String(m)); };
       // ONE: the rack cost held loose, nothing packed.
       var q=__P(), k;
       q.racks=0; q.arrays=0; q.kit=[]; q.hotAssign={};
       fill(q,{});
       said=[];
       buildRack();
       var t1=said.join(' ');
       // CONTROL: the rack was built and said its line.
       if(__P().racks!==1||t1.indexOf('Rack 1')<0) return 'SKIP: the rack was not built here ('+t1.slice(0,80)+')';
       if(t1.indexOf('packed')>=0||t1.indexOf('backpack')>=0) bad.push('a rack built with nothing packed says: '+t1.slice(0,160));
       // TWO: two extra scrap and two extra boards, with 2 scrap, 4 cells and 3 boards packed for the next ascent.
       q=__P(); q.racks=0; q.arrays=0; q.hotAssign={};
       fill(q,{scrap:2,board:2});
       q.kit=['scrap','scrap','cell','cell','cell','cell','board','board','board'];
       var pb={}, exp={};
       for(k in RACK_COST){ pb[k]=packedCount(k); exp[k]=Math.max(0,RACK_COST[k]-(heldCount(k)-pb[k])); }
       // CONTROL: the packing took, and the parts, packed ones counted, still pay for a rack.
       if(pb.scrap!==2||pb.cell!==4||pb.board!==3||!rackAfford()) return skip('the packing did not take here (scrap '+pb.scrap+', cells '+pb.cell+', boards '+pb.board+')');
       said=[];
       buildRack();
       var t2=said.join(' ');
       // CONTROL: the rack was built and said its line.
       if(__P().racks!==1||t2.indexOf('Rack 1')<0) return skip('the rack with parts packed was not built here ('+t2.slice(0,80)+')');
       var took={}, named=[], miss=[], moved=[];
       for(k in RACK_COST){
         took[k]=pb[k]-packedCount(k);
         // The v13.59 rule stands: loose copies go first, so only what the loose ones cannot cover leaves the backpack.
         if(took[k]!==exp[k]) moved.push(took[k]+' packed '+nm(k)+' taken where '+exp[k]+' were needed');
         if(took[k]>0){ named.push(took[k]+' packed '+nm(k)); if(t2.indexOf(' '+took[k]+' packed '+nm(k))<0) miss.push(nm(k)); }
         else if(t2.indexOf('packed '+nm(k))>=0) bad.push('the rack line names packed '+nm(k)+' it did not take: '+t2.slice(0,160));
       }
       if(moved.length) bad.push('the rack no longer spends loose parts before packed ones: '+moved.join(', '));
       // CONTROL: the rack did take packed parts, so there is something to say.
       if(!named.length) return skip('the rack took no packed part here');
       if(miss.length||t2.indexOf('backpack')<0) bad.push('a rack that took '+named.join(' and ')+' out of the backpack says only: '+t2.slice(0,160));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
