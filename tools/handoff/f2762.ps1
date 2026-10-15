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

if ($s.Contains("  {v:'27.62',what:")) { throw "check 27.62 is in the fixture already" }

SubRx @'
  {v:'27.61',what:
'@ @'
  {v:'27.62',what:'cloud-menus-haul-reveal-stops: the EXTRACTED card closed mid reveal (as the party lift closes it) ends the reveal and plays no more pick sounds',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof haulRevealing!=='function'||typeof haulRevealTick!=='function'||typeof netCardOff!=='function'||typeof HAUL_REV==='undefined') return 'SKIP: no haul reveal in this fixture';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[], oSfx=sfx, n=0, k, closed;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       G.player.iv=99; G.bag=['scrap','board','optic','servo','core','medkit','wire','cell'];
       __endRaid('extract');
       if(!haulRevealing()) return 'SKIP: staging: the haul did not start revealing';
       closed=netCardOff();
       if(!closed) return 'SKIP: staging: the card did not close';
       sfx=function(){ n++; };
       haulRevealTick(5); haulRevealTick(5);
       if(haulRevealing()) bad.push('the haul still reveals after its card closed');
       if(n) bad.push(n+' pick sounds played after the card closed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sfx=oSfx; HAUL_REV=null;
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
