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

# v12.79 CHECK, inserted before the v12.78 entry. It opens the real panel in a
# real raid and reads the text the frame actually writes. Nothing is named here:
# the rows it requires come out of the key table and the rows it forbids come out
# of the two tip tables, so editing any of those three moves the check with them
# instead of leaving it asserting a phrase that no longer exists.
SubRx @'
  {v:'12.78',what:'a gun he chose is not swapped out behind his back: with a real weapon in each hand a better find goes to the backpack and both hands are untouched, while the Scav Pistol is still always booted for something better and an empty second slot still takes it (his note, after a live round)',
'@ @'
  {v:'12.79',what:'the full key panel is keys: every binding in the key table is still drawn and not one gear rule or sound colour label is, while the compact corner legend still draws its keys (his note, after a live round)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__textTrace&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and read the drawn text';
     if(typeof LEGEND==='undefined'||typeof GEARRULES==='undefined'||typeof SOUNDKEY==='undefined') return 'SKIP: this build has no key table or no tip tables to tell apart';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_f){}
       if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be drawn';
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to open the panel in';
       g.ents.length=0; g.player.downed=false;
       function drawn(mode){
         g.legendOn=mode;
         var lines=[]; try{ lines=__textTrace(function(){ __frame(0.016); }); }catch(_t){ return ''; }
         var t=''; for(var i=0;i<lines.length;i++) t+=' | '+lines[i].t;
         return t;
       }
       var full=drawn(2);
       if(!full) return 'SKIP: the full panel drew no text at all, so there is nothing here to read';
       // EVERY BINDING IS STILL THERE. Taken out of the key table, not named.
       var LEG=(typeof PAD!=='undefined'&&PAD&&PAD.on)?LEGEND_PAD:LEGEND, i, j, missing=0, firstMiss='';
       for(i=0;i<LEG.length;i++) for(j=0;j<LEG[i][1].length;j++){
         var lbl=String(LEG[i][1][j][0]||'');
         if(lbl&&full.indexOf(lbl)<0){ missing++; if(!firstMiss) firstMiss=lbl; }
       }
       if(missing)
         bad.push(missing+' of his key bindings are no longer drawn on the full panel, the first being ['+firstMiss+'], so this build has taken away the thing he opens it for');
       // AND NOT ONE LINE OF TIPS. Taken out of the tip tables, not named.
       var tips=0, firstTip='';
       for(i=0;i<GEARRULES.length;i++){
         var gr=GEARRULES[i], rule=(typeof gr[1]==='function')?gr[1]():gr[1];
         rule=String(rule||'');
         if(rule.length>8&&full.indexOf(rule)>=0){ tips++; if(!firstTip) firstTip=rule; }
       }
       for(i=0;i<SOUNDKEY.length;i++){
         var sl=String(SOUNDKEY[i][1]||'');
         if(sl.length>4&&full.indexOf(sl)>=0){ tips++; if(!firstTip) firstTip=sl; }
       }
       if(tips)
         bad.push(tips+' lines of tips are still drawn beside his keys, the first being ['+firstTip.slice(0,60)+']: he opened this to read the bindings and the tip column is taller than the bindings are, so it was setting the size of the panel');
       // CONTROL: the compact corner legend is a different thing and is untouched.
       var small=drawn(1);
       var got=0;
       for(i=0;i<LEG.length&&got===0;i++) for(j=0;j<LEG[i][1].length;j++){
         if(small.indexOf(String(LEG[i][1][j][0]||''))>=0){ got=1; break; }
       }
       if(!got)
         bad.push('control: the compact corner legend now draws none of his keys either, so this build has emptied that panel as well');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.legendOn=1; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.78',what:'a gun he chose is not swapped out behind his back: with a real weapon in each hand a better find goes to the backpack and both hands are untouched, while the Scav Pistol is still always booted for something better and an empty second slot still takes it (his note, after a live round)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
