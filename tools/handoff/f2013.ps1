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

if ($s.Contains("  {v:'20.13',what:")) { throw "check 20.13 is in the fixture already" }

SubRx @'
  {v:'20.12',what:
'@ @'
  {v:'20.13',what:'a pillager looks the same in both co-op windows: one that has walked since he was born is rebuilt on the other window with the hair, skin, hat and build the host gave him',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof netEntNewWord!=='function'||typeof netEntFill!=='function') return 'SKIP: no co-op entity messages here';
     var bad=[], g, r=null, i, m, e, diff=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&g.ents[i].ident&&g.ents[i].skin){ r=g.ents[i]; break; }
       if(!r) return 'SKIP: no pillager with a look';
       var x0=r.x, y0=r.y; r.x+=37; r.y-=23; r.nid=r.nid||9999;
       m=netEntNewWord(r); r.x=x0; r.y=y0;
       e={kind:'raider'}; netEntFill(e,m);
       ['hair','skin','hat','cut','build'].forEach(function(k){ if(e[k]!==r[k]) diff.push(k+' '+e[k]+' for '+r[k]); });
       if(diff.length) bad.push('the other window draws him differently: '+diff.join(', '));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
