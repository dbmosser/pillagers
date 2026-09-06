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

# v11.85 CHECK, inserted before the v11.84 entry. Every fillText the map
# overlay makes is recorded with the font in force, and the extraction
# names and their countdown lines are measured in rendered pixels.
SubRx @'
  {v:'11.84',what:'a Meridian Lance round travels through crawlers, hitting each one on the line once with its full damage, while a rifle round still stops at the first (his note of 2026-09-06)',
'@ @'
  {v:'11.85',what:'the map names each extraction at 18px or more and counts down to its close at 15px or more, one row each above the ring, instead of both in the smallest face the game has (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map overlay in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], rec=[], proto=CanvasRenderingContext2D.prototype, orig=proto.fillText;
     proto.fillText=function(t){ try{ rec.push({t:String(t),font:this.font}); }catch(_r){} return orig.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.mapOpen=true;
       drawMapOverlay();
       function px(f){ var m=/([\d.]+)px/.exec(f||''); return m?parseFloat(m[1]):0; }
       var names=rec.filter(function(r){ return r.t.indexOf('EXTRACT ')===0&&r.t.length<=10; });
       var subs=rec.filter(function(r){ return /^(closes in |STAYS OPEN|CLOSED|CALLED |OPEN TO EXTRACT)/.test(r.t); });
       if(!names.length) bad.push('control: the map drew no EXTRACT name');
       if(!subs.length) bad.push('control: the map drew no countdown or state line under a ring');
       var smallN=names.filter(function(r){ return px(r.font)<18; }), smallS=subs.filter(function(r){ return px(r.font)<15; });
       if(smallN.length) bad.push(smallN.length+' extraction name(s) drawn at '+px(smallN[0].font)+'px, under 18');
       if(smallS.length) bad.push(smallS.length+' countdown line(s) drawn at '+px(smallS[0].font)+'px, under 15 ("'+smallS[0].t+'")');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=orig; try{ var g2=__state(); if(g2) g2.mapOpen=false; }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.84',what:'a Meridian Lance round travels through crawlers, hitting each one on the line once with its full damage, while a rifle round still stops at the first (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
