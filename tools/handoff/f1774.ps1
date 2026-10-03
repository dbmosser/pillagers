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

if ($s.Contains("  {v:'17.74',what:")) { throw "check 17.74 is in the fixture already" }

SubRx @'
  {v:'17.73',what:
'@ @'
  {v:'17.74',what:'volume: Settings has Master, Music and Effects rows; Effects and Master set the bus every sound rides, Music and Master scale the level the music asks for',
   run:function(){
     if(typeof volApply!=='function') return 'Settings has no volume rows';
     var bad=[], ks=(GAMEOPTS||[]).map(function(o){ return o.k; }), b0=BUS, mg=(typeof MUS==='object'&&MUS)?MUS.g:null, ml=(typeof MUS==='object'&&MUS)?MUS.lvl:undefined, c0={m:CFG.volMaster,f:CFG.volFx,u:CFG.volMusic}, seen=null;
     ['volMaster','volMusic','volFx'].forEach(function(k){ if(ks.indexOf(k)<0) bad.push('Settings has no '+k+' row'); });
     try{
       BUS={gain:{value:1}}; MUS.g={gain:{setTargetAtTime:function(v){ seen=v; }}}; MUS.lvl=0.4; VOL_LAST='';
       CFG.volMaster=1; CFG.volFx=0.5; CFG.volMusic=1; volApply();
       if(Math.abs(BUS.gain.value-0.5)>1e-9) bad.push('Effects at 50% set the bus to '+BUS.gain.value);
       if(seen===null||Math.abs(seen-0.4)>1e-9) bad.push('with Music at Full the music level asked for was '+seen+', not 0.4');
       CFG.volMaster=0.5; CFG.volMusic=0.5; volApply();
       if(Math.abs(BUS.gain.value-0.25)>1e-9) bad.push('Master 50% and Effects 50% set the bus to '+BUS.gain.value);
       if(Math.abs(seen-0.1)>1e-9) bad.push('Master 50% and Music 50% asked the music for '+seen+', not 0.1');
       CFG.volMaster=0; volApply(); if(BUS.gain.value!==0) bad.push('Master Off left the bus at '+BUS.gain.value);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ BUS=b0; if(typeof MUS==='object'&&MUS){ MUS.g=mg; MUS.lvl=ml; } CFG.volMaster=c0.m; CFG.volFx=c0.f; CFG.volMusic=c0.u; VOL_LAST=''; try{ volApply(); }catch(_v){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
