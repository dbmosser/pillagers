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

SubRx @'
  {v:'11.07',what:'a crawler close enough to bite you has found you
'@ @'
  {v:'11.08',what:'the sound key teaches the colours the game actually draws, and none it never draws',
   run:function(){
     if(typeof SOUNDKEY==='undefined'||typeof SNDCOL==='undefined')
       return 'SKIP: this build has no sound key';
     var bad=[], i, j;
     // 1. EVERY SWATCH IS A COLOUR THE GAME REALLY USES. Measured on v11.07 the
     //    key carried #e65100 for pillager firing, an orange the game stopped
     //    drawing at v9.63 on his own word, RED, and has drawn #ff3b30 since.
     var live={}, k, t;
     for(k in SNDCOL) for(t in SNDCOL[k]) live[String(SNDCOL[k][t]).toLowerCase()]=k+' '+t;
     for(i=0;i<SOUNDKEY.length;i++){
       var col=String(SOUNDKEY[i][0]||'').toLowerCase();
       if(!col){ bad.push('the sound key row "'+SOUNDKEY[i][1]+'" has no colour at all'); continue; }
       if(!live[col]) bad.push('the sound key shows '+col+' for "'+SOUNDKEY[i][1]+'" and the game never draws that colour');
     }
     // 2. AND IT DOES NOT PROMISE A RING THAT CANNOT EXIST. ping refuses to draw
     //    the player's own noises, so a row telling him a colour means HIM is
     //    teaching him to look for something that never appears.
     var labels=[];
     for(i=0;i<SOUNDKEY.length;i++) labels.push(String(SOUNDKEY[i][1]).toLowerCase());
     var joined=labels.join(' | ');
     if(/(^|\| )you( \||$)/.test(joined))
       bad.push('the sound key still has a row that says a ring can be you, and your own noises have drawn no ring since v5.31');
     // 3. AND IT SAYS SO, which is his question answered where it is asked.
     if(joined.indexOf('never your own')<0)
       bad.push('the sound key does not say that a ring is never your own noise, which is the rule he asked about');
     // 4. CONTROLS. The colour table has to have been read at all, and the key
     //    has to still cover the four things that make noises he can be hurt by.
     var n=0; for(k in live) n++;
     if(n<4) bad.push('control: only '+n+' colours were found in the colour table, so this is not checking the game');
     var need=['machine moving','machine firing','pillager moving','pillager firing'];
     for(i=0;i<need.length;i++) if(joined.indexOf(need[i])<0)
       bad.push('control: the sound key no longer explains '+need[i]);
     // 5. AND THE PANEL STILL FITS. A key that teaches the colours by covering
     //    the belt has traded one problem for another.
     if(window.__deploy&&window.__state&&window.__frame&&window.__hud&&__vpAlive()){
       __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.legendOn=1;
       var threw=null;
       try{ __frame(0); __hud(); }catch(e){ threw=String(e&&e.message||e); }
       if(threw) bad.push('drawing the legend threw: '+threw);
       var rows=SOUNDKEY.length;
       if(rows>8) bad.push('the sound key has grown to '+rows+' rows, which is taller than the panel was measured for');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.07',what:'a crawler close enough to bite you has found you
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
