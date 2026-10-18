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

if ($s.Contains("  {v:'31.35',what:")) { throw "check 31.35 is in the fixture already" }

SubRx @'
  {v:'31.34',what:
'@ @'
  {v:'31.35',what:'the career gun card reads name, ammo, then one quiet row with the backpack hint on the left (it is not above the gun name), and no run info row runs past the panel edge',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||!window.__textTrace||typeof careerPostBuild!=='function') return 'SKIP: no raid here';
     var bad=[], g, tr, i, hint, nm, e, D, B, nme;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       try{ careerPostBuild(g); }catch(_c){}
       g.arcade=0; g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       for(i=0;i<4;i++) __frame(0.016);
       tr=__textTrace(function(){ __frame(0.016); });
       nme=String(g.player.wep.name).toUpperCase();
       tr.forEach(function(x){ var t=x.t.toUpperCase(); if(/\S\s+BACKPACK$/.test(t)) hint=x; if(t.indexOf(nme)===0&&x.align==='right'&&x.px>=18) nm=x; });
       if(!hint) bad.push('the backpack hint is not drawn');
       else if(!nm) bad.push('the gun name is not drawn');
       else {
         if(!(hint.y>nm.y)) bad.push('the backpack hint (y '+Math.round(hint.y)+') is still above the gun name (y '+Math.round(nm.y)+')');
         if(hint.align!=='left') bad.push('the backpack hint is not on the left of the bottom row');
       }
       D=(typeof DPRH!=='undefined'&&DPRH)||1; B=HUDBOX.cond;
       if(B){ tr.forEach(function(x){ if(x.align==='left'&&x.y>=B.y*D&&x.y<=(B.y+B.h)*D&&x.x>=B.x*D&&x.x<=(B.x+B.w)*D&&x.x+x.w>(B.x+B.w)*D-2) bad.push('a run info row runs past the panel edge ('+x.t+')'); }); }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.arcade=0; g2.career=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
