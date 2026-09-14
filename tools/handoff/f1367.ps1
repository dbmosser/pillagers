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
  {v:'13.66',what:
'@ @'
  {v:'13.67',what:'issued Bandages are spent first however they leave the backpack: dropping the issued pair and then finding as many banks every one found, and using one then finding one banks exactly one (in-raid audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof dropItem!=='function'||typeof tickHeal!=='function'||typeof useMedical!=='function') return 'SKIP: no drop or heal verbs in this build';
     var bad=[], P2=__P(), keepStash=(P2.stash||[]).slice();
     function bands(){ var c=0, st=P2.stash||[]; for(var i=0;i<st.length;i++) if(st[i]==='bandage') c++; return c; }
     function land(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       g.ents.length=0; g.player.downed=false; g.player.iv=99; g.pedCarry=0;
       tickHeal(0.016);
       return g;
     }
     function issuedIn(g){ var c=0; for(var i=0;i<g.bag.length;i++) if(g.bag[i]==='bandage') c++; return c; }
     try{
       // THE FINDING: drop every issued Bandage, then find as many.
       var g=land(); if(!g) return 'SKIP: no live raid to extract from';
       var iss=issuedIn(g); if(!iss) return 'SKIP: this landing issued no Bandages to test';
       for(var i=g.bag.length-1;i>=0;i--) if(g.bag[i]==='bandage') dropItem(i);
       tickHeal(0.016);
       for(i=0;i<iss;i++) g.bag.push('bandage');
       tickHeal(0.016);
       var before=bands(); __endRaid('extract'); var added=bands()-before;
       if(added!==iss) bad.push('after dropping the '+iss+' issued Bandages and finding '+iss+', the extraction banked '+added+' of them');
       // SECOND ARM: a use then a find banks exactly the one found, not two (no double count).
       g=land();
       if(g&&issuedIn(g)){
         g.player.hp=40; g.player.prep=null; g.player.healQ=0; g.player.healCap=undefined;
         useMedical(); tickHeal(0.016);
         g.bag.push('bandage'); tickHeal(0.016);
         before=bands(); __endRaid('extract'); added=bands()-before;
         if(added!==1) bad.push((added<1?'control: ':'')+'using one issued Bandage and finding one banked '+added+', not the one he found');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.stash=keepStash; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.prep=null; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
