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

if ($s.Contains("  {v:'18.60',what:")) { throw "check 18.60 is in the fixture already" }

SubRx @'
  {v:'18.59',what:
'@ @'
  {v:'18.60',what:'the compact legend names the keys as set and never runs a key into its word: CTRL / C ends before crouch begins, and with search moved to G the legend says G',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof keysBind!=='function') return 'SKIP: no key binding here';
     var bad=[], g, oFT=ctx.fillText, rec=[], km=(P&&P.keymap)?JSON.parse(JSON.stringify(P.keymap)):null, oSave=saveProfile, oPad=padOn, k, c, i;
     function grab(){ rec=[]; ctx.fillText=function(s,x,y){ rec.push({s:String(s),x:x,y:y,w:ctx.measureText(String(s)).width}); return oFT.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       saveProfile=function(){}; padOn=function(){ return false; }; PAD.on=false;
       P.keymap={}; KEYS.inv=null;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.legendOn=1; g.bagOpen=false; g.mapOpen=false;
       __frame(0.016); grab();
       k=rec.filter(function(r){ return r.s==='CTRL / C'; })[0]; c=rec.filter(function(r){ return r.s==='crouch'; })[0];
       if(!k||!c) return 'SKIP: the compact legend was not drawn';
       if(c.x<k.x+k.w+1) bad.push('CTRL / C (ends at '+Math.round(k.x+k.w)+') runs into crouch (starts at '+Math.round(c.x)+')');
       keysBind('KeyE','KeyG'); grab();
       for(i=1;i<rec.length;i++) if(rec[i].s==='search'){ if(rec[i-1].s!=='G') bad.push('with search on G the legend says '+rec[i-1].s); break; }
       if(i>=rec.length) bad.push('control: no search row was drawn');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; saveProfile=oSave; padOn=oPad; if(P){ if(km) P.keymap=km; else delete P.keymap; } KEYS.inv=null; try{ keysInv(); keysLegendApply(); }catch(_k){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
