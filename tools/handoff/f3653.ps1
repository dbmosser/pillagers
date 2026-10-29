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

if ($s.Contains("  {v:'36.53',what:")) { throw "check 36.53 is in the fixture already" }

SubRx @'
  {v:'36.52',what:
'@ @'
  {v:'36.53',what:'spot marks share a 24px filled glyph and seat colour in raid, minimap and map; a spot label sits 4px clear of its diamond',
   run:function(){
     var keep={},ks=['on','seat','pings','wps','pingAt','pingLast','pingTarget'],g,p,i,j,r,MP,calls=[],panels=[],cg=colourCueGlyph,hp=hudPanel,ws=w2s;
     ks.forEach(function(k){keep[k]=NET[k];});
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.on=false;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.rise=null;CFG.xfPix=0;
       colourCueGlyph=function(c,k,x,y,s,col){calls.push({k:k,x:x,y:y,s:s,col:col});return cg.apply(this,arguments);};
       hudPanel=function(x,y,w,h){panels.push({x:x,y:y,w:w,h:h});return hp.apply(this,arguments);};
       r=Math.max(1,hudRes());
       for(i=0;i<2;i++){
         NET.seat=i;NET.pings=[];NET.wps={};g.waypoint=null;netMarkSet(p.x+150,p.y-100);
         w2s=function(){return {x:W/2,y:H/2};};calls=[];panels=[];netPingDraw();w2s=ws;
         if(calls.length!==1||calls[0].k!=='place'||Math.abs(calls[0].s-2.4*r)>.01||calls[0].col!==netMarkColour(i))return 'world spot is not the shared 24px seat-coloured filled glyph';
         if(panels.length!==1||Math.abs(panels[0].y+panels[0].h-(H/2-16*r))>.1)return 'spot plate is not 4px above its 24px diamond';
         calls=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);
         if(!calls.some(function(q){return q.k==='place'&&q.col===netMarkColour(i)&&Math.abs(q.s-2.4)<.01;}))return 'own minimap spot has a different glyph';
         calls=[];g.mapOpen=true;drawMapOverlayRaw();MP=mapProj();
         if(!calls.some(function(q){return q.k==='place'&&q.col===netMarkColour(i)&&Math.abs(q.s-2.4*r)<.01&&Math.abs(q.x-(MP.ox+g.waypoint.x*MP.sc))<2;}))return 'own sector map spot has a different glyph';
         g.mapOpen=false;NET.pings=[];g.waypoint=null;netPingPush(1-i,{x:p.x+100,y:p.y-80,spot:1});calls=[];netWpMapDraw(0,0,.1);
         if(!calls.some(function(q){return q.k==='place'&&q.col===netMarkColour(1-i)&&Math.abs(q.s-2.4*r)<.01;}))return 'partner sector map spot has a different glyph';
       }
       return null;
     }finally{
       colourCueGlyph=cg;hudPanel=hp;w2s=ws;NET.on=false;try{__endRaid('abandon');}catch(_e){}__topClear();ks.forEach(function(k){NET[k]=keep[k];});
     }
   }},
  {v:'36.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
