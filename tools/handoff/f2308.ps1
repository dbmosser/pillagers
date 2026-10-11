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

if ($s.Contains("  {v:'23.08',what:")) { throw "check 23.08 is in the fixture already" }

SubRx @'
  {v:'23.07',what:
'@ @'
  {v:'23.08',what:'system labels in caps: zoom in and out, the HUD size, a Waypoint set and cleared alone and set in a party, the cursor reset and auto-jog each say a caps headline of at most 34 with any detail of at most 48, nothing says Marker or the map, and every weather detail is at most 56 characters and never names the map as a place',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof raidKey!=='function'||typeof netWpFromMap!=='function'||typeof mapProj!=='function'||typeof WEATHER==='undefined'||typeof cv==='undefined'||!cv||typeof mouse!=='object') return 'SKIP: no raid keys, map Waypoint or weather here';
     var bad=[], g=null, p=null, i, said=[], realSay=say, realWF=sayWhenFree, z0, mx0=mouse.x, my0=mouse.y, MP, keepN={on:NET.on,peers:NET.peers,seat:NET.seat}, MK='Mark'+'er', TM='the '+'map';
     function line(tag,n0){ if(said.length<=n0) bad.push(tag+' said nothing'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false; g.paused=false; z0=(typeof zoomTarget==='function')?zoomTarget():1;
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); return realSay.apply(this,arguments); };
       sayWhenFree=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); };
       var n=said.length; raidKey('NumpadAdd',false); line('zoom in',n);
       n=said.length; raidKey('NumpadSubtract',false); line('zoom out',n);
       if(typeof setZoom==='function') setZoom(z0,true);
       // the Waypoint, alone and in a party, and cleared from the map
       g.mapOpen=true; MP=mapProj(); mouse.x=MP.ox+20; mouse.y=MP.oy+20;
       NET.on=false; n=said.length; netWpFromMap(); line('a Waypoint set alone',n);
       NET.on=true; NET.peers=[]; n=said.length; try{ netWpFromMap(); }catch(_w){} line('a Waypoint set in a party',n); NET.on=false;
       n=said.length; cv.dispatchEvent(new MouseEvent('mousedown',{button:2,bubbles:true})); line('a Waypoint cleared',n);
       g.mapOpen=false;
       // the cursor and auto-jog
       if(typeof restoreCursor==='function'){ n=said.length; window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backspace',key:'Backspace',bubbles:true})); }
       keys={}; p.autoJog=false;
       for(i=0;i<said.length;i++){
         var l=said[i], s=l.m+' '+l.sub;
         if(l.m!==l.m.toUpperCase()||l.m.length>34||(/[.!?,;:]$/).test(l.m)) bad.push(JSON.stringify(l.m)+' is not a caps headline of at most 34');
         if(l.sub.length>48) bad.push(JSON.stringify(l.m)+' has a detail of '+l.sub.length+' characters');
         if(s.indexOf(MK)>=0||s.toUpperCase().indexOf(MK.toUpperCase()+' ')>=0) bad.push(JSON.stringify(s)+' says Marker, not Waypoint');
         if(s.toLowerCase().indexOf(TM)>=0) bad.push(JSON.stringify(s)+' names the map as a place');
       }
       // the weather details
       for(i=0;i<WEATHER.length;i++){
         var w=WEATHER[i], sb=String(w.sub||'');
         if(sb.length>56) bad.push('the '+w.id+' weather detail is '+sb.length+' characters');
         if(sb.toLowerCase().indexOf(TM)>=0) bad.push('the '+w.id+' weather detail names the map as a place: '+JSON.stringify(sb));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; sayWhenFree=realWF; NET.on=keepN.on; NET.peers=keepN.peers; NET.seat=keepN.seat; mouse.x=mx0; mouse.y=my0; keys={};
       try{ if(typeof setZoom==='function') setZoom(z0,true); }catch(_z){}
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; g2.waypoint=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
