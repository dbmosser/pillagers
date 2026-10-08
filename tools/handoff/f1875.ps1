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

if ($s.Contains("  {v:'18.75',what:")) { throw "check 18.75 is in the fixture already" }

SubRx @'
  {v:'18.74',what:
'@ @'
  {v:'18.75',what:'using a bandage, medkit or plate shows a HUD bar: APPLYING BANDAGE with a bar filled to the wind-up, SLOTTING ARMOUR PLATE above it when both run, and nothing when neither runs',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, oFT=ctx.fillText, rec=[], hasB, hasA, yB=null, yA=null, i;
     function grab(){ rec=[]; ctx.fillText=function(s,x,y){ rec.push({s:String(s),y:y}); return oFT.apply(this,arguments); }; try{ __frame(0.001); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; p.hp=40;
       p.prep=null; p.prepA=null; grab();
       if(rec.some(function(r){ return r.s.indexOf('APPLYING ')===0||r.s.indexOf('SLOTTING ')===0; })) bad.push('control: a use bar was drawn with nothing being used');
       p.prep={t:0.75,max:1.5,kind:'heal',key:'bandage'}; grab();
       hasB=rec.filter(function(r){ return r.s.indexOf('APPLYING BANDAGE')===0; })[0];
       if(!hasB) bad.push('no APPLYING BANDAGE bar on the HUD while a bandage goes on');
       p.prepA={t:0.5,max:2,kind:'armor',key:'plate'}; grab();
       for(i=0;i<rec.length;i++){ if(rec[i].s.indexOf('APPLYING BANDAGE')===0) yB=rec[i].y; if(rec[i].s.indexOf('SLOTTING ARMOUR PLATE')===0) yA=rec[i].y; }
       if(yA===null) bad.push('no SLOTTING ARMOUR PLATE bar while a plate goes on');
       else if(yB!==null&&!(yA<yB)) bad.push('the plate bar does not stack above the bandage bar');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2){ g2.player.prep=null; g2.player.prepA=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
