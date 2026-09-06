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

# v11.98 CHECK, inserted before the v11.97 entry. A ring is put into the
# hold state and the map overlay drawn with the canvas text call recorded.
SubRx @'
  {v:'11.97',what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 40 (230 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)',
'@ @'
  {v:'11.98',what:'the sector map says EXTRACT NOW with the seconds left under a landed ring, the banner wording, instead of OPEN TO EXTRACT (2026-09-06 review of v11.74)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map overlay in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], rec=[], proto=CanvasRenderingContext2D.prototype, orig=proto.fillText;
     var oldWords='OPEN TO '+'EXTRACT', newWords='EXTRACT '+'NOW';
     proto.fillText=function(t){ try{ rec.push(String(t)); }catch(_r){} return orig.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g.zones||!g.zones.length) return 'SKIP: no extraction ring';
       var Z=g.zones[0]; Z.open=true; Z.beaconT=0; Z.hold=12; g.active=Z; g.mapOpen=true;
       drawMapOverlay();
       var subs=rec.filter(function(t){ return t.indexOf(oldWords)===0||t.indexOf(newWords)===0; });
       if(!subs.length) bad.push('control: the map drew no boarding line under the landed ring');
       if(subs.some(function(t){ return t.indexOf(oldWords)===0; })) bad.push('the map still says '+oldWords+' under a landed ring ("'+subs[0]+'")');
       if(!subs.some(function(t){ return t.indexOf(newWords)===0&&/12S LEFT/.test(t); })) bad.push('the map does not say '+newWords+' with the seconds left (drew: '+subs.join(' | ').slice(0,80)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=orig; try{ var g2=__state(); if(g2){ g2.mapOpen=false; } }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.97',what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 40 (230 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
