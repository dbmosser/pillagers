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

if ($s.Contains("  {v:'37.13',what:")) { throw "check 37.13 is in the fixture already" }

SubRx @'
  {v:'37.12',what:
'@ @'
  {v:'37.13',what:'a hurt machine shows no health pip under its name plate (smoke and sparks only, his g-83 pick) while a hurt pillager bot keeps its pip',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, g=null, p, s=null, r=null, ok=false, k, nS=0, nR=0, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.hp=p.maxhp; refreshVseg();
       var OFS=[[70,-160],[70,160],[110,-120],[110,120],[60,-220],[60,220]];
       for(k=0;k<OFS.length&&!ok;k++){
         p.face=Math.atan2(OFS[k][1],0);
         var ax=p.x-OFS[k][0], ay=p.y+OFS[k][1], bx=p.x+OFS[k][0], by=p.y+OFS[k][1];
         if(canSee(p.x,p.y,p.face,ax,ay,g.vseg)&&canSee(p.x,p.y,p.face,bx,by,g.vseg)){ ok=true; s=mkSentry(ax,ay); r=mkRaider(bx,by); }
       }
       if(!ok) return 'SKIP: staging: no open view from the spawn';
       r.hostile=true; s.hp=s.maxhp*0.5; r.hp=r.maxhp*0.5;
       g.ents.length=0; g.ents.push(s); g.ents.push(r);
       __frame(0.016);
       if(VIS.indexOf(s)<0||VIS.indexOf(r)<0) return 'SKIP: staging: the sentry and the pillager bot were not both in view';
       PR.fillRect=function(x,y,w,h){
         if(h===3&&w>20&&(/_wtA/).test(String(new Error().stack))){ if(x-1<=s.x&&s.x<=x+w+1) nS++; if(x-1<=r.x&&r.x<=x+w+1) nR++; }
         return of.apply(this,arguments);
       };
       __frame(0.016);
       PR.fillRect=of;
       if(!nR) bad.push('the hurt pillager bot lost its health pip');
       if(nS) bad.push('the hurt sentry still draws a health pip ('+nS+' bars)');
       return bad.length?bad.join('; '):null;
     } finally {
       PR.fillRect=of;
       try{ var g2=__state(); if(g2){ g2.ents.length=0; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     } }},
  {v:'37.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
