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

if ($s.Contains("  {v:'21.61',what:")) { throw "check 21.61 is in the fixture already" }

SubRx @'
  {v:'21.60',what:
'@ @'
  {v:'21.61',what:'downed in a ring and holding E, the downed screen shows the extraction hold as a bar with its name',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var bad=[], g, p, Z=null, i, said=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, k0;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: staging: no open ring';
       p.x=Z.x; p.y=Z.y; p.downed=true; p.downT=12; p.revived=true; Z.open=true; Z.pullT=0.7; Z.callT=0;
       ctx.fillText=function(t){ said.push(String(t)); return of.apply(this,arguments); };
       drawHUD();
       if(!said.some(function(t){ return t.indexOf('DOWN')===0; })) return 'SKIP: staging: the downed screen was not drawn';
       if(!said.some(function(t){ return t==='EXTRACTING'; })) bad.push('downed and holding E in a ring, the downed screen does not show the extraction hold');
       Z.pullT=0; Z.callT=0.8; said=[]; drawHUD();
       if(!said.some(function(t){ return t==='CALLING EXTRACTION'; })) bad.push('downed and calling the ring, the downed screen does not show the call');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) ctx.fillText=of; else delete ctx.fillText; try{ var g2=__state(); if(g2&&!g2.over){ if(Z){ Z.pullT=0; Z.callT=0; } g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
