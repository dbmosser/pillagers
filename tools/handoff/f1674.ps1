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

if ($s.Contains("  {v:'16.74',what:")) { throw "check 16.74 is in the fixture already" }

SubRx @'
  {v:'16.73',what:
'@ @'
  {v:'16.74',what:'a friend told the host spectates reads who is out and how, not that the host has left: the party status and the raid line carry the host name from the roster, is out of this raid, the way his run ended (killed, extracted, abandoned from the how the word carries, nothing when it carries none) and Extract to finish your run, neither says left, and the friend is still not ended',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__hubEnter)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof netSeatName!=='function'||typeof sayWhenFree!=='function') return 'SKIP: this fixture cannot stage a linked window';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,status:NET.status,specG:NET.specG}, keepSt=state, _swf=sayWhenFree, said=[], peer, oc=document.getElementById('outcome'), NM='ZQX VOSS';
     function js(o){ return JSON.stringify(o); }
     function one(how,want){
       var st, sw, L, tag='how '+(how===null?'none':how)+': ';
       NET.status=''; said.length=0;
       sw=netOnMsg(peer,js(how===null?{t:'up',st:'spec'}:{t:'up',st:'spec',how:how}));
       if(!G||G.over){ bad.push(tag+'the friend told spec was ended ('+sw+')'); return; }
       st=String(NET.status||''); L=said.length?String(said[said.length-1]):'';
       if(st.indexOf(NM)<0) bad.push(tag+'the party status does not name the host ('+st+')');
       if(st.indexOf('is out of this raid')<0) bad.push(tag+'the party status does not say the host is out of this raid ('+st+')');
       if(want&&st.indexOf(want)<0) bad.push(tag+'the party status does not say '+want+' ('+st+')');
       if(st.indexOf('Extract to finish your run')<0) bad.push(tag+'the party status does not say Extract to finish your run ('+st+')');
       if((/\bleft\b/i).test(st)) bad.push(tag+'the party status still says left ('+st+')');
       if(!L) bad.push(tag+'nothing was said in the raid');
       else{
         if(L.indexOf(NM)<0||L.indexOf('is out of this raid')<0||(want&&L.indexOf(want)<0)) bad.push(tag+'the raid line does not say who is out and how ('+L+')');
         if((/\bleft\b/i).test(L)) bad.push(tag+'the raid line still says left ('+L+')');
       }
     }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false;
       NET.on=true; NET.role='join'; NET.seat=1; NET.specG=null; NET.upSeed=G.seed>>>0; NET.up=[];
       peer={state:'in',seat:0,name:NM,timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer];
       NET.roster=[{seat:0,pid:'zqxhost',name:NM,host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       sayWhenFree=function(m){ said.push(String(m)); };
       one('dead','killed');
       one('extract','extracted');
       one('abandon','abandoned');
       one(null,'');
     }
     finally{
       try{ sayWhenFree=_swf; }catch(_s){}
       try{ keys={}; if(oc) oc.classList.remove('on'); }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; NET.status=keepN.status; NET.specG=keepN.specG; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
