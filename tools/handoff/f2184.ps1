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

if ($s.Contains("  {v:'21.84',what:")) { throw "check 21.84 is in the fixture already" }

SubRx @'
  {v:'21.83',what:
'@ @'
  {v:'21.84',what:'a wrapped line draws his words: the CONDITIONS panel and the sector map zone names split his rewording, not the original',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof txRecord!=='function'||typeof drawHUD!=='function'||typeof sectorPreviewDraw!=='function'||typeof CONDWRAP!=='object') return 'SKIP: no text recorder, HUD, sector map or CONDITIONS wrap in this build';
     var bad=[], g=null, wx0=null, k, hadTxt=false, set=[], realSay=say;
     function setTxt(o,n){ set.push(o); P.txt[o]=n; }
     function rowsOf(rec){ var a=[],i; for(i=0;i<rec.length;i++) a.push(String(rec[i].t)); return a; }
     // The first run of two or more drawn rows, one after another, whose words joined by spaces are want: {i,n}, or null.
     function runOf(a,want){
       for(var i=0;i<a.length;i++){
         if(!a[i]||want.indexOf(a[i])!==0) continue;
         var acc=a[i], j=i;
         while(acc.length<want.length&&j+1<a.length){ j++; acc+=' '+a[j]; }
         if(acc===want&&j>i) return {i:i,n:j-i+1};
       }
       return null;
     }
     function hud(){ CONDWRAP={}; CONDWRAPN=0; return rowsOf(txRecord(function(){ drawHUD(); })); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.wx) return 'SKIP: staging: no raid with a weather';
       keys={}; g.mapOpen=false; g.bagOpen=false;
       say=function(){};
       hadTxt=!!P.txt; if(!P.txt) P.txt={};
       // ONE: a weather row that fits on one line, and his rewording of it about three lines long.
       wx0=g.wx; var W1={}; for(k in wx0) W1[k]=wx0[k]; W1.view=1; W1.noise=1; W1.lights=0.5; W1.lightning=0; g.wx=W1;
       var ONE=['lamps','50%','out'].join(' '), HIS=['zq the yard lamps are half dark tonight','so keep to the walls and stay low'].join(' ');
       var a0=hud();
       if(a0.indexOf(ONE)<0) return 'SKIP: the CONDITIONS panel did not draw the staged weather row ('+ONE+') on one line';
       setTxt(ONE,HIS);
       var a1=hud();
       if(!runOf(a1,HIS)){
         if(a1.indexOf(HIS)>=0) bad.push('his rewording of a one line CONDITIONS row is drawn whole on one row, past the panel, instead of wrapped');
         else bad.push('his rewording of a one line CONDITIONS row is not drawn; the rows drawn are '+JSON.stringify(a1.filter(function(s){ return /lamps|zq/.test(s); })));
       }
       delete P.txt[ONE];
       // TWO: a weather row that wraps on its own, and his rewording of its last row, longer than the panel.
       W1.lightning=1;
       var LONG=ONE+', '+['lightning strikes:','flashes reveal you from farther away'].join(' ');
       var b0=hud(), run=runOf(b0,LONG);
       if(!run) bad.push('(then SKIP: the staged two line weather row was not drawn as rows of its own words)');
       else {
         var X=b0[run.i+run.n-1], HX=X+' '+['zq and a few more','of his own words'].join(' ');
         setTxt(X,HX);
         var b1=hud();
         if(b1.indexOf(HX)<0) bad.push('his rewording of the last row of a wrapped CONDITIONS row ('+X+') is not drawn; the rows drawn are '+JSON.stringify(b1.slice(Math.max(0,run.i-1),run.i+run.n+2)));
         delete P.txt[X];
       }
       g.wx=wx0;
       // THREE: a sector map zone name that fits, and his name for it, too wide even at the smallest size.
       var cv=document.createElement('canvas'); cv.width=200; cv.height=200;
       var ZN=['ZQ','YARD'].join(' '), ZH=['ZQ THE LONG FROZEN','YARD OF LAMPS'].join(' ');
       var M={w:1000,h:1000,zones:[{x:0,y:0,w:500,h:500,name:ZN}]};
       var z0=rowsOf(txRecord(function(){ sectorPreviewDraw(cv,M); }));
       if(z0.indexOf(ZN)<0) bad.push('(then SKIP: the staged zone name '+ZN+' was not drawn on one line, drawn '+JSON.stringify(z0)+')');
       else {
         setTxt(ZN,ZH);
         var z1=rowsOf(txRecord(function(){ sectorPreviewDraw(cv,M); }));
         if(!runOf(z1,ZH)&&z1.indexOf(ZH)<0) bad.push('his name for a sector map zone is not drawn; the rows drawn are '+JSON.stringify(z1));
         delete P.txt[ZN];
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ for(var q=0;q<set.length;q++) if(P.txt) delete P.txt[set[q]]; if(!hadTxt) delete P.txt; }catch(_t){}
       try{ CONDWRAP={}; CONDWRAPN=0; }catch(_c){}
       try{ var g2=__state(); if(g2&&wx0) g2.wx=wx0; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
