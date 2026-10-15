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

if ($s.Contains("  {v:'27.40',what:")) { throw "check 27.40 is in the fixture already" }

SubRx @'
  {v:'27.39',what:
'@ @'
  {v:'27.40',what:'his answer: a row for the style medals is reserved between the feed and the vitals, the width of the feed, and nothing else draws in it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame) return 'SKIP: no raid here';
     if(typeof MEDALBOX==='undefined') return 'this build reserves no medal spot';
     var bad=[], g, i, F, M, Bd;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       for(i=0;i<10;i++) say('MEDAL TEST LINE '+i,'info');
       for(i=0;i<4;i++) __frame(0.016);
       F=FEEDBOX; M=MEDALBOX; Bd=HUDBOX.body;
       if(!M.on||!(M.w>0)||!(M.h>0)) return 'the medal spot is not laid out';
       if(M.h<48*Math.max(1,hudRes())) bad.push('the medal spot is '+M.h+' tall, under the 48 px emblem');
       if(F.y+F.h>M.y+0.5) bad.push('the feed ('+Math.round(F.y+F.h)+') reaches the medal spot ('+Math.round(M.y)+')');
       if(Bd&&M.y+M.h>Bd.y+0.5) bad.push('the medal spot runs into the vitals');
       if(Math.abs(M.w-F.w)>2||Math.abs(M.x-F.x)>2) bad.push('the medal spot is not the width and the left edge of the feed');
       if(F.rows.length!==FEED.show) bad.push('the feed shows '+F.rows.length+' lines, not '+FEED.show);
       if(typeof hudRects==='function'&&!hudRects().medals) bad.push('the medal spot is not in the HUD registry');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
