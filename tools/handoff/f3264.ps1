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

if ($s.Contains("  {v:'32.64',what:")) { throw "check 32.64 is in the fixture already" }

SubRx @'
  {v:'32.63',what:
'@ @'
  {v:'32.64',what:'the human figures are drawn bigger (HIS art picks a01 D, a02 B, a04 C, a05 B, a09 B, a10 D): 1.25 about the feet with the build height, head 1.2, pack 1.3, a mate health bar',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, ff=PR.fill, mn={}, mx={}, rec, k, i, sc, b, hv, e1;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||!__state().player) return 'SKIP: no raid';
       if(typeof FIG_SCALE==='undefined'||typeof drawOp0!=='function') return 'the figures have no FIG_SCALE and no scaled draw';
       rec=function(){ try{ if(this.canvas===cv&&(/drawOp0/).test(String(new Error().stack))){ var d=this.getTransform().d; if(!(b in mn)||d<mn[b]) mn[b]=d; if(!(b in mx)||d>mx[b]) mx[b]=d; } }catch(_r){} };
       PR.fillRect=function(){ rec.apply(this,arguments); return of.apply(this,arguments); };
       PR.fill=function(){ rec.apply(this,arguments); return ff.apply(this,arguments); };
       hv={lean:[0.92,1.08],broad:[1.1,0.96],curved:[1,1]};
       for(b in hv){
         wc.save(); wc.setTransform(1,0,0,1,0,0);
         drawOp(100,100,0,0,'#242832',1,0,'none',0,{hero:0,build:b,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
         wc.restore();
       }
       PR.fillRect=of; PR.fill=ff;
       for(b in hv){
         if(!(b in mn)) return 'the '+b+' figure drew nothing';
         if(Math.abs(mn[b]-1.25*hv[b][1])>0.01) return 'the '+b+' body is drawn at '+mn[b].toFixed(3)+' tall, not 1.25 times its build height '+hv[b][1];
         if(mx[b]<1.25*hv[b][1]*1.2-0.01) return 'the '+b+' head/pack is not drawn bigger than the body: '+mx[b].toFixed(3);
       }
       if(!(spriteTop({kind:'raider',r:11})>=40+FIG_UP)) return 'the pillager plate does not rise over the bigger head';
       return null;
     } finally {
       PR.fillRect=of; PR.fill=ff;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
