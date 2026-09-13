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

# v13.26 CHECK, inserted before the v13.25 entry.
#
# IT READS WHAT THE GAME BUILT, SYNCHRONOUSLY, before the text engine runs. That
# is deliberate: the fault was a sentence that only looked right when a baked edit
# happened to match, so the check has to prove the generator itself produces his
# wording, with no baked edit involved.
#
# TWO PLAYERS, because the fault depended on the run count: one who has never
# raided either map, and one with a run on each.
SubRx @'
  {v:'13.25',what:'the what-is-new card no longer promises Escape keeps fullscreen where it cannot: an entry about Escape and fullscreen says it only holds in the game own tab, and what happens inside another page such as itch (his report of 2026-09-12)',
'@ @'
  {v:'13.26',what:'the map screen shows every player the sector line he rewrote: the test robot extract rate in that map, without first contact, containers or median haul, whether or not that player has raided there (his baked edits matched only his own run counts)',
   run:function(){
     if(typeof renderSector!=='function'||typeof FIXED_MAPS==='undefined'||typeof SECTOR_MEAS==='undefined') return 'SKIP: this fixture cannot draw the map screen';
     var host=document.getElementById('sectorlist'); if(!host) return 'SKIP: there is no map list to draw into';
     var bad=[], keepLog=(P.log||[]).slice();
     function title(n){ return String(n||'').toLowerCase().replace(/\b[a-z]/g,function(c){ return c.toUpperCase(); }); }
     function rows(){ renderSector(); var out=[]; host.querySelectorAll('.sectorpick').forEach(function(r){ out.push(String(r.textContent||'').replace(/\s+/g,' ')); }); return out; }
     function judge(label){
       var rs=rows();
       if(rs.length<2){ bad.push(label+': the map screen drew '+rs.length+' maps, not both'); return; }
       for(var i=0;i<rs.length&&i<FIXED_MAPS.length;i++){
         var t=rs[i], nm=FIXED_MAPS[i].name, MS=SECTOR_MEAS[i]||{};
         if(MS.ext===undefined) continue;
         if(t.indexOf('first contact ~')>=0||t.indexOf('median haul')>=0||t.indexOf('containers a raid')>=0)
           bad.push(label+': '+nm+' still shows first contact, containers or median haul, the three figures he cut from this line');
         if(t.indexOf('of its raids in '+title(nm)+'.')<0)
           bad.push(label+': '+nm+' does not give the extract rate for that map in his words, ending "of its raids in '+title(nm)+'."');
       }
     }
     try{
       P.log=[];
       judge('a player who has never raided either map');
       P.log=[]; for(var j=0;j<FIXED_MAPS.length;j++) P.log.push({mapName:FIXED_MAPS[j].name});
       judge('a player with one run on each map');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P.log=keepLog; renderSector(); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.25',what:'the what-is-new card no longer promises Escape keeps fullscreen where it cannot: an entry about Escape and fullscreen says it only holds in the game own tab, and what happens inside another page such as itch (his report of 2026-09-12)',
'@

# CHECK 11.29 REPAIR. It required the map screen to show first contact for both
# maps, as a way of proving the screen shows the figures in the code. His own
# baked edit of this line removed first contact, and v13.26 makes that wording the
# one every player sees, so the assertion now measures a display he retired. The
# robot-owner and extract-figure assertions beside it still stand, and still bite.
SubRx @'
           if(st.indexOf('first contact ~'+SM[mi].fc+'s')<0) bad.push('map '+mi+' shows a different first contact from the code, which says '+SM[mi].fc);
'@ @'
           // r1326: first contact is no longer printed on this line; his edit cut it and v13.26 shows his wording to everyone.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
