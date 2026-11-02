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

if ($s.Contains("  {v:'37.27',what:")) { throw "check 37.27 is in the fixture already" }

SubRx @'
  {v:'37.26',what:
'@ @'
  {v:'37.27',what:'the teammate row shows his gun and his rounds under the bars: a carbine with 18 in the magazine and 90 in reserve draws burst carbine and 18 / 90; fists and busy hands draw no gun line; the word carries, stores and relays am and rs',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof netTeamHud!=='function'||typeof netUpShown!=='function') return 'SKIP: no co-op HUD here';
     var bad=[], g, NK={}, k, oShown=netUpShown, oName=netSeatName, oFT=ctx.fillText, seen=[], row;
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       row={seat:1,hp:70,mh:100,ar:30,ac:50,x:g.player.x+40,y:g.player.y,dn:0,w:'carbine',fk:0,hd:0,am:18,rs:90};
       NET.on=true; NET.up=[row];
       netUpShown=function(u){ return !!u; }; netSeatName=function(s){ return (s===1)?'ZQMATE':oName(s); };
       ctx.fillText=function(s){ seen.push(String(s).toLowerCase()); return oFT.apply(this,arguments); };
       ctx.save(); try{ netTeamHud(H); } finally { ctx.restore(); }
       if(seen.indexOf('burst carbine')<0) bad.push('the gun name was not drawn on the teammate row (drew: '+seen.join(' | ')+')');
       if(seen.indexOf('18 / 90')<0) bad.push('the rounds and reserve 18 / 90 were not drawn on the teammate row');
       seen=[]; row.w='fists'; row.am=0; row.rs=0;
       ctx.save(); try{ netTeamHud(H); } finally { ctx.restore(); }
       if(seen.some(function(t){ return (/ \/ /).test(t); })) bad.push('a teammate with fists got a rounds line');
       seen=[]; row.w='carbine'; row.am=18; row.rs=90; row.hd=1;
       ctx.save(); try{ netTeamHud(H); } finally { ctx.restore(); }
       if(seen.indexOf('18 / 90')>=0) bad.push('a teammate with busy hands still shows his gun line');
       if(!(/g\.am=/).test(String(netOnState))||!(/out\.am=g\.am/).test(String(netOnState))) bad.push('the teammate word is not stored and relayed with am and rs');
       if(!(/am:Math\.max\(0,p\.ammo/).test(String(netUpTick))) bad.push('the st word does not carry am');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; netUpShown=oShown; netSeatName=oName; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'37.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
