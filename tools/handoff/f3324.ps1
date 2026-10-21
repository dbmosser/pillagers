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

if ($s.Contains("  {v:'33.24',what:")) { throw "check 33.24 is in the fixture already" }

SubRx @'
  {v:'33.23',what:
'@ @'
  {v:'33.24',what:'kill chain tick: each chained kill plays a soft sine tick a pentatonic note higher than the last, and the chain breaking starts it again from the bottom',
   run:function(){
     if(typeof chainTickStep!=='function'||typeof chainTickPlay!=='function') return 'there is no kill chain tick (no chainTickPlay)';
     var bad=[], i, rb=blip, rs=say, heard=[], st={}, kk=null, kt, k, tt, seq=[], r, kG, fr;
     if(chainTickStep(1)!==-1||chainTickStep(0)!==-1) bad.push('a lone kill ticks');
     if(chainTickStep(2)!==0||chainTickStep(3)!==1) bad.push('the second kill is not the bottom step');
     if(chainTickStep(10)!==CHAIN_NOTES.length-1||chainTickStep(99)!==CHAIN_NOTES.length-1) bad.push('the top step does not hold');
     for(i=1;i<CHAIN_NOTES.length;i++){ if(!(CHAIN_NOTES[i]>CHAIN_NOTES[i-1])) bad.push('the notes do not climb at '+i); }
     for(i=0;i<CHAIN_NOTES.length;i++){
       if(typeof SPK_GEN['chainTick'+i]!=='function'||SPK_CAT['chainTick'+i]!=='sting') bad.push('chainTick'+i+' is not a sting bus cue');
     }
     if(typeof OfflineAudioContext==='function'&&typeof SPK_GEN.chainTick0==='function'){
       var OFF=new OfflineAudioContext(1,22050,22050);
       for(i=0;i<CHAIN_NOTES.length;i++){ try{ SPK.at.chainTick=-9; fr=SPK_GEN['chainTick'+i](OFF,OFF.destination,1,0); if(!fr||!fr.g) bad.push('chainTick'+i+' made no sound'); }catch(e){ bad.push('chainTick'+i+' threw '+e); } }
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       kG=__state(); if(!kG||!kG.player) return bad.length?bad.join('; '):'SKIP: no raid';
       for(k in ARCADE_KILLPTS){ if((ARCADE_KILLPTS[k]|0)>0){ kk=k; break; } }
       if(!kk) return 'no kill kind scores';
       kt=G.t;
       blip=function(n){ heard.push(String(n)); }; say=function(){};
       G.t=100; for(i=0;i<5;i++){ scoreKill(st,kk,0,0); G.t+=1; }
       G.t+=10; scoreKill(st,kk,0,0); G.t+=1; scoreKill(st,kk,0,0);
       seq=heard.filter(function(n){ return n.indexOf('chainTick')===0; });
       if(seq.join(',')!=='chainTick0,chainTick1,chainTick2,chainTick3,chainTick0') bad.push('the ticks were '+seq.join(',')+' (want 0 1 2 3 then 0 again after the break)');
     } finally {
       blip=rb; say=rs; if(kt!==undefined) G.t=kt;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
