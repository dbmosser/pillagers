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

if ($s.Contains("  {v:'34.17',what:")) { throw "check 34.17 is in the fixture already" }

SubRx @'
  {v:'34.16',what:
'@ @'
  {v:'34.17',what:'demo start question gets its full 12 seconds after the opening map in each window; initials name tonights best without a top 10 claim',
   run:function(){
     var sv={}, names=['on','solo','role','easy','easyAsk','easyAsked','ini','over'], i, j, g, now=100000, clock=Date.now, text=hudText, skip=MAPFIRST.skip, seen=[], bad=[], ga;
     function capture(fn){ seen=[]; hudText=function(s){ seen.push(String(s).toLowerCase()); }; try{ fn(); }finally{ hudText=text; } return seen.join(' | '); }
     function hasCard(s,n){ return s.indexOf('want easy mode?')>=0&&new RegExp('\\b'+n+'$').test(s); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<names.length;i++) sv[names[i]]=ARCADE[names[i]];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'could not stage a raid';
       ga=g.arcade; g.arcade=1; ARCADE.on=1; ARCADE.solo=0; ARCADE.over=null;
       Date.now=function(){ return now; };
       // Check A: clocks use seams, and both local roles get 12 seconds after their own map.
       for(j=0;j<2;j++){
         ARCADE.role=j?'p2':'host'; ARCADE.easyAsk=null; g.mapFirst=0; MAPFIRST.skip=0;
         if(!mapFirstBegin()) bad.push('opening map not staged for '+ARCADE.role);
         easyStartAsk(); now+=15000; mapFirstStep(15);
         capture(easyHud);
         if(!g.mapFirst||!ARCADE.easyAsk) bad.push(ARCADE.role+': question expired during 15 seconds on the map');
         if(easyLive()) bad.push(ARCADE.role+': question takes answers behind the map');
         mapFirstEnd('test');
         if(!ARCADE.easyAsk||ARCADE.easyAsk.at!==now||!easyLive()) bad.push(ARCADE.role+': countdown did not start at map close');
         if(!hasCard(capture(easyHud),12)) bad.push(ARCADE.role+': card did not start at 12');
         now+=11000;
         if(!hasCard(capture(easyHud),1)) bad.push(ARCADE.role+': card did not retain its last second');
         now+=1000; capture(easyHud);
         if(ARCADE.easyAsk||ARCADE.easy) bad.push(ARCADE.role+': unanswered question was not normal at 12 seconds');
         easyStartAsk();
         if(!ARCADE.easyAsk||ARCADE.easyAsk.at!==now||!hasCard(capture(easyHud),12)) bad.push(ARCADE.role+': no-map question did not start immediately');
         easyAnswer(false);
       }
       // Check B: capture the rendered heading in solo and both two-player windows, plus the solo DOM card.
       for(j=0;j<3;j++){
         ARCADE.solo=j===0?1:0; ARCADE.role=j===2?'p2':'host';
         ARCADE.ini={run:'cx-easymapwords',raid:1,l:['A','B','C'],pos:1,at:now,touched:0,mirror:0,who:j===2?2:1};
         var s=capture(arcadeIniHud);
         if(s.indexOf("tonight's best")<0||s.indexOf('enter initials')<0||/top 10/.test(s)) bad.push('initials heading incorrect for '+(j===0?'solo':ARCADE.role)+': '+s);
       }
       ARCADE.solo=1;
       var c=document.createElement('div'); arcadeIniDraw(c,ARCADE.ini);
       var h=c.querySelector('.aoi'), label=h?String(h.textContent).toLowerCase():'';
       if(label!=="tonight's best \u00b7 enter initials"||/top 10/.test(label)) bad.push('solo run-over heading incorrect: '+label);
       return bad.length?bad.join('; '):null;
     } finally {
       Date.now=clock; hudText=text; MAPFIRST.skip=skip;
       if(g) g.arcade=ga;
       try{ __endRaid('abandon'); }catch(_end){}
       for(i=0;i<names.length;i++) if(Object.prototype.hasOwnProperty.call(sv,names[i])) ARCADE[names[i]]=sv[names[i]];
       __topClear();
     } }},
  {v:'34.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
