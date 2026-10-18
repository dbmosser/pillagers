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

if ($s.Contains("  {v:'30.29',what:")) { throw "check 30.29 is in the fixture already" }

SubRx @'
  {v:'30.28',what:
'@ @'
  {v:'30.29',what:'the demo starts with TV-size text (HUD size 150 percent) and leaving puts his own size back (his Q21)',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     if(typeof arcadeSandboxIn!=='function'||typeof arcadeSandboxOut!=='function'||typeof uiScale!=='function') return 'SKIP: no arcade sandbox here';
     var bad=[], us0, had;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       had=Object.prototype.hasOwnProperty.call(P,'uiScale'); us0=P.uiScale; P.uiScale=1.2;
       if(!arcadeSandboxIn('host')) return 'arcadeSandboxIn failed';
       if(Math.abs(uiScale()-1.5)>0.001) bad.push('inside the demo the HUD size is '+uiScale()+', not 1.5');
       arcadeSandboxOut();
       if(Math.abs(uiScale()-1.2)>0.001) bad.push('after leaving the demo the HUD size is '+uiScale()+', not his 1.2');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} if(had) P.uiScale=us0; else delete P.uiScale; __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
