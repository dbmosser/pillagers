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

if ($s.Contains("  {v:'22.70',what:")) { throw "check 22.70 is in the fixture already" }

SubRx @'
  {v:'22.69',what:
'@ @'
  {v:'22.70',what:'one teammate colour: in co-op the name over a teammate head, his row on the left and his edge arrow are all the ally colour, and all danger red while he is down',
   run:function(){
     if(typeof netOnState!=='function'||typeof netUpTags!=='function'||typeof netUpShown!=='function'||typeof netMateArrow!=='function'||typeof drawHUD!=='function'||typeof HUDC==='undefined'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammates up top';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,upOut:NET.upOut,peers:NET.peers,roster:NET.roster,status:NET.status,srch:NET.srch,holds:NET.holds},
         oSend=netSend, oRef=netRefresh, oSay=say, oBlip=blip, k0=keys, bad=[], k, peer, p, w, g1, oFT=ctx.fillText, oWT=(typeof wc!=='undefined'&&wc)?wc.fillText:null, NM='ZQX'+' MATE', tag, row, arr, ally, dang;
     function norm(c){ var o=ctx.fillStyle; ctx.fillStyle=c; var r=ctx.fillStyle; ctx.fillStyle=o; return r; }
     function unspy(){ try{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_a){} try{ if(oWT&&wc!==ctx){ delete wc.fillText; if(wc.fillText!==oWT) wc.fillText=oWT; } }catch(_b){} }
     function look(){
       var r={tag:null,row:null,arr:null};
       if(oWT&&wc!==ctx) wc.fillText=function(t){ if(String(t)===NM&&r.tag===null) r.tag=String(wc.fillStyle); return oWT.apply(this,arguments); };
       ctx.fillText=function(t){ var s=String(t); if(s===NM&&r.row===null) r.row=String(ctx.fillStyle); if(s.indexOf(NM+'  ')===0&&r.arr===null) r.arr=String(ctx.fillStyle); if(s===NM&&wc===ctx&&r.tag===null) r.tag=String(ctx.fillStyle); return oFT.apply(this,arguments); };
       try{ netUpTags(); }catch(_t){} try{ drawHUD(); }catch(_h){} try{ netMateArrow({seat:1,x:W*3,y:H/2,dn:g1.dn}); }catch(_m){}
       unspy(); return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||G.over) return 'SKIP: staging: no raid';
       p=G.player; keys={}; G.sim=0; p.downed=false; p.roll=0; p.iv=99; G.ents.length=0; G.bagOpen=false; G.mapOpen=false;
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; blip=function(){};
       peer={state:'in',seat:1};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:NM}]; NET.up=[]; NET.upOut=undefined; NET.specG=null; NET.holds={}; NET.srch=null;
       w={t:'st',k:'r',sd:G.seed>>>0,x:p.x+120,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:0,hp:80,mh:100,ar:0,ac:0,dt:0,sa:1};
       netOnState(peer,w);
       g1=NET.up[1];
       if(!g1||!netUpShown(g1)) return 'SKIP: staging: the teammate word was not filed up top';
       g1.x=p.x+120; g1.y=p.y; g1.dn=0;
       ally=norm(HUDC.ally); dang=norm(HUDC.danger);
       tag=look();
       if(tag.tag===null||tag.row===null) return 'SKIP: staging: his name was not drawn over his head and in his row ('+JSON.stringify(tag)+')';
       if(tag.tag!==tag.row) bad.push('standing, the name over his head is '+tag.tag+' while his row on the left is '+tag.row);
       if(tag.tag!==ally) bad.push('standing, the name over his head is '+tag.tag+', not the ally colour '+ally);
       if(tag.arr!==null&&tag.arr!==ally) bad.push('standing, his edge arrow label is '+tag.arr+', not the ally colour');
       g1.dn=1; g1.dt=10;
       row=look();
       if(row.tag===null||row.row===null) return 'SKIP: staging: his name was not drawn while down';
       if(row.tag!==row.row) bad.push('down, the name over his head is '+row.tag+' while his row on the left is '+row.row);
       if(row.tag!==dang) bad.push('down, the name over his head is '+row.tag+', not danger red '+dang);
       if(row.arr!==null&&row.arr!==dang) bad.push('down, his edge arrow label is '+row.arr+', not danger red');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       unspy();
       netSend=oSend; netRefresh=oRef; say=oSay; blip=oBlip; keys=k0;
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.player){ G.player.downed=false; G.player.iv=0; } }catch(e){}
       try{ __endRaid('abandon'); __topClear(); __cleanProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
