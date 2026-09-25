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
  {v:'15.72',what:
'@ @'
  {v:'15.73',what:'check 9.63 measures the shot mark alone again: with the noise ring of a hidden shot drawn above the darkness since v15.67, the red a pillager shot leaves is still told apart from the mark being off',
   run:function(){
     var c=null, i;
     for(i=0;i<__REGRESS.length;i++) if(__REGRESS[i].v==='9.63'){ c=__REGRESS[i]; break; }
     if(!c) return 'SKIP: check 9.63 is not in this fixture';
     var r=c.run();
     if(r===null) return null;
     if((/^SKIP/).test(String(r))) return r;
     return 'check 9.63 fails: '+r; }},
  {v:'15.72',what:
'@
SubRx @'
       __gun.fire(R,__gun.weapons.pistol,p.x,p.y,false);
       var made=g.pings.length;
'@ @'
       __gun.fire(R,__gun.weapons.pistol,p.x,p.y,false);
       var made=g.pings.length;
       // v15.73: since v15.67 the noise ring of this same shot is drawn above the darkness too, in the same reds, and it does not
       // follow the shot mark dial. Clear it so both arms measure the shot mark alone.
       if(g.noiseRings) g.noiseRings.length=0;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
