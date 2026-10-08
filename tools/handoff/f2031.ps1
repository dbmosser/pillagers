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

if ($s.Contains("  {v:'20.31',what:")) { throw "check 20.31 is in the fixture already" }

SubRx @'
  {v:'20.30',what:
'@ @'
  {v:'20.31',what:'a co-op guest is paid and scored for the Terms the shared raid was built with: a raid holding its own Terms reads them while it runs and as it ends, and the Undercroft still reads the player own',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof termsPay!=='function'||typeof hasTerm!=='function'||typeof netUpStart!=='function') return 'SKIP: no raid or Terms here';
     var bad=[], t0, g, src, nd;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t0=P.terms; P.terms=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.terms=['known','patrols'];
       if(!hasTerm('known')) bad.push('a raid built under THEY KNOW YOU does not read it');
       if(!(Math.abs(termsPay()-0.60)<1e-9)) bad.push('the raid pays '+termsPay()+' for its Terms, not 0.60');
       g.over='extract';
       if(!(Math.abs(termsPay(1)-0.60)<1e-9)) bad.push('as the raid ends it pays '+termsPay(1)+', not 0.60');
       if(hasTerm('known')||termsPay()!==0) bad.push('the Undercroft reads the raid Terms, not the player own');
       g.over=false;
       src=String(netUpStart); nd='G.ter'+'ms=';
       if(src.indexOf(nd)<0) bad.push('a guest raid never keeps the Terms the host built it with');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} if(t0!==undefined) P.terms=t0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
