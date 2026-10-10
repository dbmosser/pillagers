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

if ($s.Contains("  {v:'22.03',what:")) { throw "check 22.03 is in the fixture already" }

SubRx @'
  {v:'22.02',what:
'@ @'
  {v:'22.03',what:'a door player 2 opens with a key while the host watches opens in the raid the host keeps for him and is passed on to the party, and a raid that is simply over opens nothing',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netDoorTake!=='function'||typeof lockedOpen!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oBc=netBroadcast, oSay=say, words=[], g, L=null, r1, r2, peer={seat:1,state:'in',name:'ZQX DOORTEST'}, i;
     function doors(id){ var n=0, j; for(j=0;j<g.map.walls.length;j++) if(g.map.walls[j].door===id) n++; return n; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.map) return 'SKIP: no live raid';
       for(i=0;i<(g.map.locked||[]).length;i++) if(!g.map.locked[i].open&&doors(g.map.locked[i].id)){ L=g.map.locked[i]; break; }
       if(!L) return 'SKIP: staging: no shut door on this map';
       say=function(){};
       netBroadcast=function(w){ words.push(w); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.upSeed=g.seed>>>0;
       g.over='dead'; NET.specG=null;
       r1=netDoorTake(peer,{t:'door',sd:g.seed>>>0,id:L.id});
       if(L.open||!doors(L.id)) bad.push('a raid that is simply over opened a door ('+r1+')');
       NET.specG=g;
       r2=netDoorTake(peer,{t:'door',sd:g.seed>>>0,id:L.id});
       if(!L.open) bad.push('the raid the host keeps for the party left the door shut ('+r2+')');
       if(doors(L.id)) bad.push('the door wall still stands in the raid the host keeps, so the enemies cannot see or walk through it');
       if(!words.some(function(w){ return w&&w.t==='door'&&w.id===L.id; })) bad.push('the open door was not passed on to the rest of the party');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netBroadcast=oBc; say=oSay;
       try{ var g2=__state(); if(g2) g2.over=false; NET.specG=null; }catch(_o){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
