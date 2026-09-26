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

if ($s.Contains("  {v:'16.02',what:")) { throw "check 16.02 is in the fixture already" }

SubRx @'
  {v:'16.01',what:
'@ @'
  {v:'16.02',what:'partly cloudy does not hold: a weather turn into Partly Cloudy on the last turn of a raid keeps one turn back for the break it announces; control, a last turn into rain leaves none',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined') return 'SKIP: this fixture cannot stage the weather';
     var bad=[], oPick=pickWeather, keepPick=P.wxPick, W0=null, WP=null, WR=null, i, r;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='clear') W0=WEATHER[i]; if(WEATHER[i].id==='partly') WP=WEATHER[i]; if(WEATHER[i].id==='rain') WR=WEATHER[i]; }
     if(!W0||!WP||!WR) return 'SKIP: this build has no clear, partly or rain sky';
     function turn(to){
       pickWeather=function(){ return to; };
       G.wx=W0; G.wxNext=null; G.wxT=0; G.wxTurnsLeft=1; G.wxAt=0; G.over=false;
       wxTick(0.05);
       return {next:G.wxNext?G.wxNext.id:null,left:G.wxTurnsLeft};
     }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); P.wxPick='any';
       if(!G) return 'SKIP: no raid staged';
       G.sim=1;
       r=turn(WR);
       if(r.next!=='rain'||r.left!==0) bad.push('control: the last turn into rain gave next '+r.next+' with '+r.left+' turns left');
       r=turn(WP);
       if(r.next!=='partly') bad.push('the staged turn did not go into partly (next '+r.next+')');
       else if(r.left<1) bad.push('the last turn went into Partly Cloudy, which says This will not hold, with '+r.left+' turns left, so it holds to extraction');
     }
     finally{
       try{ pickWeather=oPick; }catch(_pw){}
       try{ P.wxPick=keepPick; }catch(_wp){}
       try{ G=null; keys={}; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.01',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
