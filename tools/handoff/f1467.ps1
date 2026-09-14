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
  {v:'14.66',what:
'@ @'
  {v:'14.67',what:'the sector page names his own gun 2: with gun 1 empty and his own gun in gun 2 the going up line names that gun as gun 2, as it names a gun in gun 1 (ascent audit finding 3)',
   run:function(){
     if(typeof syncSectorKit!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no sector kit line in this build';
     var el=document.getElementById('sectorkit');
     if(!el) return 'SKIP: no sector kit element in this document';
     var bad=[], prof, gk=null;
     for(var k in WEAPONS){ if(k!=='fists'&&k!=='none'&&WEAPONS[k]&&WEAPONS[k].name){ gk=k; break; } }
     if(!gk) return 'SKIP: no gun to own';
     var nm=WEAPONS[gk].name;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       // CONTROL: his gun in gun 1 is named.
       prof.weapons=[gk]; prof.equipped=gk; prof.equippedSec=null;
       syncSectorKit();
       if(String(el.textContent).indexOf(nm)<0) return 'SKIP: the sector page did not name a gun in gun 1 here ("'+String(el.textContent).slice(0,60)+'")';
       // THE FIX: gun 1 empty, his gun in gun 2.
       prof.equipped='fists'; prof.equippedSec=gk;
       syncSectorKit();
       var tx=String(el.textContent);
       if(tx.indexOf(nm)<0||tx.indexOf('gun 2')<0) bad.push('with gun 1 empty and his '+nm+' in gun 2, the sector page said "'+tx.slice(0,80)+'" and never named the gun a death can lose');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
