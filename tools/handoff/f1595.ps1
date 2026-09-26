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
  {v:'15.94',what:
'@ @'
  {v:'15.95',what:'the backpack panel prints the price with the thousands separator: in a raid with a Meridian Reactor Core selected in the backpack the price line under the grid reads the same 2,600 each the stash hover prints, and with a Data Core selected the same line reads 520 each on either build (credits audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy, end a raid and restore the profile';
     if(typeof drawBag!=='function'||typeof bagStacks!=='function'||typeof ival!=='function'||typeof ITEMS==='undefined'||!ITEMS.reactor||!ITEMS.core) return 'SKIP: no backpack draw, item prices, Meridian Reactor Core or Data Core in this build';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no canvas in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, snap=null, keep=null, seen=[], cx=ctx, realFill=null, ownFill=false;
     var BIG=ITEMS.reactor.name, SMALL=ITEMS.core.name;
     function drawn(fn){ seen=[]; try{ fn(); }catch(_d){ return null; } return seen.slice(); }
     function has(list,w){ for(var i=0;i<list.length;i++) if(list[i]===w) return true; return false; }
     function priceLines(list){ var o=[]; for(var i=0;i<list.length;i++) if(list[i].indexOf(' each')>=0) o.push(list[i]); return o.length?o.join(' | '):'(no price line)'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // The two prices as the game computes them at the pinned dials: one at or above 1,000, one below.
       var big=ival('reactor'), small=ival('core');
       if(!(big>=1000)||!(small>0&&small<1000)) return 'SKIP: the Meridian Reactor Core is worth '+big+' and the Data Core '+small+' here, so a separator cannot be told apart';
       var withSep=big.toLocaleString();
       if(withSep===String(big)) return 'SKIP: this browser prints '+big+' with no thousands separator, so the two spellings cannot be told apart';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(G!==g||state!=='raid') return 'SKIP: the page is not in this raid here';
       keep={bag:g.bag,hotAssign:g.hotAssign,bagOpen:g.bagOpen,bagSel:g.bagSel,drag:g.drag};
       ownFill=Object.prototype.hasOwnProperty.call(cx,'fillText');
       realFill=cx.fillText;
       cx.fillText=function(t){ seen.push(String(t)); return realFill.apply(cx,arguments); };
       // CONTROL: a Data Core alone in the backpack, selected: the panel draws its name and a price line reading 520 each on
       // either build, so the line is found where the check reads.
       g.bag=['core']; g.hotAssign={}; g.bagOpen=true; g.drag=null; g.bagSel=0;
       var r0=drawn(drawBag);
       if(r0===null) return 'SKIP: drawing the raid backpack threw here';
       if(!has(r0,SMALL)) return 'SKIP: the raid backpack did not draw the selected Data Core here';
       if(!has(r0,'$'+small+' each')) return 'SKIP: with the Data Core selected the price line read "'+priceLines(r0)+'" rather than $'+small+' each, so the line cannot be found here';
       // THE FINDING: a Meridian Reactor Core alone, selected: the price line must carry the separator the stash hover prints.
       g.bag=['reactor']; g.bagSel=0;
       var r1=drawn(drawBag);
       if(r1===null) return 'SKIP: drawing the raid backpack with the Meridian Reactor Core threw here';
       if(!has(r1,BIG)) return 'SKIP: the raid backpack did not draw the selected Meridian Reactor Core here';
       if(!has(r1,'$'+withSep+' each')){
         if(has(r1,'$'+big+' each')) bad.push('with a Meridian Reactor Core selected the price line under the grid reads $'+big+' each, no thousands separator, while the stash hover prints $'+withSep+' each');
         else bad.push('with a Meridian Reactor Core selected the price line read "'+priceLines(r1)+'" rather than $'+withSep+' each');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) cx.fillText=realFill; else delete cx.fillText; } }catch(_f){}
       try{ if(g&&keep){ g.bag=keep.bag; g.hotAssign=keep.hotAssign; g.bagOpen=keep.bagOpen; g.bagSel=keep.bagSel; g.drag=keep.drag; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
