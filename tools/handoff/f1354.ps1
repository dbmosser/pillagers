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
  {v:'13.53',what:
'@ @'
  {v:'13.54',what:'the Bandages a raid issues are not banked: extracting with the issued pair and nothing found adds no Bandage to the stash, while a Bandage found in the raid is still banked, exactly one for one (end-of-raid audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     var bad=[], P2=__P(), keepStash=(P2.stash||[]).slice();
     function bands(){ var c=0, st=P2.stash||[]; for(var i=0;i<st.length;i++) if(st[i]==='bandage') c++; return c; }
     function run(found){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       g.ents.length=0; g.player.downed=false; g.pedCarry=0;
       var issued=0; for(var i=0;i<g.bag.length;i++) if(g.bag[i]==='bandage') issued++;
       if(!issued) return {skip:1};
       for(i=0;i<found;i++) g.bag.push('bandage');
       var before=bands();
       __endRaid('extract');
       return {issued:issued, added:bands()-before};
     }
     try{
       var A=run(0);
       if(A===null) return 'SKIP: no live raid to extract from';
       if(A.skip) return 'SKIP: this landing issued no Bandages to test';
       if(A.added!==0) bad.push('extracting with only the '+A.issued+' issued Bandages added '+A.added+' Bandage(s) to the stash, free kit banked every raid');
       // CONTROL: a Bandage found in the raid is still banked.
       var B=run(1);
       if(B&&!B.skip&&B.added!==1) bad.push((B.added<1?'control: ':'')+'extracting with the issued pair plus one Bandage found added '+B.added+' to the stash, not the one he found');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.stash=keepStash; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
