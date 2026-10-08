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

if ($s.Contains("  {v:'20.46',what:")) { throw "check 20.46 is in the fixture already" }

SubRx @'
  {v:'20.45',what:
'@ @'
  {v:'20.46',what:'the Mainframe REWARDS strip draws the gun or the key a contract pays, not only its Credits',
   run:function(){
     if(typeof renderConDetail!=='function'||typeof gearLabel!=='function'||typeof FIXED_MAPS==='undefined'||!WEAPONS.rifle||!ITEMS.gun_rifle) return 'SKIP: no contract panel here';
     var d=document.getElementById('condetail'); if(!d) return 'SKIP: no contract panel in this page';
     var bad=[], c0=P.contracts, s0=P._conSel, cells, mi, L, kk;
     function show(gear){
       P.contracts=[{type:'kill',tgt:'sentry',n:3,prog:0,reward:4321,desc:'Destroy 3 Sentries',tier:'hard',gear:gear}]; P._conSel=0;
       renderConDetail(); return d.querySelectorAll('.crewcell');
     }
     try{
       cells=show({kind:'wep',k:'rifle'});
       if(cells.length!==1) bad.push('a card that pays the Auto Rifle drew '+cells.length+' reward cells beside the Credits, not 1');
       else if(cells[0].title!==WEAPONS.rifle.name) bad.push('the gun cell is titled '+cells[0].title+', not '+WEAPONS.rifle.name);
       mi=clamp(P.mapIx===undefined?0:P.mapIx,0,FIXED_MAPS.length-1); L=(FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; kk=L.length?('key_'+L[0].id):'';
       if(kk&&ITEMS[kk]){
         cells=show({kind:'key'});
         if(cells.length!==1) bad.push('a card that pays a key drew '+cells.length+' reward cells beside the Credits, not 1');
         else if(cells[0].title!==gearLabel({kind:'key'})) bad.push('the key cell is titled '+cells[0].title);
       }
       cells=show({kind:'stash',ks:['medkit','medkit'],label:'2 Medkits'});
       if(cells.length!==1||!cells[0].querySelector('.cnt')) bad.push('control: a card that pays 2 Medkits no longer draws one cell counted 2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.contracts=c0; P._conSel=s0;
       try{ renderConDetail(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
