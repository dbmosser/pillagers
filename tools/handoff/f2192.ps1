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

if ($s.Contains("  {v:'21.92',what:")) { throw "check 21.92 is in the fixture already" }

SubRx @'
  {v:'21.91',what:
'@ @'
  {v:'21.92',what:'a teammate down is not lost in a burst of lines: sent while two rows are up and followed by five more lines, it shows within 4 s, and the extraction closing lines go out as extraction lines',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof netOnState!=='function'||typeof padRumble!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this build has no party words';
     if(typeof feedRows!=='function') return 'SKIP: no message rows here';
     var NK={}, k, bad=[], g, realSay=say, realSwf=sayWhenFree, oRum=padRumble, oName=netSeatName, peer={seat:1,state:'in'}, w, t0, f=0, i, j, rows, seen=-1, cz=null, kinds=[];
     function step(){ __loop(t0+(++f)*16.7); }
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       NET.on=false; NET.role=null; NET.peers=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9;
       // only the probe lines and the teammate line may speak
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('MOTH')===0) return realSay.apply(this,arguments); };
       padRumble=function(){ return 'test'; };
       netSeatName=function(s){ return s===1?'MOTH':(s===0?'HOST':null); };
       t0=performance.now();
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey='';
       say('zq r1'); say('zq r2');   // two ordinary rows up, both still protected
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.floor=NET.floor||[];
       w={t:'st',k:'r',x:Math.round(g.player.x)+60,y:Math.round(g.player.y),f:0,sd:g.seed>>>0,dn:0,hp:100,mh:100};
       netOnState(peer,w); netOnState(peer,w); w.dn=1; netOnState(peer,w);
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       for(i=1;i<=5;i++) sayWhenFree('zq b'+i);
       for(i=0;i<240&&seen<0;i++){
         rows=feedRows();
         for(j=0;j<rows.length;j++) if(String(rows[j].m).indexOf('MOTH')===0){ seen=i; break; }
         if(seen>=0) break;
         step(); if(g.over) break;
       }
       if(seen<0) bad.push('a teammate down sent while two rows were up and followed by five lines never showed in 4 s (queue '+JSON.stringify((g.msgQ||[]).map(String))+')');
       // the extraction closing lines carry the extraction kind
       for(i=0;i<g.zones.length;i++) if(g.zones[i].closeAt!==undefined&&g.zones[i].open&&g.zones[i]!==g.active){ cz=g.zones[i]; break; }
       if(cz){
         sayWhenFree=function(m,kd){ if(String(m).indexOf('Extraction')===0||String(m).indexOf('EXTRACTION')===0) kinds.push(kd); };
         cz.warned=0; cz.beaconT=null; g.timeLeft=cz.closeAt+100; step();
         g.timeLeft=cz.closeAt-0.5; step();
         sayWhenFree=realSwf;
         if(kinds.length<2) bad.push('staging: the closing and closed lines were said '+kinds.length+' times');
         for(i=0;i<kinds.length;i++) if(kinds[i]!=='ext') bad.push('an extraction closing line goes out as '+JSON.stringify(kinds[i])+', not ext');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; sayWhenFree=realSwf; padRumble=oRum; netSeatName=oName; keys={};
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
