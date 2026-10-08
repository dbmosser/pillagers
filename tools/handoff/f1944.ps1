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

if ($s.Contains("  {v:'19.44',what:")) { throw "check 19.44 is in the fixture already" }

SubRx @'
  {v:'19.43',what:
'@ @'
  {v:'19.44',what:'the raider board holds its summary line: with pillagers down, the out and down line sits inside the board panel, clear of its bottom edge',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawRaiderBoard!=='function'||typeof hudPanel!=='function') return 'SKIP: no raider board here';
     var bad=[], g, oHP=hudPanel, oFT=ctx.fillText, panel=null, sum=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       if(P.hud&&P.hud.raiders) P.hud.raiders.c=0;
       hudPanel=function(x,y,w,h){ if(!panel) panel={y:y,h:h}; return oHP.apply(this,arguments); };
       ctx.fillText=function(t,x,y){ var s=String(t), fm=(/([\d.]+)px/).exec(String(ctx.font)); if(/ out .* down$/.test(s)) sum={y:y,fp:fm?parseFloat(fm[1]):11}; return oFT.apply(this,arguments); };
       ctx.save(); try{ drawRaiderBoard(); } finally { ctx.restore(); }
       if(!panel) return 'SKIP: the board panel was not drawn';
       if(!sum) return 'SKIP: no out and down line (nobody down)';
       if(sum.y+sum.fp*0.25>panel.y+panel.h-1) bad.push('the out and down line reaches '+Math.round(sum.y+sum.fp*0.25)+', past the panel bottom at '+Math.round(panel.y+panel.h));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
