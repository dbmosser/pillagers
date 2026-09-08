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

# v12.52 CHECK, inserted before the v12.51 entry. It works out the Riot
# Scattergun reach from the weapon table rather than writing 187 down, so the
# check follows the dial if the gun is ever retuned, and it skips honestly if
# that reach ever grows past the safe edge, because then there is nothing here
# to find. The controls are the two halves v12.20 promised and this build has to
# keep: an ordinary pillager still throws from outside the blast, and the charge
# he throws lands outside his own radius.
SubRx @'
  {v:'12.51',what:'a Howler does not shell its own crater: its own impact no longer winds its eight second bearing back to full or moves that bearing onto the burst, so one noise from a man who then goes quiet brings the shells the bearing honestly allows and no barrage (2026-09-07 audit)',
'@ @'
  {v:'12.52',what:'a pillager whose whole reach is inside his own blast does not throw a charge at all, instead of throwing from a band one unit wide inside his own explosion; an ordinary pillager still throws from outside the blast and his charge still lands clear of him (2026-09-07 audit, my defect from v12.20)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof raiderThrow!=='function') return 'SKIP: no pillager throw in this build';
     if(!(WEAPONS&&WEAPONS.shotgun&&WEAPONS.shotgun.rng)) return 'SKIP: this build has no Riot Scattergun to stage';
     var bad=[], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fragR=190;
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player, e=null;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed&&!g.ents[i].finished&&!g.ents[i].merc) e=g.ents[i];
       if(!e) return 'SKIP: no pillager to hand a charge to';
       // The reach comes off the weapon table, not out of this check, so it
       // follows the dial if the gun is ever retuned.
       var SHOT=WEAPONS.shotgun.rng*0.72, EDGE=190+52;
       if(SHOT>=EDGE) return 'SKIP: the Riot Scattergun reach of '+Math.round(SHOT)+' now clears the safe edge of '+EDGE+', so the man this check is about no longer exists';
       function ask(fd,rng){
         e.bag=['frag']; e.thrT=0; e.smkT=99; e.hp=e.maxhp||100; e.downed=false; e.finished=false;
         e.rng=rng;
         var n0=g.frags.length;
         var r=raiderThrow(e,p,fd,0.016);
         var f=(g.frags.length>n0)?g.frags[g.frags.length-1]:null;
         return {threw:!!r,made:g.frags.length-n0,
                 own:f?Math.sqrt((f.x-e.x)*(f.x-e.x)+(f.y-e.y)*(f.y-e.y)):null};
       }
       // THE FINDING: the whole window the old band left him, which is the last
       // unit before his own reach and is inside the blast he is throwing.
       var A=ask(SHOT-0.7,SHOT);
       if(A.threw||A.made)
         bad.push('a Riot Scattergun pillager threw a charge from '+Math.round(SHOT-0.7)+' units, which is inside the '+EDGE+' unit edge his own blast needs: his whole reach is '+Math.round(SHOT)+', so every throw he can make lands on himself');
       // CONTROL ONE: an ordinary pillager still throws from outside the blast,
       // or a build that simply stopped every throw reads green above.
       var B=ask(260,520);
       if(!B.threw||!B.made) bad.push('control: a pillager with an ordinary reach would not throw from 260 units, so the band is not live here and nothing above proves anything');
       // CONTROL TWO: and what he threw landed clear of him, which is the whole
       // point v12.20 was written for.
       else if(!(B.own>190)) bad.push('control: the charge an ordinary pillager threw landed '+Math.round(B.own)+' units from him, inside the 190 blast, so v12.20 is undone');
       // AND NOT ONLY AT THAT ONE DISTANCE. His whole reach is inside his own
       // blast, so there must be no distance he can reach from at which he throws.
       var thrown=[], fd2;
       for(fd2=20;fd2<SHOT;fd2+=8){ if(ask(fd2,SHOT).made) thrown.push(Math.round(fd2)); }
       if(thrown.length) bad.push(String("a Riot Scattergun pillager still throws from ")+thrown.length+" distances inside his own reach ("+thrown.slice(0,6).join(", ")+"), and every one of them is inside the blast");
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ __topClear(); __cleanProfile(); __resetCfg(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.51',what:'a Howler does not shell its own crater: its own impact no longer winds its eight second bearing back to full or moves that bearing onto the burst, so one noise from a man who then goes quiet brings the shells the bearing honestly allows and no barrage (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
