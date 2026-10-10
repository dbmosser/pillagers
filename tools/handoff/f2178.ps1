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

if ($s.Contains("  {v:'21.78',what:")) { throw "check 21.78 is in the fixture already" }

SubRx @'
  {v:'21.77',what:
'@ @'
  {v:'21.78',what:'his notes: the Crier lines read like a shooter HUD, A CRIER IS REVEALING YOUR LOCATION and then CRIER REVEALED YOUR LOCATION',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)||typeof mkSnitch!=='function') return 'SKIP: this fixture cannot deploy and step';
     var bad=[], said=[], realSay=say;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='snitch') g.ents[i].hp=0;
       var cr=mkSnitch(p.x+240,p.y); cr.state='alarm'; cr.wind=0.01; cr.markX=p.x; cr.markY=p.y; cr.lost=0; g.ents.push(cr);
       __ents(0.1);
       if(!said.some(function(t){ return /^CRIER REVEALED YOUR (LAST )?LOCATION$/.test(t); })) bad.push('the alarm line is not CRIER REVEALED YOUR LOCATION (said: '+said.join(' | ').slice(0,120)+')');
       var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd="'A CRIER IS REVEALING"+" YOUR LOCATION'";
       if(src.split(nd).length-1<2) bad.push('the spot line is not A CRIER IS REVEALING YOUR LOCATION on both windows');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ say=realSay; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
