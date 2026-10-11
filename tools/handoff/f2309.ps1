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

if ($s.Contains("  {v:'23.09',what:")) { throw "check 23.09 is in the fixture already" }

SubRx @'
  {v:'23.08',what:
'@ @'
  {v:'23.09',what:'the in-ring hint says call for extraction, his v9.59 verb: standing in an open ring with nothing called, the hint reads Hold [E] to call for extraction, and no line of the game uses the old shorter verb phrase',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof outHint!=='function'||typeof padOn!=='function') return 'SKIP: no hint here';
     var bad=[], g, p, z=null, i, h, src='', cut, oPad=padOn, rx=new RegExp('call'+'\\s+'+'extraction','i'), m;
     try{
       try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(_s){}
       cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
       m=rx.exec(src); if(m) bad.push('the build still says '+src.slice(Math.max(0,m.index-40),m.index+30).replace(/\s+/g,' '));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       padOn=function(){ return false; };
       p=g.player;
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].hold=null; }
       g.active=null; g.beaconT=null;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) return 'SKIP: no open extraction ring here';
       p.x=z.x; p.y=z.y;
       h=outHint(1); if(h!=='Hold ['+keyLabel('KeyE','E')+'] to call for extraction') bad.push('in a ring with nothing called the hint is '+JSON.stringify(h));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       padOn=oPad; keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
