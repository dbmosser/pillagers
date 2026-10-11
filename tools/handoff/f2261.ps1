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

if ($s.Contains("  {v:'22.61',what:")) { throw "check 22.61 is in the fixture already" }

SubRx @'
  {v:'22.60',what:
'@ @'
  {v:'22.61',what:'a gift taken while his backpack is open is still shown: the teammate takes the offered item while the giver has the backpack open, 6 s pass with it open, and when it shuts the GIVEN TO row is drawn in the pickup stack',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     if(typeof netGiftTake!=='function'||typeof drawPickups!=='function'||typeof msgTick!=='function'||typeof NET!=='object') return 'SKIP: no gift or pickup stack here';
     var bad=[], g=null, p, oFT=ctx.fillText, ev=[], GV=['GIVEN','TO'].join(' '), res, i, row=null, hit=false, n=-1;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; p.downed=false; g.mapOpen=false;
       if(!ITEMS.scrap) return 'SKIP: no Scrap Metal item to give';
       g.bag=['scrap']; g.pick=[]; g.bagOpen=true;
       g.giftOut={id:'chkgift1',k:'scrap',to:1,t:g.t};
       res=netGiftTake({state:'in',seat:1},{op:'yes',id:'chkgift1',from:1});
       if(res!=='gave') return 'SKIP: staging: the gift answer gave '+res;
       if(g.bag.indexOf('scrap')>=0) bad.push('the item given is still in the backpack');
       for(i=0;i<60;i++) msgTick(0.1);
       g.bagOpen=false;
       for(i=0;i<(g.pick||[]).length;i++) if(String(g.pick[i].tag||'').toUpperCase().indexOf(GV)===0) row=g.pick[i];
       if(!row) bad.push('after 6 s with the backpack open the GIVEN TO row is gone from the pickup stack, so the giver never sees that his item left');
       else {
         row.at=(g.t||0)-1;
         ctx.fillText=function(t,x){ ev.push([String(t),+x]); return oFT.apply(this,arguments); };
         ctx.save(); try{ n=drawPickups(); } finally { ctx.restore(); unspy(); }
         for(i=0;i<ev.length;i++) if(ev[i][0].indexOf(GV)>=0&&ev[i][1]>W*0.6) hit=true;
         if(!hit) bad.push('with the backpack shut the GIVEN TO row is not drawn (drawPickups drew '+n+' rows)');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ var g2=__state(); if(g2){ g2.giftOut=null; g2.bagOpen=false; g2.pick=[]; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
