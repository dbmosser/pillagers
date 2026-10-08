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

if ($s.Contains("  {v:'19.60',what:")) { throw "check 19.60 is in the fixture already" }

SubRx @'
  {v:'19.59',what:
'@ @'
  {v:'19.60',what:'the door prompt dodges at the size it is drawn: at 4K the corner readout test is given the prompt at its grown width',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof hudDodge!=='function') return 'SKIP: no dodge here';
     var bad=[], g, p, LK, hd=hudDodge, oFT=ctx.fillText, hws=[], lw=0, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       LK=(g.map&&g.map.locked&&g.map.locked[0])||null; if(!LK) return 'SKIP: no locked door on this map';
       p.x=LK.doorX; p.y=LK.doorY+30;
       for(k=0;k<10;k++){ g.nearDoor=LK; __frame(0.05); }
       hudDodge=function(x,y,hw){ hws.push(hw); return hd.apply(this,arguments); };
       ctx.fillText=function(t){ var s=String(t); if(s.indexOf(LK.name)>=0&&!lw) lw=ctx.measureText(s).width; return oFT.apply(this,arguments); };
       g.nearDoor=LK; __frame(0.05);
       if(!hws.length||!lw) return 'SKIP: the door prompt was not drawn';
       if(hws.some(function(h){ return Math.abs(h-(lw/2+6))<1; })) bad.push('at 4K the door prompt is dodge-tested at its 1080p width '+Math.round(lw+12)+' while drawn about '+Math.round((lw+12)*2)+' wide'); if(!hws.some(function(h){ return Math.abs(h-(lw/2+6)*2)<2; })) bad.push('no dodge test at the drawn door prompt width');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudDodge=hd; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2){ g2.nearDoor=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
