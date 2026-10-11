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

if ($s.Contains("  {v:'22.64',what:")) { throw "check 22.64 is in the fixture already" }

SubRx @'
  {v:'22.63',what:
'@ @'
  {v:'22.64',what:'the offer line names one key: with a controller it reads [Y] to take it and never T or, on the keyboard [T] to take it and never or Y, and the giver sees Waiting with the seconds left',
   run:function(){
     if(typeof drawGiftLine!=='function'||typeof PAD==='undefined') return 'SKIP: this build has no offer line or controller';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], s, nm, padK={}, pk, TOR='T '+'or', ORY='or '+'Y';
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       nm=ITEMS.codex?ITEMS.codex.name:'codex';
       G.t=50; G.giftIn={id:'tst',k:'codex',from:1,t:50};
       PAD.on=true; PAD.brand='xbox';
       s=String(drawGiftLine()||'');
       if(s.indexOf(nm)<0||s.indexOf('[Y] to take it')<0||s.indexOf(TOR)>=0||s.indexOf('12s')<0) bad.push('with a controller the offer line reads '+JSON.stringify(s)+', not one [Y] key');
       PAD.on=false;
       s=String(drawGiftLine()||'');
       if(s.indexOf(nm)<0||s.indexOf('[T] to take it')<0||s.indexOf(ORY)>=0) bad.push('on the keyboard the offer line reads '+JSON.stringify(s)+', not one [T] key');
       G.giftIn=null; G.giftOut={id:'out',k:'codex',to:1,t:50};
       s=String(drawGiftLine()||'');
       if(s.indexOf('Offered '+nm)!==0||s.indexOf('Waiting')<0||s.indexOf('12s')<0||s.indexOf('Waiting for them')>=0) bad.push('the giver sees '+JSON.stringify(s)+', not the offer, Waiting and the seconds left');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       try{ if(G){ G.giftIn=null; G.giftOut=null; } }catch(_g){}
       try{ __endRaid('abandon'); }catch(_c){}
       keys={}; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
