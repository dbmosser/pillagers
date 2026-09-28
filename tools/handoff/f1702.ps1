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

if ($s.Contains("  {v:'17.02',what:")) { throw "check 17.02 is in the fixture already" }

SubRx @'
  {v:'17.01',what:
'@ @'
  {v:'17.02',what:'kid mode at 1/20 is really 1/20: a saved 1/20 reads as 1/20, the Settings row shows it and goes on to OFF, the host word carries it, and a player 2 hit at 1/20 takes a twentieth',
   run:function(){
     if(typeof KID_OPTS==='undefined'||typeof kidMulOwn!=='function'||typeof netKidMul!=='function'||typeof kidCycle!=='function'||typeof kidRowHtml!=='function'||typeof netWorldTake!=='function'||typeof damagePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no kid mode';
     var low=KID_OPTS[KID_OPTS.length-1][0];
     if(!(Math.abs(low-0.05)<1e-9)) return 'SKIP: the smallest kid mode level is not 1/20';
     var keep={had:Object.prototype.hasOwnProperty.call(P,'kidDmg'),kd:P.kidDmg,on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,kh:NET.kidHost,sp:saveProfile}, bad=[], p=null, oG=null, hp0, v, h, r;
     try{
       saveProfile=function(){};
       P.kidDmg=0.05; NET.kidHost=undefined;
       v=kidMulOwn(); if(Math.abs(v-0.05)>1e-9) bad.push('a saved 1/20 reads as '+v);
       h=kidRowHtml(); if(h.indexOf('>1/20<')<0) bad.push('the Settings row does not show 1/20 when 1/20 is saved');
       kidCycle(); if(P.kidDmg!==1) bad.push('one press from 1/20 went to '+P.kidDmg+', not OFF');
       P.kidDmg=1; NET.kidHost=0.05;
       v=netKidMul(); if(Math.abs(v-0.05)>1e-9) bad.push('1/20 from the host gives player 2 '+v);
       NET.on=false; NET.role=null; NET.kidHost=undefined;
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       NET.on=true; NET.role='join'; NET.peers=[{state:'in',seat:0}]; NET.upSeed=G.seed;
       r=netWorldTake(NET.peers[0],{t:'wd',sd:G.seed>>>0,wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:G.wxT||0,kd:0.05});
       if(r!=='wd'||!(Math.abs(NET.kidHost-0.05)<1e-9)) bad.push('the host word with 1/20 set player 2 to '+NET.kidHost+' ('+r+')');
       NET.peers=[];
       p=G.player; oG=voxGrunt; voxGrunt=function(){}; p.iv=0; p.armor=0; p.plates=0; hp0=p.hp;
       damagePlayer(20,'sentry','SENTRY',p.x+5,p.y);
       if(!(hp0-p.hp>0.5&&hp0-p.hp<2)) bad.push('a 20 point hit on player 2 with 1/20 from the host took '+(hp0-p.hp).toFixed(2)+' health, not about 1');
     } finally {
       saveProfile=keep.sp;
       if(keep.had) P.kidDmg=keep.kd; else delete P.kidDmg;
       NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; NET.kidHost=keep.kh;
       try{ if(oG) voxGrunt=oG; }catch(e1){}
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(e2){}
       try{ __topClear(); }catch(e3){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
