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

if ($s.Contains("  {v:'30.67',what:")) { throw "check 30.67 is in the fixture already" }

SubRx @'
  {v:'30.66',what:
'@ @'
  {v:'30.67',what:'the Run info panel has a white title and grey section headings, no lime (the critic, 10-19)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oF=ctx.fillText, rec=[], t, lime=[], i;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       ctx.fillText=function(s){ rec.push({s:String(s),c:String(this.fillStyle).toLowerCase()}); return oF.apply(this,arguments); };
       try{ __frame(0.016); }finally{ ctx.fillText=oF; }
       t=rec.filter(function(r){ return (/^run info$/i).test(r.s); });
       if(!t.length) return 'the Run info panel is not drawn in this staging';
       if(t[t.length-1].c==='#e6ff3d') return 'the Run info title is lime';
       for(i=0;i<rec.length;i++){ if(rec[i].c==='#e6ff3d'&&(/^(run goals|contracts)$/i).test(rec[i].s)) lime.push(rec[i].s); }
       if(lime.length) return 'a Run info section heading is lime: '+lime.join(',');
       return null;
     } finally {
       ctx.fillText=oF;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
