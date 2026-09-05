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

# THE TARGET IS A CELL A BODY CAN STAND IN. The exact centre of a building can
# sit inside a piece of furniture's padding, and a route to a blocked cell is
# no route at all; that read building 74 as sealed when its centre was five
# units from a table. The target is the nearest open route cell to the centre,
# within 48 units. And the survey runs both dials of this build, since two rules
# ship in it.
SubRx @'
     function survey(mi,dial){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(),B=g.map.buildings,Ds=g.map.doors,nd=g.map.navD,sealed=[],tested=0,q,u;
       for(q=0;q<B.length;q++){ var bd=B[q]; if(bd.w<120||bd.h<120) continue;
         var doors=[]; for(u=0;u<Ds.length;u++){ var dd=Ds[u]; if(dd.x>=bd.x-1&&dd.x<=bd.x+bd.w+1&&dd.y>=bd.y-1&&dd.y<=bd.y+bd.h+1) doors.push(dd); }
         if(!doors.length) continue;
         var cx=bd.x+bd.w/2, cy=bd.y+bd.h/2, ok=false;
         for(u=0;u<doors.length&&!ok;u++){ var d=doors[u], h=d.w>=d.h, top=(h?d.y:d.x)<=(h?bd.y:bd.x)+1;
           var ix=h?d.x+32:(top?d.x+16+30:d.x-30), iy=h?(top?d.y+16+30:d.y-30):d.y+32;
           if(__navPath(nd,ix,iy,cx,cy,0)) ok=true; }
         tested++; if(!ok) sealed.push(q); }
'@ @'
     function survey(mi,dial){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial,furnGap:dial});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(),B=g.map.buildings,Ds=g.map.doors,nd=g.map.navD,cc=nd.c,sealed=[],tested=0,q,u;
       function openCell(x,y){ var gx=Math.floor(x/cc),gy=Math.floor(y/cc); if(gx<0||gy<0||gx>=nd.w||gy>=nd.h) return false; return !nd.blk[gy*nd.w+gx]; }
       function nearOpen(x,y){ if(openCell(x,y)) return [x,y]; for(var r=16;r<=48;r+=16) for(var a=0;a<8;a++){ var an=a*Math.PI/4, px=x+Math.cos(an)*r, py=y+Math.sin(an)*r; if(openCell(px,py)) return [px,py]; } return null; }
       for(q=0;q<B.length;q++){ var bd=B[q]; if(bd.w<120||bd.h<120) continue;
         var doors=[]; for(u=0;u<Ds.length;u++){ var dd=Ds[u]; if(dd.x>=bd.x-1&&dd.x<=bd.x+bd.w+1&&dd.y>=bd.y-1&&dd.y<=bd.y+bd.h+1) doors.push(dd); }
         if(!doors.length) continue;
         var tgt=nearOpen(bd.x+bd.w/2,bd.y+bd.h/2), ok=false;
         if(!tgt){ tested++; sealed.push(q); continue; }
         for(u=0;u<doors.length&&!ok;u++){ var d=doors[u], h=d.w>=d.h, top=(h?d.y:d.x)<=(h?bd.y:bd.x)+1;
           var ix=h?d.x+32:(top?d.x+16+30:d.x-30), iy=h?(top?d.y+16+30:d.y-30):d.y+32;
           if(__navPath(nd,ix,iy,tgt[0],tgt[1],0)) ok=true; }
         tested++; if(!ok) sealed.push(q); }
'@

SubRx @'
     function drive(dial,frames){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial});
'@ @'
     function drive(dial,frames){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial,furnGap:dial});
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
