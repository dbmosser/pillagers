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

if ($s.Contains("  {v:'36.82',what:")) { throw "check 36.82 is in the fixture already" }

SubRx @'
  {v:'36.81',what:
'@ @'
  {v:'36.82',what:'the raid draws one thin outline in a fixed order of strength: the partner, then the golden enemy, then pillager crews, then the box in reach; plain machines get none',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     if(typeof OUTLN==='undefined'||typeof outlineFor!=='function') return 'there is no shared outline table (OUTLN, outlineFor)';
     var o=OUTLN, g, i, e, cr=null, mc=null, ct=null, n0, w0, PR=CanvasRenderingContext2D.prototype, osr=PR.strokeRect, hit=0, ol, fk;
     if(!(o.partner.a>o.golden.a&&o.golden.a>o.crew.a&&o.crew.a>o.use.a)) return 'the outline strengths are not in the order partner, golden, crew, use';
     if(!(o.partner.w>=o.golden.w&&o.golden.w>=o.crew.w&&o.crew.w>=o.use.w)) return 'the outline widths are not in the order partner, golden, crew, use';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(!cr&&e.kind==='raider'&&!e.merc&&e.crew!==undefined&&e.hp>0) cr=e; if(!mc&&e.kind==='sentry'&&!e.golden&&e.hp>0) mc=e; }
       if(!cr) return 'SKIP: no pillager crew on this map';
       if(mc&&outlineFor(mc)) return 'a plain machine got an outline';
       ol=outlineFor(cr); if(!ol||ol.sp!==o.crew) return 'a pillager of a crew does not get the crew outline';
       cr.golden=1; ol=outlineFor(cr); cr.golden=0;
       if(!ol||ol.sp!==o.golden) return 'the golden enemy does not outrank a crew outline';
       if(outlineFor({kind:'raider',merc:1,crew:0,hp:50})) return 'a hired pillager got a crew outline';
       // a crew pillager beside the player is drawn through the thin stamp
       cr.x=g.player.x+50; cr.y=g.player.y; cr.seen=true; n0=RIM.n;
       for(i=0;i<4&&!(RIM.n>n0);i++){ cr.seen=true; __frame(); }
       if(!(RIM.n>n0)) return 'a pillager of a crew was drawn with no outline stamp';
       // the partner, drawn the way a window draws the other player
       fk={x:g.player.x+40,y:g.player.y,f:0,seat:1,hp:100,mh:100,lk:{},roll:0,bob:0,n:1};
       n0=RIM.n; wc.save(); try{ netUpDrawOne(fk); } finally{ wc.restore(); }
       if(!(RIM.n>n0)) return 'the partner body was drawn with no outline stamp';
       // the box in reach is outlined through drawUseOutline
       for(i=0;i<g.containers.length;i++){ if(!g.containers[i].opened&&g.containers[i].type!=='body'){ ct=g.containers[i]; break; } }
       if(!ct) return 'SKIP: no box';
       g.nearContainer=ct;
       PR.strokeRect=function(){ if((/drawUseOutline/).test(String(new Error().stack))) hit++; return osr.apply(this,arguments); };
       wc.save(); try{ drawUseOutline(ct,40,0,20); } finally{ wc.restore(); }
       PR.strokeRect=osr;
       if(!hit) return 'the box in reach was not outlined';
       g.nearContainer=null; hit=0;
       PR.strokeRect=function(){ if((/drawUseOutline/).test(String(new Error().stack))) hit++; return osr.apply(this,arguments); };
       wc.save(); try{ drawUseOutline(ct,40,0,20); } finally{ wc.restore(); }
       PR.strokeRect=osr;
       if(hit) return 'a box out of reach was outlined';
       return null;
     } finally {
       PR.strokeRect=osr;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
