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

if ($s.Contains("  {v:'31.01',what:")) { throw "check 31.01 is in the fixture already" }

SubRx @'
  {v:'31.00',what:
'@ @'
  {v:'31.01',what:'the party arcade pause box is the same in both windows: the line telling the host that closing its window ends the raid for the party shows in a co-op raid and is left off in the arcade demo, where player 2 has none (his order of 2026-10-18: p1 and p2 should look and behave the same)',
   run:function(){
     var el=document.getElementById('pausehost');
     if(!el||typeof netHostHolds!=='function'||typeof togglePauseBox!=='function'||typeof ARCADE==='undefined'||!ARCADE) return 'SKIP: this build has no hosting line in the pause box';
     if(!(window.__deploy&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: this fixture cannot start a raid';
     if(NET.on||NET.same||ARCADE.on) return 'SKIP: a party is on in this copy';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,aon:ARCADE.on}, oSend=netSend, oRef=netRefresh, bad=[], raided=false, a='', b='';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); raided=true;
       if(!G||G.sim||G.over) return 'SKIP: no live raid';
       netSend=function(){ return true; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}]; NET.upSeed=77;
       if(!netHostHolds()) return 'SKIP: the stand-in party does not read as holding the raid';
       togglePauseBox(true); a=el.style.display; togglePauseBox(false);
       ARCADE.on=1;
       togglePauseBox(true); b=el.style.display; togglePauseBox(false);
       if(a==='none') bad.push('control: a co-op host pause box no longer shows the hosting line');
       if(b!=='none') bad.push('the party arcade pause box still shows the hosting line to the host');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ ARCADE.on=keep.aon; }catch(_a){}
       try{ NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; }catch(_n){}
       try{ netSend=oSend; netRefresh=oRef; }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ if(raided) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
