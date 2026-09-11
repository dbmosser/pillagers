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

# v12.70 CHECK, inserted before the v12.69 entry. It writes a district card with
# a sentence naming a place that does NOT exist on the sector it will be read on,
# which is the exact state a sector change leaves behind, and then asks what the
# card says. The place names come off the maps themselves rather than out of this
# check, so a renamed zone moves the check with it. It skips honestly if the
# build offers only one sector, since there would be nothing to switch to.
SubRx @'
  {v:'12.69',what:'the XP a run pays for its haul counts what it brought back and not what the lift carried up, and the career best does the same, while a haul actually found in the raid pays exactly what it always did (2026-09-08 audit, the other side of v12.65)',
'@ @'
  {v:'12.70',what:'a search contract names a place on the sector he is playing: a card written on one sector and read on another names a place that exists there, instead of the frozen name of a place on the sector it was rolled on, while a card of any other type still reads what it was written with (2026-09-08 audit)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof districtPlaceName!=='function'||typeof FIXED_MAPS==='undefined') return 'SKIP: this build has no districts to name';
     if(FIXED_MAPS.length<2) return 'SKIP: this build offers one sector, so there is nothing to switch to';
     // Read the sentence the way the board does. On a build with no live reader the
     // stored sentence IS what the board prints, so the old build FAILS here
     // rather than excusing itself with a skip, which is what a control is for.
     function __cdRead(c){ return (typeof contractDesc==='function')?contractDesc(c):((c&&c.desc)||''); }
     var bad=[], P2=__P(), keepMap=P2.mapIx, keepC=(P2.contracts||[]).slice();
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // The same district, named on each sector. If the two sectors happen to
       // give it the same name there is nothing here to tell apart.
       var D=2, i, names=[];
       for(i=0;i<FIXED_MAPS.length;i++){ P2.mapIx=i; names.push(String(districtPlaceName(D)||'')); }
       if(!names[0]||!names[1]) return 'SKIP: that district has no name on one of the sectors';
       if(names[0]===names[1]) return 'SKIP: both sectors call that district the same thing, so a stale name could not be told from a live one';
       // THE FINDING: the card was written on sector 0 and is being read on 1.
       P2.mapIx=0;
       var card={type:'district',d:D,n:3,prog:0,reward:480,desc:'Search 3 containers in '+names[0]};
       P2.contracts=[card];
       P2.mapIx=1;
       var said=String(__cdRead(card)||'');
       if(said.indexOf(names[0])>=0)
         bad.push('the card still names '+names[0]+', which is on the other sector: he was rolled that errand before he changed sector and the board is sending him to a place that is not on the map he is playing');
       if(said.indexOf(names[1])<0)
         bad.push('the card does not name '+names[1]+', which is what that district is called on the sector he is playing; it reads ['+said+']');
       // CONTROL ONE: switch back, and it must follow again rather than sticking
       // to whatever it said last.
       P2.mapIx=0;
       var back=String(__cdRead(card)||'');
       if(back.indexOf(names[0])<0)
         bad.push('control: back on the first sector the card no longer names '+names[0]+' either, so the sentence is not following the sector at all ['+back+']');
       // CONTROL TWO: a card of any other type must read exactly what it was
       // written with, so this build has not started rewriting every card.
       var kill={type:'kill',tgt:'sentry',n:4,prog:0,reward:600,desc:'Destroy 4 Sentries'};
       if(String(__cdRead(kill)||'')!=='Destroy 4 Sentries')
         bad.push('control: a card that is not a search card now reads ['+__cdRead(kill)+'] rather than what it was written with');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.mapIx=keepMap; P2.contracts=keepC; saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.69',what:'the XP a run pays for its haul counts what it brought back and not what the lift carried up, and the career best does the same, while a haul actually found in the raid pays exactly what it always did (2026-09-08 audit, the other side of v12.65)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
