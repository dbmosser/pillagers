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

if ($s.Contains("  {v:'35.46',what:")) { throw "check 35.46 is in the fixture already" }

SubRx @'
  {v:'35.45',what:
'@ @'
  {v:'35.46',what:'cw-cx-walletframe: drawing the corner clips the page wallet in that same frame, even after an old stamp, with no wallet rows and with empty or full backpacks',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__textTrace)||typeof trColDraw!=='function') return 'SKIP: no corner renderer';
     var bad=[], g=null, had=document.body.classList.contains('trcol'), h0=TRG.hid, t0=TRG.t, c0=P.credits;
     function sample(label,frame){
       var el=document.getElementById('topright');
       if(!el){ bad.push('missing page wallet'); return; }
       document.body.classList.remove('trcol'); TRG.hid=0; TRG.t=-1e9;
       var tr=__textTrace(function(){ if(frame) __frame(0.016); else trColDraw(); });
       if(!document.body.classList.contains('trcol')||getComputedStyle(el).clipPath==='none') bad.push(label+': page wallet is visible in the newly drawn frame');
       var cash='$'+(P.credits||0).toLocaleString();
       if(tr.some(function(t){ return t.t===cash&&t.x>W*0.65&&t.y<H*0.22; })) bad.push(label+': obsolete canvas cash row returned');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live career raid';
       if(typeof mapFirstEnd==='function'&&g.mapFirst) mapFirstEnd('fixture');
       g.mapOpen=false; g.bagOpen=false; g.rise=null; g.ents=[]; g.tel=g.tel||{}; g.tel.notes=[];
       P.credits=4471337; syncTopRight();
       g.bag=[]; sample('empty bag, direct corner',false); sample('empty bag, rendered frame',true);
       g.bag=['medkit','medkit','bandage','frag','frag','frag']; syncTopRight();
       sample('full bag, direct corner',false); sample('full bag, rendered frame',true);
       g.tel.notes=[{t:1,txt:'fixture note'}]; sample('notes row',false);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&!g.over){ g.career=0; g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile(); P.credits=c0; syncTopRight(); TRG.hid=h0; TRG.t=t0; document.body.classList.toggle('trcol',had);
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
