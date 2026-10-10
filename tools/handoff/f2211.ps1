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

if ($s.Contains("  {v:'22.11',what:")) { throw "check 22.11 is in the fixture already" }

SubRx @'
  {v:'22.10',what:
'@ @'
  {v:'22.11',what:'a party guest build leaves the imported friend off the bodies, so the pillager the host rolled keeps his own name and record there, while a raid this window runs still brings the friend',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof applyGhost!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oGh=P.ghost, TAG='ZQPALGHOST', e=null, i, g;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       P.ghost={tag:TAG,wep:'sniper',rate:30};
       NET.upHold=true; NET.upIss=null;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       NET.upHold=false;
       g=__state(); if(!g||g.over||!g.ents) return 'SKIP: staging: no raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: staging: no pillager in the raid';
       if(e.name===TAG||e.ghost) bad.push('a party guest build put this window imported friend on a pillager the host runs as someone else');
       if(String(e.ident||'').indexOf('ghost_')===0) bad.push('a kill of that pillager on the guest would be written to the friend record');
       if(g.tel&&g.tel.ghostIn) bad.push('the guest run says the friend was in the raid');
       applyGhost();
       if(e.name!==TAG||e.ident!=='ghost_'+TAG) bad.push('control: in a raid this window runs, the friend did not take the first pillager');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       if(oGh===undefined) delete P.ghost; else P.ghost=oGh;
       try{ if(P.rivals) delete P.rivals['ghost_'+TAG]; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
