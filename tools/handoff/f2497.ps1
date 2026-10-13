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

if ($s.Contains("  {v:'24.97',what:")) { throw "check 24.97 is in the fixture already" }

SubRx @'
  {v:'24.96',what:
'@ @'
  {v:'24.97',what:'his note 2026-10-12: calling extraction with a light, a middling and a full haul says and draws no backpack weight line (LIGHT, LOADED or HEAVY BACKPACK, or its They heard that detail), while EXTRACTION CALLED still shows and the greed measure still follows the haul',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy or draw';
     if(typeof tryExtractTick!=='function'||typeof greedOf!=='function'||typeof bagValue!=='function') return 'SKIP: no extraction call here';
     var bad=[], g, p, z=null, bd=1e9, d, i, j, h, realSay=say, realBV=bagValue, oFT=ctx.fillText, BK='BACK'+'PACK',
         W=['HEAVY '+BK,'LOADED '+BK,'LIGHT '+BK,'heard '+'that','Expect '+'company','Fewer will '+'come'],
         XC=['EXTRACTION','CALLED'].join(' '), hauls=[[0.1,'light'],[0.5,'middling'],[1,'full']], said, called, drew, gr=[];
     function hit(s){ s=String(s); for(var w=0;w<W.length;w++) if(s.indexOf(W[w])>=0) return W[w]; return null; }
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function clr(){ g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.mapOpen=false; g.bagOpen=false;
       for(i=0;i<g.zones.length;i++){ if(g.zones[i].open===false) continue; d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y); if(d<bd){ bd=d; z=g.zones[i]; } }
       if(!z) return 'SKIP: no open extraction ring here';
       for(h=0;h<hauls.length;h++){
         (function(fr){ bagValue=function(){ return fr*CFG.greedFull; }; })(hauls[h][0]);
         gr.push(greedOf());
         z.beaconT=null; z.callT=0; z.hold=null; z.pullT=null; clr();
         said=[]; called=false; drew=null;
         say=function(m,k,o){ said.push(String(m)+' | '+String((o&&o.sub)||'')); return realSay.apply(this,arguments); };
         p.x=z.x; p.y=z.y; p.downed=false;
         for(i=0;i<30&&(z.beaconT===null||z.beaconT===undefined);i++){ g.ents.length=0; tryExtractTick(0.1,true); }
         say=realSay;
         if(z.beaconT===null||z.beaconT===undefined){ bad.push('control: standing in the ring with a '+hauls[h][1]+' haul did not call for extraction'); continue; }
         for(j=0;j<said.length;j++){ if(said[j].indexOf(XC)===0) called=true; if(hit(said[j])) bad.push('the call with a '+hauls[h][1]+' haul said '+JSON.stringify(said[j])); }
         if(!called) bad.push('control: the call with a '+hauls[h][1]+' haul did not say '+XC);
         for(i=0;i<8;i++){
           ctx.fillText=function(t){ if(!drew&&hit(t)) drew=String(t); return oFT.apply(this,arguments); };
           try{ __frame(0.016); } finally { unspy(); }
         }
         if(drew) bad.push('with a '+hauls[h][1]+' haul the screen drew '+JSON.stringify(drew));
       }
       if(!(gr.length===3&&gr[0]<gr[1]&&gr[1]<gr[2])) bad.push('control: the staged hauls did not move the greed measure ('+gr.join(', ')+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; bagValue=realBV;
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
