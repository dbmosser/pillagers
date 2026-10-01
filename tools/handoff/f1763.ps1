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

if ($s.Contains("  {v:'17.63',what:")) { throw "check 17.63 is in the fixture already" }

SubRx @'
  {v:'17.62',what:
'@ @'
  {v:'17.63',what:'a teammate whose raid ended is named in the host raid, with how it ended',
   run:function(){
     if(typeof netUpWord!=='function') return 'SKIP: this build has no party raid words';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], lines=[], oSend=netSend, oSwf=sayWhenFree, oName=netSeatName, peer={seat:1,state:'in'};
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(){ return true; }; sayWhenFree=function(t){ lines.push(String(t)); };
       netSeatName=function(s){ return s===1?'MOTH':(s===0?'HOST':null); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; if(!NET.up) NET.up=[];
       netUpWord(peer,{t:'up',st:'out',how:'extract'});
       if(!lines.some(function(t){ return t.indexOf('MOTH is out of this raid (extracted)')===0; })) bad.push('the host was told '+JSON.stringify(lines));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; sayWhenFree=oSwf; netSeatName=oName;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
