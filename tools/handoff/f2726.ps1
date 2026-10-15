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

if ($s.Contains("  {v:'27.26',what:")) { throw "check 27.26 is in the fixture already" }

SubRx @'
  {v:'27.25',what:
'@ @'
  {v:'27.26',what:'seen in the busy frame picture: the compact controls list stands to the right of the feed on the vitals, ends before 47 percent of the width and no longer runs up over the pillagers board or the feed',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame) return 'SKIP: no raid here';
     if(typeof FEEDBOX==='undefined'||typeof LEGZ0==='undefined') return 'the controls list is not laid out beside the feed';
     var bad=[], g, L, F, Bd, Rd;
     function hit(a,b){ return !!a&&!!b&&a.w>0&&b.w>0&&a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y; }
     function r(b){ return Math.round(b.x)+','+Math.round(b.y)+' '+Math.round(b.w)+'x'+Math.round(b.h); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.legendOn=1;
       say('Scrap Metal','pick',{item:'scrap',n:1});
       for(var i=0;i<5;i++) __frame(0.016);
       L=HUDBOX.legend; F=FEEDBOX; Bd=HUDBOX.body; Rd=HUDBOX.raiders;
       if(!L||!(L.w>0)) return 'SKIP: no controls list drawn';
       if(!F.on) return 'the feed zone is not laid out';
       if(hit(L,F)) bad.push('the controls list ('+r(L)+') is on the feed ('+r(F)+')');
       if(L.x<F.x+F.w-0.5) bad.push('the controls list does not stand right of the feed');
       if(Bd&&L.y+L.h>Bd.y+0.5) bad.push('the controls list runs into the vitals');
       if(L.x+L.w>W*0.5) bad.push('the controls list reaches '+Math.round(L.x+L.w)+' of '+W);
       if(Rd&&hit(L,Rd)) bad.push('the controls list ('+r(L)+') is over the pillagers board ('+r(Rd)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
