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

if ($s.Contains("  {v:'16.08',what:")) { throw "check 16.08 is in the fixture already" }

SubRx @'
  {v:'16.07',what:
'@ @'
  {v:'16.08',what:'the party on the sector map: with the map open in a party raid, a teammate up top is drawn with his name, and one who is down with DOWN under it; control, alone the map names nobody else',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof drawMapOverlay!=='function'||!ctx) return 'SKIP: this fixture cannot open the sector map in a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, texts=[], oFill=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), p;
     function draw(){ texts=[]; ctx.fillText=function(t){ texts.push(String(t)); return oFill.apply(ctx,arguments); }; try{ drawMapOverlay(); } finally { if(own) ctx.fillText=oFill; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oFill; } } } return texts.join(' | '); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); p=G.player; G.mapOpen=true;
       var solo=draw();
       if(solo.indexOf('ZQX MATE')>=0) bad.push('control: alone the map names a teammate');
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}]; NET.upSeed=G.seed>>>0;
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       NET.up=[]; NET.up[1]={seat:1,x:p.x+400,y:p.y+200,f:0,tx:p.x+400,ty:p.y+200,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,mv:0,roll:0,bob:0,cr:0,sp:0,w:''};
       var up=draw();
       if(up.indexOf('ZQX MATE')<0) bad.push('with the map open a teammate up top is not named on it');
       if(up.indexOf('DOWN')>=0) bad.push('a teammate on his feet is marked DOWN');
       NET.up[1].dn=1;
       var dn=draw();
       if(dn.indexOf('ZQX MATE')<0||dn.indexOf('DOWN')<0) bad.push('a teammate who is down is not marked DOWN on the map');
     }
     finally{
       try{ if(G) G.mapOpen=false; }catch(_m){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.07',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
