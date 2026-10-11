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

if ($s.Contains("  {v:'22.90',what:")) { throw "check 22.90 is in the fixture already" }

SubRx @'
  {v:'22.89',what:
'@ @'
  {v:'22.90',what:'the weather is a caps callout: a rainy drop says RAIN with Covers your noise and theirs as the detail, a turn into a storm says STORM INCOMING with the lightning detail on the host window and on the linked one, and every sky has a drop or turn headline in caps within 34 characters with no end punctuation and a short detail',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined'||typeof netWorldTake!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no weather or party here';
     var bad=[], oSay=say, oSfx=sfx, oPick=pickWeather, kPick=P.wxPick, said=[], g=null, i, q, RN=null, ST=null, FG=null, NK={}, k, l, peer={seat:0,state:'in'};
     function cap(what,want,wantSub){
       var l=null, j;
       for(j=0;j<said.length;j++) if(said[j].m===want) l=said[j];
       if(!l){ bad.push(what+' said '+JSON.stringify(said.map(function(s){ return s.m; }))+', not '+want); return; }
       if(wantSub&&l.sub!==wantSub) bad.push(what+' has the detail '+JSON.stringify(l.sub)+', not '+JSON.stringify(wantSub));
     }
     for(i=0;i<WEATHER.length;i++){ q=WEATHER[i]; if(q.id==='rain') RN=q; if(q.id==='storm') ST=q; if(q.id==='fog') FG=q;
       [q.cap,q.turn].forEach(function(h){ if(h==null) return; h=String(h); if(h!==h.toUpperCase()||h.length>34||/[.!?,;:]$/.test(h)) bad.push(q.id+' has the headline '+JSON.stringify(h)+', not a caps callout'); });
       if(!q.turn) bad.push(q.id+' has no caps turn headline');
       if(q.id!=='clear'&&!q.cap) bad.push(q.id+' has no caps drop headline');
       if(q.id!=='fog'&&(!q.sub||/[.!?]$/.test(String(q.sub)))) bad.push(q.id+' has the detail '+JSON.stringify(q.sub)+', not a short detail');
     }
     if(!RN||!ST) return 'SKIP: no rain or storm in the weather table';
     if(FG&&FG.sub!==['Limited','visibility','due','to','fog.'].join(' ')) bad.push('the fog detail is not his v7.43 line');
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       say=function(m,kd,o){ said.push({m:String(m),k:kd,sub:(o&&o.sub)?String(o.sub):''}); };
       sfx=function(){};

       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); P.wxPick='rain';
       said.length=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.wx) return 'SKIP: staging: no raid';
       if(g.wx.id!=='rain') bad.push('SKIP: staging: the drop sky is '+g.wx.id);
       else cap('a rainy drop','RAIN','Covers your noise and theirs');
       // the host window turns the sky to a storm
       pickWeather=function(){ return ST; }; P.wxPick='any';
       g.wx=RN; g.wxNext=null; g.wxT=0; g.wxTurnsLeft=2; g.wxAt=0; said.length=0;
       wxTick(0.016);
       if(!(g.wxNext&&g.wxNext.id==='storm')) bad.push('SKIP: staging: the host sky did not turn');
       else cap('a turn into a storm','STORM INCOMING',ST.sub);
       // the linked window is told the same
       pickWeather=oPick;
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[peer]; NET.upSeed=g.seed>>>0; NET.fxIn=false;
       g.wx=RN; g.wxNext=null; g.wxT=0; said.length=0;
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,wx:'rain',wn:'storm',wt:0});
       if(!(g.wxNext&&g.wxNext.id==='storm')) bad.push('SKIP: staging: the host word did not reach the linked window');
       else cap('a turn told to player 2','STORM INCOMING',ST.sub);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=oSay; sfx=oSfx; pickWeather=oPick;
       if(kPick===undefined) delete P.wxPick; else P.wxPick=kPick;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.wxNext=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     l=bad.filter(function(s){ return s.indexOf('SKIP')!==0; });
     if(!l.length&&bad.length) return bad.join('; ');
     return l.length?l.join('; '):null; }},
  {v:'22.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
