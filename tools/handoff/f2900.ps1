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

if ($s.Contains("  {v:'29.00',what:")) { throw "check 29.00 is in the fixture already" }

SubRx @'
  {v:'28.99',what:
'@ @'
  {v:'29.00',what:'a mimic box: the crawler is named MIMIC, comes out on the far side of the box from the player and holds its bite, and the box is spent and spins away in a void swirl (his order: pops out AWAY, different name, disappear-into-the-void swirl)',
   run:function(){
     if(typeof __frame!=='function'||typeof mimicWake!=='function'||typeof drawMimicVoid!=='function'&&false) return 'SKIP: no frame or mimic helper';
     var g=null, ct=null, p=null, i, c, n0, dx, dy, sw=0, ow=null, ctx;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c.type==='crate'&&!c.opened&&spotFree(g.map,c.x-34,c.y,12)&&spotFree(g.map,c.x+60,c.y,12)){ ct=c; break; } }
       if(!ct) return 'SKIP: no crate with free ground on both sides';
       g.ents=[]; p.x=ct.x+60; p.y=ct.y; ct.mim=1; ct.mimicDone=0; ct.mimicWake=0; ct.prog=0;
       n0=g.ents.length; mimicWake(ct);
       c=g.ents[g.ents.length-1];
       if(g.ents.length<=n0||!c||!c.mimic) return 'the mimic woke but no crawler came up';
       if(!/^MIMIC/.test(String(c.name))) return 'the crawler out of the box is called '+c.name+', not MIMIC';
       dx=(c.x-ct.x)*(p.x-ct.x)+(c.y-ct.y)*(p.y-ct.y);
       if(!(dx<0)) return 'the mimic crawler came out on the player side of the box (at '+Math.round(c.x-ct.x)+','+Math.round(c.y-ct.y)+' from the box, player at +60,0)';
       if(!(c.cd>0)) return 'the mimic crawler can bite the moment it is out';
       if(!ct.opened||(ct.loot&&ct.loot.length)) return 'the mimic box is still a searchable box';
       if(!(ct.mimicVoid>0)) return 'the mimic box has no void swirl';
       ctx=CanvasRenderingContext2D.prototype; ow=ctx.fill;
       ctx.fill=function(){ if(String(this.fillStyle).toLowerCase()==='#08001a') sw++; return ow.apply(this,arguments); };
       p.x=ct.x+60; p.y=ct.y;
       if(g.cam){ g.cam.x=ct.x; g.cam.y=ct.y; }
       for(i=0;i<8&&!sw;i++) __frame();
       ctx.fill=ow; ow=null;
       if(!sw) return 'the spent mimic box drew no void swirl';
       for(i=0;i<120;i++) mimicTick(1/60);
       if(ct.mimicVoid>0) return 'the void swirl never ended';
       return null;
     } finally {
       try{ if(ow) CanvasRenderingContext2D.prototype.fill=ow; }catch(_e0){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
