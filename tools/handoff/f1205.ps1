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

# CHECK 11.44'S SENTINEL was pinned at 17 by the v11.77 stamp bump and could
# never fire again; it fires on any stamp at or above 17 now.
SubRx @'
       if(P.cfgv===17) bad.push('cfgv was stamped to 17 during the load, which is saveProfile running before the cfgv block');
'@ @'
       if(P.cfgv>=17) bad.push('cfgv was stamped to '+P.cfgv+' during the load, which is saveProfile running before the cfgv block');
'@

# v11.97 CHECK, inserted before the v11.96 entry. A real pillager with a real
# frag in his bag is asked to throw at the player from 200 units (inside the
# new near edge) and from 260 (inside the band); the card line is read.
SubRx @'
  {v:'11.96',what:'a station window no longer repeats the credits and XP in its heading under the corner readout: the heading balance is hidden or clear of the readout (2026-09-06 review of v11.78)',
'@ @'
  {v:'11.97',what:'a pillager will not throw a frag from inside his own blast: the throw band starts at the radius plus 52 (242 at 190) and still throws at 260, and the card prints the true centre damage (2026-09-06 review of v11.77)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof raiderThrow!=='function'||typeof WHATSNEW==='undefined') return 'SKIP: no pillager throw or card in this build';
     var bad=[], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fragR=190;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, e=null;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed&&!g.ents[i].finished&&!g.ents[i].merc) e=g.ents[i];
       if(!e) return 'SKIP: no pillager to hand a frag to';
       function ask(fd){
         e.bag=['frag']; e.thrT=0; e.smkT=99; e.hp=e.maxhp||100; e.downed=false; e.rng=Math.max(e.rng||0,520);   // a long-armed pillager, so the reach floor is not what stops him
         var n0=g.frags.length;
         var r=raiderThrow(e,p,fd,0.016);
         return {threw:!!r,frags:g.frags.length-n0};
       }
       var near=ask(200);
       if(near.threw||near.frags) bad.push('a pillager threw from 200 units, inside his own 190 blast');
       var band=ask(260);
       if(!band.threw||!band.frags) bad.push('control: a pillager would not throw from 260 units, so the band is not live here');
       var line=null; for(i=0;i<WHATSNEW.length;i++) if(WHATSNEW[i].indexOf('FRAG CHARGES REACH FURTHER')===0) line=WHATSNEW[i];
       if(!line) bad.push('control: the card has no frag line to read');
       else if(line.indexOf('140 at the centre')<0||line.indexOf('98 at the centre')<0) bad.push('the card still prints the coefficients as the centre damage: '+line.slice(0,120));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); __resetCfg(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.96',what:'a station window no longer repeats the credits and XP in its heading under the corner readout: the heading balance is hidden or clear of the readout (2026-09-06 review of v11.78)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
