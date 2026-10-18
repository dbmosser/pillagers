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

if ($s.Contains("  {v:'31.12',what:")) { throw "check 31.12 is in the fixture already" }

SubRx @'
  {v:'31.11',what:
'@ @'
  {v:'31.12',what:'cw-barrels3b: the frost fog a cryo barrel leaves is a thick cloud (covers well over a quarter of the circle it is drawn in, measured on a recording canvas), not a faint outline; the acid pool still draws',
   run:function(){
     if(typeof brlPoolDraw!=='function'||typeof BRL_POOL!=='object') return 'SKIP: no frost fog in this build';
     var bad=[], oW=wc, oT=null, g=null, rec={ga:1,area:0,cov:0,ops:0}, fake={}, cry, aci, thrown=null;
     ['save','restore','beginPath','moveTo','lineTo','closePath','stroke','rect','clip','translate','scale','rotate','setTransform','quadraticCurveTo','fillRect'].forEach(function(n){ fake[n]=function(){ rec.ops++; }; });
     fake.ellipse=function(x,y,rx,ry){ rec.area=3.14159*rx*ry; rec.ops++; };
     fake.arc=function(x,y,r){ rec.area=3.14159*r*r; rec.ops++; };
     fake.fill=function(){ rec.cov+=rec.ga*rec.area; rec.ops++; };
     fake.drawImage=function(im,x,y,w,h){ if(arguments.length>=5) rec.cov+=rec.ga*w*h; rec.ops++; };
     Object.defineProperty(fake,'globalAlpha',{get:function(){ return rec.ga; },set:function(v){ rec.ga=v; }});
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       oT=g.t; g.t=0; wc=fake;
       try{ brlPoolDraw({x:0,y:0,r:96,t:1,life:5,by:-1,bt:0,k:'cryo'}); cry=rec.cov/(96*96); }catch(e1){ thrown='cryo: '+(e1&&e1.message||e1); }
       rec.cov=0; rec.ga=1; rec.ops=0;
       try{ brlPoolDraw({x:0,y:0,r:72,t:1,life:6,by:-1,bt:0,k:'acid'}); aci=rec.cov/(72*72); }catch(e2){ thrown=(thrown||'')+' acid: '+(e2&&e2.message||e2); }
       wc=oW; g.t=oT;
       if(thrown) bad.push('drawing a fog or a pool threw: '+thrown);
       if(!(cry>=3.2)) bad.push('the frost fog covers only '+(cry===undefined?'nothing':cry.toFixed(2))+' of the square of its radius, a faint outline, not a cloud (3.2 and over is a cloud)');
       if(!(aci>1.5)) bad.push('the acid pool covers only '+(aci===undefined?'nothing':aci.toFixed(2))+' of the square of its radius');
       return bad.length?bad.join('; '):null;
     }catch(e){ return 'threw: '+(e&&e.stack||e); }
     finally{
       wc=oW; try{ if(g&&oT!==null) g.t=oT; }catch(_t){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
