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

if ($s.Contains("  {v:'28.83',what:")) { throw "check 28.83 is in the fixture already" }

SubRx @'
  {v:'28.82',what:
'@ @'
  {v:'28.83',what:'every gun recipe on the bench costs twice its old amount and a non-gun recipe is unchanged (his order: guns more expensive to craft)',
   run:function(){
     if(typeof RECIPES==='undefined') return 'SKIP: no recipes in this build';
     var old={gun_smg:{comp:4,cell:3,board:2,servo:1},gun_carbine:{comp:4,servo:2,board:2},gun_rifle:{comp:5,servo:2,board:3,optic:1},gun_shotgun:{comp:5,cell:4,board:2,servo:2}};
     var bad=[], seen=0, i, k, r, out, medOk=false, fragOk=false;
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       for(i=0;i<RECIPES.length;i++){
         r=RECIPES[i]; out=null; for(k in r.out){ out=k; break; }
         if(old[out]){
           seen++;
           for(k in old[out]) if(r.need[k]!==old[out][k]*2) bad.push(r.name+' needs '+r.need[k]+' '+k+' and not '+old[out][k]*2);
           for(k in r.need) if(old[out][k]===undefined) bad.push(r.name+' gained '+k);
         }
         if(out==='medkit'&&r.need.bandage===2&&r.need.comp===1) medOk=true;
         if(out==='frag'&&r.need.comp===2&&r.need.cell===2&&r.need.scrap===2) fragOk=true;
       }
       if(seen!==4) bad.push('found '+seen+' gun recipes and not four');
       if(!medOk) bad.push('the Medkit recipe changed');
       if(!fragOk) bad.push('the Frag Charge recipe changed');
       return bad.length?bad.join('; '):null;
     } finally { __topClear(); } }},
  {v:'28.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
