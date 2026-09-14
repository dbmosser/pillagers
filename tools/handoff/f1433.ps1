$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.32',what:
'@ @'
  {v:'14.33',what:'noise does not alert the Peddler or the Stray: a noise beside the Peddler, a stray and a crawler alerts the crawler and leaves the Peddler and the stray calm (weather audit finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof ping!=='function'||typeof mkPeddler!=='function') return 'SKIP: no noise or Peddler in this build';
     var bad=[], g0=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; g.ents.length=0; p.iv=99;
       var pd=mkPeddler(p.x+40,p.y,g.map); if(g.ents.indexOf(pd)<0) g.ents.push(pd); pd.alert=0;
       var st={kind:'stray',x:p.x-40,y:p.y,alert:0,state:'idle',hp:30,maxhp:30};
       var cr={kind:'crawler',x:p.x,y:p.y+40,alert:0,state:'patrol',hp:30,maxhp:30};
       g.ents.push(st); g.ents.push(cr);
       ping(p.x,p.y,900,false,false,'env','fire');
       if(!(cr.alert>0)) bad.push('control: a noise beside a crawler did not alert it, so this check cannot see an alert');
       if(pd.alert>0) bad.push('a noise beside the Peddler left him alerted ('+pd.alert+'), which his update never lets decay');
       if(st.alert>0) bad.push('a noise beside the Stray left it alerted ('+st.alert+'), which its update never lets decay');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ g0.ents.length=0; if(g0.player) g0.player.iv=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
