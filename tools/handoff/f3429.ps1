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

if ($s.Contains("  {v:'34.29',what:")) { throw "check 34.29 is in the fixture already" }

SubRx @'
  {v:'34.28',what:
'@ @'
  {v:'34.29',what:'the raid HUD has one hero per state: while the extraction ship is inbound the ammo card steps down to 60 percent, and the compact controls list is drawn at 80 percent',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, bad=[], g, ammo=1, leg=1, seen=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; G.legendOn=1; G.legendExtDone=true; G.legendAutoDone=true;
       proto.fillText=function(t,x,y){ if(this===ctx&&typeof t==='string'){ var s=TX(t); if(x>W*0.8&&y>H*0.85&&/\d/.test(s)&&this.globalAlpha<ammo) ammo=this.globalAlpha; if(/^(sprint|crouch|reload)$/.test(s)){ seen++; if(this.globalAlpha<leg) leg=this.globalAlpha; } } return o.apply(this,arguments); };
       __frame(0.001); ammo=1; leg=1; __frame(0.001);
       var a0=ammo, l0=leg;
       g.beaconT=20; ammo=1; __frame(0.001); ammo=1; __frame(0.001);
       var a1=ammo;
       if(a0<0.99) bad.push('the ammo card is dim ('+a0+') with no ship inbound');
       if(a1>0.7) bad.push('the ammo card is at '+a1+' while the ship is inbound');
       if(!seen) bad.push('the compact controls list was not drawn (legendOn '+G.legendOn+')');
       else if(l0>0.85) bad.push('the compact controls list is at '+l0+' (want 0.8)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.beaconT=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
