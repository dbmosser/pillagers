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

# v12.27 CHECK, inserted before the v12.26 entry. The kept-aside record the
# kit button writes is staged, commitKit is driven for real (the free branch),
# a live raid is ended dead, and the plan and gun slot must be back with the
# packing, minus the key on an item sold during the run. Control: a clean
# extraction restores neither, the v6.88 rule.
SubRx @'
  {v:'12.26',what:'Q moves the belt highlight to the throwable it makes ready, so the cell the belt lights is the one the trigger cooks; with an empty pouch it says No throwables and moves nothing (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.27',what:'a free-kit run that ends dead gives back the tactical belt plan and the gun slot with the packing, minus a key whose item did not come back; a clean extraction restores neither, as before (the v12.13 not-verified line)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof commitKit!=='function') return 'SKIP: no commitKit in this build';
     var bad=[];
     function freeRun(how){
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       P.stash=['medkit','plate','frag']; P.kit=[];
       P.freeKit=1; P.kitSaved={kit:['medkit','plate'],hot:{2:'medkit',5:'plate'},gun:'probe-slot'}; P.hotAssign={}; P._gunSlot=null;
       if(!commitKit()) bad.push('control: commitKit refused the free kit');
       if(!P.kitBeforeFree||P.kitBeforeFree.join(',')!=='medkit,plate') bad.push('control: the lift did not keep the packing aside ('+(P.kitBeforeFree||[]).join(',')+')');
       P.stash=['medkit','frag'];   // the plate is gone by the end of the run, so its key must not come back
       var g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid(how); }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       freeRun('dead');
       if((P.kit||[]).join(',')!=='medkit') bad.push('control: the packing did not come back minus the plate (kit '+(P.kit||[]).join(',')+')');
       if(!P.hotAssign||P.hotAssign[2]!=='medkit') bad.push('the belt key on the Medkit did not come back with the packing (plan '+JSON.stringify(P.hotAssign||{})+')');
       if(P.hotAssign&&P.hotAssign[5]) bad.push('a key on the plate came back although the plate did not');
       if(P._gunSlot!=='probe-slot') bad.push('the gun slot did not come back ('+P._gunSlot+')');
       if(P.planBeforeFree) bad.push('the kept-aside plan was not cleared after the restore');
       __topClear();
       // CONTROL: a clean extraction restores neither, the v6.88 rule.
       freeRun('extract');
       if(P.hotAssign&&P.hotAssign[2]) bad.push('control: an extraction restored the belt plan');
       if(P.planBeforeFree) bad.push('the kept-aside plan survived an extraction');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} try{ P.freeKit=0; P.kitSaved=null; P.kitBeforeFree=null; P.planBeforeFree=null; P._gunSlot=null; }catch(_p){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.26',what:'Q moves the belt highlight to the throwable it makes ready, so the cell the belt lights is the one the trigger cooks; with an empty pouch it says No throwables and moves nothing (2026-09-06 in-raid audit)',
'@

# HARNESS REPAIRS riding with v12.27 (the leftovers list in START-HERE):
# 11.88 read the SAVED HUD layout, so a CONDITIONS panel an earlier check had
# collapsed turned it into a SKIP; it pins an empty layout and restores it.
# 11.85 measured font sizes without pinning the pane, so a resized pane could
# change its numbers; it pins 1920x1080 like its neighbours. 11.81 let an
# extraction bank forty seconds of cutting into the saved profile and left it
# there for every later check; it restores the seals it found.
SubRx @'
     var bad=[], P2=__P(), keepC=P2.contracts, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText;
'@ @'
     var bad=[], P2=__P(), keepC=P2.contracts, keepH=P2.hud, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText;
'@
SubRx @'
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __forceSize(1920,1080);
       P2.contracts=[
'@ @'
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __forceSize(1920,1080);
       P2.hud={};   // v12.27 harness: a CONDITIONS panel an earlier check collapsed in the saved layout would turn this into a SKIP
       P2.contracts=[
'@
SubRx @'
       proto.fillText=o; P2.contracts=keepC; try{ saveProfile(); }catch(_s){}
'@ @'
       proto.fillText=o; P2.contracts=keepC; P2.hud=keepH; try{ saveProfile(); }catch(_s){}
'@
SubRx @'
     proto.fillText=function(t){ try{ rec.push({t:String(t),font:this.font}); }catch(_r){} return orig.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
'@ @'
     proto.fillText=function(t){ try{ rec.push({t:String(t),font:this.font}); }catch(_r){} return orig.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); if(window.__forceSize) __forceSize(1920,1080);   // v12.27 harness: the font sizes below are measured at one pane size
'@
SubRx @'
     var bad=[], lost='seconds of '+'cutting, lost', banked='Seal '+'cut ';
'@ @'
     var bad=[], lost='seconds of '+'cutting, lost', banked='Seal '+'cut ', keepS=JSON.stringify(__P().seals===undefined?null:__P().seals);   // v12.27 harness: the extraction below banks a seal into the saved profile
'@
SubRx @'
       __endRaid('extract');
       var t2=card();
'@ @'
       __endRaid('extract');
       var t2=card();
       try{ var _ks=JSON.parse(keepS); if(_ks===null) delete __P().seals; else __P().seals=_ks; }catch(_kse){}   // v12.27 harness: the banked seal does not outlive the check
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
