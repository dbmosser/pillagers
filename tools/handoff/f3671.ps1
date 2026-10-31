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

if ($s.Contains("  {v:'36.71',what:")) { throw "check 36.71 is in the fixture already" }

SubRx @'
  {v:'36.70',what:
'@ @'
  {v:'36.71',what:'the cooked grenade warning stays over your head and never becomes a feed line',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof cookShout!=='function') return 'no cooked grenade shout';
     var bad=[], g=null, p, ft, shown=0, n0, i, hit, PR=CanvasRenderingContext2D.prototype, of=PR.fillText;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; feedS(); n0=g.fd.lines.length;
       p.cooking=1; p.cookKind='frag'; p.cookT=FRAG_FUSE-0.5;
       PR.fillText=function(t){ if(/COOKED GRENADE/i.test(String(t))) shown++; return of.apply(this,arguments); };
       for(i=0;i<8;i++){ try{ drawHUD(); }catch(_d){} }
       PR.fillText=of;
       hit=0; for(i=0;i<g.fd.lines.length;i++) if(/cooked grenade/i.test(String(g.fd.lines[i].txt))) hit++;
       if(hit) bad.push('the cooked grenade warning is a feed line ('+hit+')');
       if(!shown) bad.push('the warning no longer flashes over his own head while he holds the frag');
       if(!cookShout({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-0.5})) bad.push('cookShout lost its last second');
       if(cookShout({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-2})||cookShout({cooking:1,cookKind:'smoke',cookT:5})) bad.push('control: a grenade not yet in its last second shouts');
       p.cooking=0; p.cookT=0; p.cookKind=null;
       for(i=0;i<8;i++){ try{ drawHUD(); }catch(_d){} }
       hit=0; for(i=0;i<g.fd.lines.length;i++) if(/cooked grenade/i.test(String(g.fd.lines[i].txt))) hit++;
       if(hit) bad.push('a feed line about a cooked grenade with nothing in hand');
       return bad.length?bad.join('; '):null;
     } finally {
       PR.fillText=of;
       try{ if(g&&g.player){ g.player.cooking=0; g.player.cookT=0; g.player.cookKind=null; } }catch(_c){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
