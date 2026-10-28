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

if ($s.Contains("  {v:'35.65',what:")) { throw "check 35.65 is in the fixture already" }

SubRx @'
  {v:'35.64',what:
'@ @'
  {v:'35.65',what:'a solo or guest target ping draws one specific name plate, keeps the health pip, restores the normal name on expiry, and has 24px map glyphs',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype,ft=PR.fillText,fr=PR.fillRect,cg=colourCueGlyph,cs=canSee;
     var pk=NET.pings,wk=NET.wps,em=NET.entMap,on=NET.on,seat=NET.seat,ow=W,oh=H,g,e,p,words=[],health=0,glyphs=[],j;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;CFG.xfPix=0;
       e=g.ents.filter(function(q){return q.hp>0&&q.kind==='sentry';})[0];
       if(!e)return 'no seeded sentry';
       p.x=WORLD_W/2;p.y=WORLD_H/2;e.x=p.x+100;e.y=p.y-20;e.name='zq ping sentry';e.nid=42;e.hp=e.maxhp/2;e.state='patrol';e.seen=true;
       NET.on=false;NET.wps={};NET.pings=[];NET.entMap={42:e};
       canSee=function(){return true;};
       PR.fillText=function(s){var t=String(s).toLowerCase();if(t.indexOf('zq ping sentry')>=0)words.push(t);return ft.apply(this,arguments);};
       PR.fillRect=function(x,y,w,h){if(this.fillStyle==='#ffc04a'&&h===3&&/_wtA/.test(String(new Error().stack)))health++;return fr.apply(this,arguments);};
       __frame();words=[];health=0;__frame();
       if(words.filter(function(t){return t==='zq ping sentry';}).length!==1||!health)return 'control: normal target name or health pip did not draw';
       for(j=0;j<2;j++){
         NET.on=!!j;NET.seat=j;
         NET.pings=[{s:j,x:e.x,y:e.y,w:'sentry',id:j?42:undefined,target:j?null:e,at:Date.now()}];
         words=[];health=0;__frame();
         if(words.length!==1||words[0]==='zq ping sentry'||words[0].indexOf('you')<0||!/\d+m/.test(words[0]))return 'target ping still has duplicate labels or loses its identity/distance in seat '+j;
         if(!health)return 'ping hides the wounded target health pip in seat '+j;
         NET.pings[0].at=Date.now()-NET_PING_T*1000-10;
         words=[];health=0;__frame();
         if(words.length!==1||words[0]!=='zq ping sentry'||!health)return 'expiry failed to restore the normal target name and health pip';
       }
       colourCueGlyph=function(c,k,x,y,s){glyphs.push({k:k,s:s});return cg.apply(this,arguments);};
       NET.on=false;NET.pings=[{s:0,x:p.x,y:p.y,w:'sentry',at:Date.now()}];
       glyphs=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);
       if(!glyphs.some(function(v){return v.k==='target'&&v.s>=2;}))return 'minimap target is below 24px';
       glyphs=[];netWpMapDraw(0,0,.1);
       if(!glyphs.some(function(v){return v.k==='target'&&v.s>=2*hudRes();}))return 'full-map target is below 24px scaled';
       return null;
     }finally{
       PR.fillText=ft;PR.fillRect=fr;colourCueGlyph=cg;canSee=cs;
       NET.on=false;try{__endRaid('abandon');}catch(err){}__topClear();__forceSize(ow,oh);
       NET.pings=pk;NET.wps=wk;NET.entMap=em;NET.on=on;NET.seat=seat;
     }
   }},
  {v:'35.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
