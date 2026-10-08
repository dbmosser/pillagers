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

if ($s.Contains("  {v:'20.27',what:")) { throw "check 20.27 is in the fixture already" }

SubRx @'
  {v:'20.26',what:
'@ @'
  {v:'20.27',what:'a shot on a weak point registers: a round coming straight at a Sentry vent from behind it counts as a vent hit at the moment it touches the body, and one coming from the front through the body does not',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof weakHit!=='function'||typeof weakOf!=='function'||typeof weakPos!=='function') return 'SKIP: no weak points here';
     var bad=[], g, e=null, L, W=null, i, pt, ux, uy, n, bx, by, h1, h2;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++){ L=weakOf(g.ents[i]); if(L&&L.length){ e=g.ents[i]; break; } }
       if(!e) return 'SKIP: no machine with weak points';
       for(i=0;i<L.length;i++) if(!W||L[i].rf*e.r+L[i].rad>W.rf*e.r+W.rad) W=L[i];
       pt=weakPos(e,W); ux=pt.x-e.x; uy=pt.y-e.y; n=Math.sqrt(ux*ux+uy*uy)||1; ux/=n; uy/=n;
       bx=e.x+ux*(e.r+2.5); by=e.y+uy*(e.r+2.5);
       h1=weakHit(e,bx,by,-ux,-uy);
       if(!h1) bad.push('a straight shot at the '+W.name+' from behind it did not register');
       bx=e.x-ux*(e.r+2.5); by=e.y-uy*(e.r+2.5);
       h2=weakHit(e,bx,by,ux,uy);
       if(h2===W) bad.push('a shot from the far side reached the '+W.name+' through the body');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
