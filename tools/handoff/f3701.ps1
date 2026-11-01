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

if ($s.Contains("  {v:'37.01',what:")) { throw "check 37.01 is in the fixture already" }

SubRx @'
  {v:'37.00',what:
'@ @'
  {v:'37.01',what:'an answer line said on, off, on within 0.35 s ends on "on": a line from another press in between is never swallowed (job 208, cw-ansgap); a held key still does not come back',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof ansSay!=='function') return 'SKIP: this fixture cannot deploy or has no answer line';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, shNow=statusNow, T=statusNow(), t0, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       statusNow=function(){ return T; };
       g.ans=null; g.ansSeen={}; g.ansPrev=null;
       ansSay('SUPERHOT ON'); T+=0.1; ansSay('SUPERHOT OFF'); T+=0.1; ansSay('SUPERHOT ON');
       if(!g.ans||g.ans.m!=='SUPERHOT ON') bad.push('on, off, on within 0.35 s left "'+(g.ans&&g.ans.m)+'" on the answer line, not SUPERHOT ON');
       g.ans=null; g.ansSeen={}; g.ansPrev=null; T+=10;
       t0=T; ansSay('NO AMMO');
       for(i=0;i<10;i++){ T+=0.25; ansSay('NO AMMO'); }
       if(!g.ans||g.ans.at!==t0) bad.push('a held key brought the line back after it had gone (shown again at '+(g.ans&&(g.ans.at-t0).toFixed(2))+' s)');
       return bad.length?bad.join('; '):null;
     } finally {
       statusNow=shNow;
       try{ __endRaid('abandon'); }catch(_e5){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'37.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
