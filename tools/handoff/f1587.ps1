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
  {v:'15.86',what:
'@ @'
  {v:'15.87',what:'at night the sector map header names a night hour: in a live raid at seed 4242 with the hour staged as noon and no weather change coming, in daylight the sector map header and the CONDITIONS row both name noon beside the weather, with the surface set to night the same header and the same row name night beside the weather and name noon nowhere, and with the surface back to day the header names noon again (sector audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__textTrace)) return 'SKIP: this fixture cannot deploy, restore the profile or trace the text drawn';
     if(typeof drawMapOverlay!=='function'||typeof drawHUD!=='function'||typeof isDay!=='function'||typeof tod!=='function'||typeof wx!=='function'||typeof TODS==='undefined'||!TODS||TODS.length<3) return 'SKIP: no sector map, HUD, day test or hour table in this build';
     var bad=[], snap=null, g=null, keep=null;
     // The hour neither line may name at night is read off the hour table, never written here.
     var NOON=TODS[2], NIGHT='night';
     // Every string drawn by one call, and what the call threw if it threw.
     function texts(fn){ var err=''; var tr=__textTrace(function(){ try{ fn(); }catch(e){ err=String((e&&e.message)||e); } }); var out=[]; for(var i=0;i<tr.length;i++) out.push(tr[i].t); return {t:out,err:err}; }
     // The one string that ends in the weather name with its spacing: the map header, or the CONDITIONS row.
     function find(list,tail){ for(var i=0;i<list.length;i++) if(list[i].length>tail.length&&list[i].slice(-tail.length)===tail) return list[i]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||!g.map||!g.wx) return 'SKIP: no live raid with weather';
       keep={tod:g.tod,wxNext:g.wxNext,wxT:g.wxT,mapOpen:g.mapOpen};
       // The stage: noon rolled, no weather change coming, the CONDITIONS panel unfolded, so both lines end in the weather name.
       g.tod=NOON; g.wxNext=null; g.wxT=0; g.mapOpen=false;
       try{ if(P.hud&&P.hud.cond&&P.hud.cond.c) P.hud.cond.c=false; }catch(_hf){}
       var WX=String(g.wx.name);
       if(String(wx().name)!==WX) return 'SKIP: the weather read '+wx().name+' where '+WX+' was staged';
       var mapTail='  '+WX, rowTail='   '+WX;
       // CONTROL: in daylight the header and the row name the hour, so the trace sees both lines on either build.
       P.cond='day';
       if(!isDay()) return 'SKIP: the surface would not read as day here';
       var d1=texts(function(){ drawMapOverlay(); });
       if(d1.err) return 'SKIP: the sector map threw in daylight ('+d1.err+')';
       var dh=find(d1.t,mapTail);
       if(dh===null) return 'SKIP: in daylight the sector map drew no header ending in the weather name, so the header cannot be read here';
       if(dh!==NOON.name+mapTail) return 'SKIP: in daylight with noon rolled the sector map header read "'+dh+'" rather than the hour beside the weather, so the header cannot be read here';
       var d2=texts(function(){ drawHUD(); });
       if(d2.err) return 'SKIP: the HUD threw in daylight ('+d2.err+')';
       var dr=find(d2.t,rowTail);
       if(dr===null) return 'SKIP: in daylight the CONDITIONS panel drew no row ending in the weather name, so the row cannot be read here';
       if(dr!==NOON.name+rowTail) return 'SKIP: in daylight with noon rolled the CONDITIONS row read "'+dr+'" rather than the hour beside the weather, so the row cannot be read here';
       // THE FIX: the surface set to night, the hour still rolled as noon (buildRaid rolls it either way), and neither line names it.
       P.cond='night';
       if(isDay()) return 'SKIP: the surface would not read as night here';
       var n1=texts(function(){ drawMapOverlay(); });
       if(n1.err) bad.push('the sector map threw at night ('+n1.err+')');
       else {
         var nh=find(n1.t,mapTail);
         if(nh===null) bad.push('at night the sector map drew no header ending in the weather name');
         else if(nh.indexOf(NOON.name)>=0) bad.push('at night, with the hour rolled as '+NOON.name+', the sector map header still read "'+nh+'", a daylight hour over a raid that went up in the dark');
         else if(nh!==NIGHT+mapTail) bad.push('at night the sector map header read "'+nh+'" rather than "'+NIGHT+mapTail+'"');
       }
       var n2=texts(function(){ drawHUD(); });
       if(n2.err) bad.push('the HUD threw at night ('+n2.err+')');
       else {
         var nr=find(n2.t,rowTail);
         if(nr===null) bad.push('at night the CONDITIONS panel drew no row ending in the weather name');
         else if(nr.indexOf(NOON.name)>=0) bad.push('at night, with the hour rolled as '+NOON.name+', the CONDITIONS row still read "'+nr+'", a daylight hour over a raid that went up in the dark');
         else if(nr!==NIGHT+rowTail) bad.push('at night the CONDITIONS row read "'+nr+'" rather than "'+NIGHT+rowTail+'"');
       }
       // KEPT: back in daylight the header names the rolled hour again.
       P.cond='day';
       var d3=texts(function(){ drawMapOverlay(); });
       if(d3.err) bad.push('the sector map threw back in daylight ('+d3.err+')');
       else if(find(d3.t,mapTail)!==NOON.name+mapTail) bad.push('back in daylight the sector map header read "'+find(d3.t,mapTail)+'" rather than the hour beside the weather');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&keep){ g.tod=keep.tod; g.wxNext=keep.wxNext; g.wxT=keep.wxT; g.mapOpen=keep.mapOpen; } }catch(_g){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
