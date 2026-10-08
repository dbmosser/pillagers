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

if ($s.Contains("  {v:'20.12',what:")) { throw "check 20.12 is in the fixture already" }

SubRx @'
  {v:'20.11',what:
'@ @'
  {v:'20.12',what:'pillagers wear their own look: a pillager in a raid is drawn in the hair, skin and build he was given at spawn, not the default',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, r=null, od=drawOp, seen=null, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&g.ents[i].hp>0&&g.ents[i].skin){ r=g.ents[i]; break; }
       if(!r) return 'SKIP: no pillager with a look in this raid';
       r.build=r.build||'curved'; r.downed=false;
       g.player.x=r.x+40; g.player.y=r.y+40; g.player.iv=99;
       drawOp=function(x,y,f,ph,co,pk,mu,mode,iv,st){ if(st&&st.own===r) seen=st; return od.apply(this,arguments); };
       for(i=0;i<6&&!seen;i++) __frame(0.05);
       drawOp=od;
       if(!seen) return 'SKIP: the pillager was not drawn';
       if(seen.skin!==r.skin||seen.hair!==r.hair) bad.push('the pillager is drawn without his look (skin '+seen.skin+' for '+r.skin+')');
       if(seen.build!==r.build) bad.push('the pillager is drawn without his build');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ drawOp=od; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
