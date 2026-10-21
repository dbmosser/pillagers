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

if ($s.Contains("  {v:'33.22',what:")) { throw "check 33.22 is in the fixture already" }

SubRx @'
  {v:'33.21',what:
'@ @'
  {v:'33.22',what:'the human figures are back to their old size: a standing pillager is drawn no taller than before v32.64 (his order: player is too big)',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, ff=PR.fill, mn={}, rec, i, b, hv;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||!__state().player) return 'SKIP: no raid';
       if(typeof FIG_SCALE==='undefined'||typeof drawOp0!=='function') return 'the figures have no FIG_SCALE and no scaled draw';
       if(FIG_SCALE>1) return 'FIG_SCALE is '+FIG_SCALE+', bigger than the old size 1';
       rec=function(){ try{ if(this.canvas===cv&&(/drawOp0/).test(String(new Error().stack))){ var d=this.getTransform().d; if(!(b in mn)||d<mn[b]) mn[b]=d; } }catch(_r){} };
       PR.fillRect=function(){ rec.apply(this,arguments); return of.apply(this,arguments); };
       PR.fill=function(){ rec.apply(this,arguments); return ff.apply(this,arguments); };
       hv={lean:1.08,broad:0.96,curved:1};
       for(b in hv){
         wc.save(); wc.setTransform(1,0,0,1,0,0);
         drawOp(100,100,0,0,'#242832',1,0,'none',0,{hero:0,build:b,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
         wc.restore();
       }
       PR.fillRect=of; PR.fill=ff;
       for(b in hv){
         if(!(b in mn)) return 'the '+b+' figure drew nothing';
         if(mn[b]>hv[b]+0.01) return 'the '+b+' body is drawn '+mn[b].toFixed(3)+' tall, taller than its build height '+hv[b]+' at the old size';
       }
       return null;
     } finally {
       PR.fillRect=of; PR.fill=ff;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'33.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
