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

if ($s.Contains("  {v:'25.54',what:")) { throw "check 25.54 is in the fixture already" }

SubRx @'
  {v:'25.53',what:
'@ @'
  {v:'25.54',what:'his rule (2026-10-12), exactly the same in DEMO and CAREER: a CAREER raid has the DEMO vaults with their keycards in boxes outside, an elite kill drops a KEYCARD box while a vault is shut, and opening a vault pays +500 into the CAREER score',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof arcadeVaults!=='function'||typeof arcadeVaultPay!=='function'||typeof mkCrawler!=='function') return 'SKIP: no vaults here';
     var bad=[], g, p, e, i, V, kb, kb0, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, s0, r;
     function kboxes(gg){ return gg.containers.filter(function(c){ return c&&c.loot&&c.loot.indexOf('keycard')>=0; }); }
     try{
       __topClear(); __runPrep();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       p=g.player;
       V=(g.map.locked||[]).filter(function(R){ return R&&R.arc; });
       if(V.length<1) bad.push('a CAREER raid has no vault');
       if(!g.containers.some(function(c){ return c&&c.vault; })) bad.push('a CAREER raid has no vault boxes');
       kb0=kboxes(g).length;
       if(V.length&&kb0<V.length) bad.push('a CAREER raid has '+kb0+' keycards out for '+V.length+' vaults');
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=1; e.hp=0; g.ents.push(e); __ents(0.016);
       if(V.length&&kboxes(g).length!==kb0+1) bad.push('an elite kill in a CAREER raid with a vault shut left '+(kboxes(g).length-kb0)+' new keycard boxes, not 1');
       if(V.length){
         s0=g.cs.s|0; r=arcadeVaultPay(V[0]);
         if((g.cs.s|0)-s0!==500) bad.push('opening a CAREER vault paid '+((g.cs.s|0)-s0)+' into the score, not 500');
         if(!r||String(r.sub||'').indexOf('500')<0) bad.push('the VAULT OPEN line carries no +$500');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
