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

# CHECK 11.77 LEFT A BARE PROFILE BEHIND. __applyLoaded replaces P with the
# synthetic profile it is handed (no cosmetics, no stash, no weapons), and
# __cleanProfile afterwards keeps what is there rather than rebuilding, so
# every later check that leans on the profile could fail: 8.72 (belt to
# stash), 10.33 and 10.34 (sprite cosmetics) each went red once in three
# corpus runs. The clean profile is snapshotted after __cleanProfile at the
# start and put back through the real loader at the end.
SubRx @'
     var bad=[], k;
     if(DEF.fragR!==190) bad.push('the default blast radius is '+DEF.fragR+' and not 190');
     function withCfg(fr){ var c={}; for(k in DEF) c[k]=DEF[k]; c.fragR=fr; return {credits:900,cfgv:17,cfg:c}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fragR=DEF.fragR;   // the game reads CFG; the blast is measured at the shipped default
'@ @'
     var bad=[], k, snap=null;
     if(DEF.fragR!==190) bad.push('the default blast radius is '+DEF.fragR+' and not 190');
     function withCfg(fr){ var c={}; for(k in DEF) c[k]=DEF[k]; c.fragR=fr; return {credits:900,cfgv:17,cfg:c}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // The loader below REPLACES the profile with a bare one and __cleanProfile
       // keeps what it finds, so the clean profile is put back through the same
       // loader at the end; without this three later checks each went red once.
       snap=JSON.stringify(__P());
       CFG.fragR=DEF.fragR;   // the game reads CFG; the blast is measured at the shipped default
'@
SubRx @'
       if(CFG.fragR!==140) bad.push('control: a hand-set 140 was overwritten to '+CFG.fragR+' by the migration');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); __resetCfg(); }
'@ @'
       if(CFG.fragR!==140) bad.push('control: a hand-set 140 was overwritten to '+CFG.fragR+' by the migration');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ if(snap) __applyLoaded(JSON.parse(snap)); }catch(_rs){} __topClear(); __cleanProfile(); __resetCfg(); }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
