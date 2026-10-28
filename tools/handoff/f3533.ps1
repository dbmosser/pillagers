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

if ($s.Contains("  {v:'35.33',what:")) { throw "check 35.33 is in the fixture already" }

SubRx @'
  {v:'35.32',what:
'@ @'
  {v:'35.33',what:'cw-quietkeep, his order 2026-10-27 (build the quiet hud, all 5 changes): with the grey rows retired the left feed is the one place a raid line shows, so the four lines whose detail tells him something keep it there: the loaner line says his own gun waits at The Stash, CONTRACT ITEM NEARBY says the gold glow marks the box, SELECT A HEAL names the three items, and the 2 player Extracted line says player 2 is still out',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof needHint!=='function'||typeof needHolds!=='function'||typeof netAidHold!=='function'||typeof arcadeExtractEnd!=='function'||typeof startRaid!=='function') return 'SKIP: no such lines in this build';
     var bad=[], g=null, oNH=needHolds, told0=P.needTold, nn0, i, ct=null, L, ln=null, r,
         SRC=[[startRaid,'_loanLn,','Equip your own gun'],[needHint,"'CONTRACT ITEM NEARBY'",'GOLD GLOW'],[netAidHold,"'SELECT A HEAL'",'Bandage, Medkit'],[arcadeExtractEnd,"'Extracted'",'Player 2 is still out']];
     try{
       // ONE, the four calls: each carries a key, and a keyed line keeps its detail in the feed at any length
       for(i=0;i<SRC.length;i++){
         var s=String(SRC[i][0]), a=s.indexOf(SRC[i][1]), d=a<0?-1:s.indexOf(SRC[i][2],a), e=d<0?-1:s.indexOf(')',d);
         if(a<0||d<0||e<0) bad.push('control: the line '+SRC[i][1]+' with its detail is not in '+SRC[i][0].name);
         else if(s.slice(a,e).indexOf('key:')<0) bad.push('the line '+SRC[i][1]+' in '+SRC[i][0].name+' carries no key, so its detail ('+SRC[i][2]+') is dropped from the left feed, now the one place it shows');
       }
       // TWO, a real path: the contract item hint says its line into the feed with its detail
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       nn0=g.needN;
       for(i=0;i<g.containers.length;i++) if(g.containers[i]&&!g.containers[i].opened){ ct=g.containers[i]; break; }
       if(!ct) bad.push('control: no box to mark');
       else {
         ct.x=g.player.x+100; ct.y=g.player.y; g.needN=g.needN||1; P.needTold=0;
         needHolds=function(c){ return c===ct; };
         g.fd={t:0,seq:0,lines:[]};
         r=needHint();
         L=g.fd.lines; for(i=0;i<L.length;i++) if(String(L[i].txt).indexOf('CONTRACT ITEM NEARBY')===0) ln=L[i];
         if(!r||!ln) bad.push('control: the contract item hint did not say CONTRACT ITEM NEARBY into the left feed');
         else if(String(ln.txt).indexOf('GOLD GLOW MARKS THE BOX')<0) bad.push('CONTRACT ITEM NEARBY is a feed line without its detail: it reads '+JSON.stringify(ln.txt));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       needHolds=oNH; P.needTold=told0;
       try{ var g2=__state(); if(g2){ g2.needN=nn0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
