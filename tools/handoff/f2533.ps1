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

if ($s.Contains("  {v:'25.33',what:")) { throw "check 25.33 is in the fixture already" }

SubRx @'
  {v:'25.32',what:
'@ @'
  {v:'25.33',what:'his order (add minimap): a MINIMAP ON/OFF row, on by default; it hides under the map, the backpack, the end cards and in the Undercroft, and grows with the screen',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof ctx==='undefined') return 'SKIP: no raid HUD here';
     if(typeof drawMinimap!=='function'||typeof MMAP!=='object') return 'SKIP: no minimap in this build';
     var bad=[], g, row=null, i, oc=CFG.minimap, os=state, oa=(typeof ARCADE==='object'&&ARCADE)?ARCADE.over:undefined, b1, b2;
     try{
       for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='minimap') row=GAMEOPTS[i];
       if(!row) bad.push('Settings has no MINIMAP row');
       else if(!row.opts[row.def]||row.opts[row.def].cfg.minimap!==1) bad.push('the MINIMAP row is not on by default');
       __topClear(); __runPrep(); __deploy({kit:['gun_carbine'],seed:4242,mapIx:0});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       CFG.minimap=1; drawHUD(); b1=MMAP.box;
       if(!b1) bad.push('MINIMAP ON draws no minimap in a raid');
       else if(Math.abs(b1.w-Math.round(216*hudRes()))>1) bad.push('the minimap is '+b1.w+' wide, not 216 times the screen scale '+hudRes());
       CFG.minimap=0; drawHUD(); b2=MMAP.box;
       if(b2) bad.push('MINIMAP OFF still draws the minimap');
       if(b1&&HUDBOX.cond&&!(HUDBOX.cond.y<b1.y+b1.h)) bad.push('with the minimap off the CONDITIONS panel stays down where the minimap was');
       CFG.minimap=1; delete CFG.minimap; drawMinimap(); if(!MMAP.box) bad.push('a save from before the row (no minimap key) draws no minimap');
       CFG.minimap=1;
       g.mapOpen=true; drawMinimap(); if(MMAP.box) bad.push('the minimap draws under the open sector map'); g.mapOpen=false;
       g.bagOpen=true; drawMinimap(); if(MMAP.box) bad.push('the minimap draws under the open backpack'); g.bagOpen=false;
       if(typeof ARCADE==='object'&&ARCADE){ var oar=g.arcade; g.arcade=oar||1; ARCADE.over={at:Date.now(),why:'test'}; drawMinimap(); if(MMAP.box) bad.push('the minimap draws on the RUN OVER card'); ARCADE.over=oa; g.arcade=oar; }
       var os2=state; state='hub'; drawMinimap(); if(MMAP.box) bad.push('the minimap draws in the Undercroft'); state=os2;
       drawMinimap(); if(!MMAP.box) bad.push('the minimap did not come back after the map, the backpack and the cards');
       __endRaid('abandon'); g=__state();
       if(g&&g.player){ drawMinimap(); if(MMAP.box) bad.push('the minimap draws over the end card'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(oc===undefined) delete CFG.minimap; else CFG.minimap=oc; }catch(_c0){}
       try{ state=os; }catch(_s){} try{ if(typeof ARCADE==='object'&&ARCADE) ARCADE.over=oa; }catch(_a){}
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; g2.bagOpen=false; if(!g2.over) __endRaid('abandon'); } }catch(_e){} try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
