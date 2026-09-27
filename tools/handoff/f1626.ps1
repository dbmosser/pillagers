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

if ($s.Contains("  {v:'16.26',what:")) { throw "check 16.26 is in the fixture already" }

SubRx @'
  {v:'16.25',what:
'@ @'
  {v:'16.26',what:'your teammates on the HUD: the state word carries the seconds left when down; in a party raid the HUD names a teammate, and a downed one shows DOWN with his seconds; alone it names nobody',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof drawHUD!=='function'||!ctx) return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, texts=[], oF=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), p, peer;
     function draw(){ texts=[]; ctx.fillText=function(t){ texts.push(String(t)); return oF.apply(ctx,arguments); }; try{ drawHUD(); }catch(e){ texts.push('THREW '+e); } finally{ if(own) ctx.fillText=oF; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oF; } } } return texts.join(' | '); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false; p=G.player;
       if(draw().indexOf('ZQX MATE')>=0) bad.push('control: alone the HUD names a teammate');
       NET.on=true; NET.role='host'; NET.seat=0; peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       netOnMsg(peer,JSON.stringify({t:'st',k:'r',sd:NET.upSeed>>>0,x:p.x+300,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:1,w:'',pz:0,hp:0,mh:100,ar:10,ac:100,dt:9}));
       if(!NET.up[1]) return 'SKIP: the staged state word was not filed';
       if(NET.up[1].dt!==9) bad.push('the state word does not carry the seconds he has left down ('+NET.up[1].dt+')');
       NET.up[1].n=5; NET.up[1].age=0;
       var t=draw();
       if(t.indexOf('ZQX MATE')<0) bad.push('in a party raid the HUD does not name the teammate');
       if(t.indexOf('DOWN 9s')<0) bad.push('the HUD does not show the downed teammate with his seconds ('+t.slice(0,120)+')');
     }
     finally{
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.25',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
