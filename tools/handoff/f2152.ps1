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

if ($s.Contains("  {v:'21.52',what:")) { throw "check 21.52 is in the fixture already" }

SubRx @'
  {v:'21.51',what:
'@ @'
  {v:'21.52',what:'a hire on FOLLOW who hears a noise is moved by his order alone: the investigate step lets him go and he is back on loot',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateEnts!=='function'||typeof hireOrdered!=='function') return typeof hireOrdered!=='function'?'control: the investigate step still moves a hire on an order':'SKIP: no raid here';
     var bad=[], g, e=null, i, o0, E0;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: staging: no pillager to hire';
       o0=g.mercOrder; e.merc=1; e.hostile=false; g.mercOrder='follow';
       e.x=g.player.x+150; e.y=g.player.y; e.state='investigate'; e.tx=g.player.x+900; e.ty=g.player.y;
       E0=g.ents; g.ents=[e];
       updateEnts(0.05);
       g.ents=E0;
       if(e.state==='investigate') bad.push('a hire on FOLLOW stayed on the noise, so the investigate step still moves him');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ try{ var g2=__state(); if(g2&&E0) g2.ents=E0; if(g2) g2.mercOrder=o0; if(e){ e.merc=0; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
