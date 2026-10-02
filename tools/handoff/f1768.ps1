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

if ($s.Contains("  {v:'17.68',what:")) { throw "check 17.68 is in the fixture already" }

SubRx @'
  {v:'17.67',what:
'@ @'
  {v:'17.68',what:'a teammate going down is said once (NAME is down. Pick them up.) with a rumble, on the word that first carries the downed flag in this raid, and not again while he stays down',
   run:function(){
     if(typeof netOnState!=='function'||typeof padRumble!=='function') return 'SKIP: this build has no party words or no rumble';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], lines=[], rum=0, oSwf=sayWhenFree, oRum=padRumble, oName=netSeatName, peer={seat:1,state:'in'}, w;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       sayWhenFree=function(t){ lines.push(String(t)); }; padRumble=function(){ rum++; return 'test'; };
       netSeatName=function(s){ return s===1?'MOTH':(s===0?'HOST':null); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.floor=NET.floor||[];
       w={t:'st',k:'r',x:Math.round(G.player.x)+60,y:Math.round(G.player.y),f:0,sd:G.seed>>>0,dn:0,hp:100,mh:100};
       netOnState(peer,w); netOnState(peer,w);
       if(lines.length||rum) bad.push('a teammate still standing was called down');
       w.dn=1; netOnState(peer,w);
       if(!lines.some(function(t){ return t.indexOf('MOTH is down')===0; })) bad.push('the window was told '+JSON.stringify(lines)+' when its teammate went down');
       if(rum!==1) bad.push('the controller rumbled '+rum+' times when the teammate went down');
       netOnState(peer,w);
       if(lines.length!==1||rum!==1) bad.push('the fall was said again while he stayed down ('+lines.length+' lines, '+rum+' rumbles)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sayWhenFree=oSwf; padRumble=oRum; netSeatName=oName;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
