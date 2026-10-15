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

if ($s.Contains("  {v:'27.35',what:")) { throw "check 27.35 is in the fixture already" }

SubRx @'
  {v:'27.34',what:
'@ @'
  {v:'27.35',what:'seen in the busy frame picture: the feed zone is a quarter of the screen wide and ten lines tall, so the controls list beside it keeps a readable size',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame) return 'SKIP: no raid here';
     if(typeof FEEDBOX==='undefined'||typeof feedRect!=='function') return 'this build has no feed zone';
     var bad=[], g, F, L, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.legendOn=1;
       say('Scrap Metal','pick',{item:'scrap',n:1});
       for(i=0;i<6;i++) __frame(0.016);
       F=FEEDBOX; L=HUDBOX.legend;
       if(!F.on) return 'the feed zone is not laid out';
       if(F.w>W*0.26) bad.push('the feed zone is '+Math.round(F.w)+' wide of '+W+', over a quarter');
       if(F.w<W*0.18) bad.push('the feed zone is only '+Math.round(F.w)+' wide of '+W);
       if(!L||!(L.w>0)) return 'SKIP: no controls list drawn';
       if(HUDZ.legend<1.0) bad.push('the controls list is squeezed to zoom '+HUDZ.legend.toFixed(2)+' beside the feed');
       if(L.x+L.w>W*0.47+2) bad.push('the controls list reaches '+Math.round(L.x+L.w)+' of '+W);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
