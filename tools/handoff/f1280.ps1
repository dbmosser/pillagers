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

# v12.80 CHECK, inserted before the v12.79 entry. It puts the cover-ground
# contract on the profile with distance on the clock and reads the panel the way
# he does, off the canvas. Two controls: another conduct contract in the same
# state must still print its note, so the guard has not silenced the whole panel,
# and the contract must still complete on the distance it always did, so deleting
# a line has not quietly deleted the work.
SubRx @'
  {v:'12.79',what:'the full key panel is keys: every binding in the key table is still drawn and not one gear rule or sound colour label is, while the compact corner legend still draws its keys (his note, after a live round)',
'@ @'
  {v:'12.80',what:'the cover ground contract prints no line of its own on the in-raid panel, since its number was raw world units nothing else in the game uses, while another conduct contract in the same state still prints its note and the contract itself still completes on the same distance (his note, after a live round)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P&&window.__frame&&window.__textTrace&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and read the drawn text';
     var bad=[], P2=__P(), keepC=(P2.contracts||[]).slice();
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_f){}
       if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be drawn';
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g.ents.length=0; g.player.downed=false;
       function shown(card,dist){
         P2.contracts=[card];
         try{ if(g.tel) g.tel.distance=dist; }catch(_d){}   // T is G.tel, no hook needed
         var lines=[]; try{ lines=__textTrace(function(){ __frame(0.016); }); }catch(_t){ return ''; }
         var t=''; for(var i=0;i<lines.length;i++) t+=' | '+lines[i].t;
         return t;
       }
       // THE FINDING: the cover-ground card, part way along, says nothing that
       // quotes a number he cannot read.
       var far={type:'conduct',ck:'far',n:1,prog:0,reward:900,desc:'Cover ground'};
       var tFar=shown(far,2000);
       if(!tFar) return 'SKIP: the panel drew no text at all, so there is nothing here to read';
       if(tFar.indexOf('14k')>=0||/\dk of /.test(tFar))
         bad.push('the in-raid panel still quotes the cover ground contract in raw world units, which is the one unit nothing else in the game uses and he has no way to read');
       // CONTROL ONE: another conduct card in the same place must still speak, or
       // the guard has silenced the panel rather than one line.
       var steady={type:'conduct',ck:'steady',n:1,prog:0,reward:900,desc:'Stay up'};
       var tSteady=shown(steady,2000);
       if(tSteady.toLowerCase().indexOf('down')<0)
         bad.push('control: another conduct contract in the same state now prints nothing either, so this build has silenced the panel and not one line');
       // CONTROL TWO: the work itself is untouched.
       if(typeof conductMet==='function'&&g.tel){
         g.tel.distance=14000;
         if(!conductMet('far')) bad.push('control: the cover ground contract no longer completes on the distance it always completed on, so deleting its line deleted the work');
         g.tel.distance=100;
         if(conductMet('far')) bad.push('control: the cover ground contract now completes on any distance at all');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.contracts=keepC; saveProfile(); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.79',what:'the full key panel is keys: every binding in the key table is still drawn and not one gear rule or sound colour label is, while the compact corner legend still draws its keys (his note, after a live round)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
