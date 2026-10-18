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

if ($s.Contains("  {v:'29.02',what:")) { throw "check 29.02 is in the fixture already" }

SubRx @'
  {v:'29.01',what:
'@ @'
  {v:'29.02',what:'cw-roletwin: a pillager carrying a rarity twin gets the same role as one carrying its base gun, and the base guns keep their roles',
   run:function(){
     if(typeof RV_BASE!=='object'||!RV_BASE||typeof raiderRole!=='function') return 'SKIP: no rarity twins here';
     var bad=[], id, b, i, r0, r1, n=0, exp={lmg:'supp',dmr:'mark',whisper:'mark',magnum:'mark',shotgun:'rush',carbine:'flank'};
     for(id in RV_BASE){
       b=RV_BASE[id]; if(!WEAPONS[id]||!WEAPONS[b]) continue; n++;
       for(i=0;i<8;i++){
         r0=raiderRole({kind:'raider',wep:WEAPONS[b],ident:'Twin'+i,rig:'std'});
         r1=raiderRole({kind:'raider',wep:WEAPONS[id],ident:'Twin'+i,rig:'std'});
         if(r0!==r1){ bad.push('a pillager Twin'+i+' with the '+id+' is '+r1+' where with the '+b+' he is '+r0); break; }
       }
     }
     if(!n) return 'SKIP: no rarity twin in WEAPONS';
     for(b in exp){ if(WEAPONS[b]&&raiderRole({kind:'raider',wep:WEAPONS[b],ident:'Base',rig:'std'})!==exp[b]) bad.push('the '+b+' no longer gives '+exp[b]); }
     return bad.length?bad.slice(0,4).join('; '):null;
   }},
  {v:'29.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
