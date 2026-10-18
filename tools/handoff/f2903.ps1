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

if ($s.Contains("  {v:'29.03',what:")) { throw "check 29.03 is in the fixture already" }

SubRx @'
  {v:'29.02',what:
'@ @'
  {v:'29.03',what:'cw-feedall: all on-screen text goes into the feed: the map story card writes its name and text as feed lines, the last-second cooked grenade shout is a danger line, ACTIVE RELOAD and a bare CLOSE CALL are lines, while WEAK SPOT stays a hit mark',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof feedLabel!=='function'||typeof loreTick!=='function') return 'SKIP: no feed or lore here';
     if(typeof cookFeed!=='function') return 'there is no feed line for the cooked grenade shout';
     var bad=[], g=null, rs=say, n0, r, st0, sr0, hadSt, ln, i, hasN, hasT;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player||!g.map) return 'SKIP: no live raid';
       say=function(){};
       feedS(); n0=g.fd.lines.length;
       st0=g.map.story; sr0=g.storyRead;
       g.map.story={name:'Test Note',text:'Zero one two three.',x:g.player.x,y:g.player.y};
       g.storyRead=0; g.lore=null;
       loreTick(0.01);
       hasN=false; hasT=false;
       for(i=n0;i<g.fd.lines.length;i++){ ln=g.fd.lines[i]; if(ln.txt==='TEST NOTE') hasN=true; if(ln.txt==='Zero one two three.') hasT=true; }
       if(!hasN) bad.push('the lore card name is not a feed line');
       if(!hasT) bad.push('the lore card text is not a feed line');
       g.map.story=st0; g.storyRead=sr0; g.lore=null;
       n0=g.fd.lines.length;
       r=cookFeed({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-0.5});
       if(!r||r.txt!=='COOKED GRENADE! THROW GRENADE NOW') bad.push('the cooked grenade shout is no feed line ('+(r&&r.txt)+')');
       n0=g.fd.lines.length;
       if(cookFeed({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-2})||cookFeed({cooking:1,cookKind:'smoke',cookT:5})||g.fd.lines.length!==n0) bad.push('control: a grenade not yet in its last second made a feed line');
       if(!(/cookFeed\(/).test(String(drawHUD))) bad.push('the HUD draw never calls cookFeed, so the shout is not fed in play');
       r=feedLabel('ACTIVE'+' RELOAD','#9fe8b0');
       if(!r||r.txt!=='ACTIVE'+' RELOAD') bad.push('ACTIVE RELOAD is no feed line');
       r=feedLabel('CLOSE'+' CALL','#ffc04a');
       if(!r||r.txt!=='CLOSE'+' CALL') bad.push('a bare CLOSE CALL is no feed line');
       n0=g.fd.lines.length;
       if(feedLabel('WEAK'+' SPOT','#fff')||feedLabel('PICKED'+' UP','#fff')||g.fd.lines.length!==n0) bad.push('control: a hit mark or PICKED UP made a feed line');
       return bad.length?bad.join('; '):null;
     } finally {
       say=rs;
       try{ if(g&&g.map&&st0!==undefined){ g.map.story=st0; g.storyRead=sr0; g.lore=null; } }catch(_r){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     } }},
  {v:'29.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
