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

if ($s.Contains("  {v:'21.15',what:")) { throw "check 21.15 is in the fixture already" }

SubRx @'
  {v:'21.14',what:
'@ @'
  {v:'21.15',what:'on the map a called ring and a ring in progress still show when they close, beside the call or the hold',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawMapOverlayRaw!=='function') return 'SKIP: no map here';
     var bad=[], g, Z=null, i, keep=[], texts=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, ml0;
     function draw(){ texts=[]; ml0=MAPLAST; MAPLAST=[]; try{ drawMapOverlayRaw(); }finally{ MAPLAST=ml0; } return texts; }
     function closes(){ return texts.filter(function(t){ return t.indexOf('closes in ')===0; }).length; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.zones||!g.zones.length) return 'SKIP: no live raid with rings';
       for(i=0;i<g.zones.length;i++){ keep.push({Z:g.zones[i],open:g.zones[i].open,ca:g.zones[i].closeAt,bt:g.zones[i].beaconT,h:g.zones[i].hold}); if(!Z&&g.zones[i].open!==false) Z=g.zones[i]; }
       if(!Z) return 'SKIP: staging: no open ring';
       for(i=0;i<g.zones.length;i++) if(g.zones[i]!==Z) g.zones[i].closeAt=undefined;
       Z.closeAt=Math.max(1,(g.timeLeft||300)-157);
       ctx.fillText=function(s){ texts.push(String(s)); };
       Z.beaconT=8; Z.hold=null; g.active=Z;
       draw();
       if(!texts.some(function(t){ return t.indexOf('CALLED')===0; })) return 'SKIP: staging: the called ring was not drawn as called';
       if(closes()!==1) bad.push('a called ring does not show when it closes ('+closes()+' closing lines)');
       Z.beaconT=0; Z.hold=9;
       draw();
       if(closes()!==1) bad.push('a ring with an extraction in progress does not show when it closes ('+closes()+' closing lines)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) ctx.fillText=of; else delete ctx.fillText;
       keep.forEach(function(k){ k.Z.open=k.open; k.Z.closeAt=k.ca; k.Z.beaconT=k.bt; k.Z.hold=k.h; });
       try{ var g2=__state(); if(g2&&!g2.over){ g2.active=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
