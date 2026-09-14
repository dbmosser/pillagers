$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.36',what:
'@ @'
  {v:'14.37',what:'a pick far away sounds far away: with a fake audio context the pick voice starts at 0.07 with no distance and at well under that 580 units away (audio audit finding 3)',
   run:function(){
     if(typeof blip!=='function'||typeof AC==='undefined') return 'SKIP: no blip or audio context holder in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running, and blip is silent in a sim';
     var bad=[], LOG=[], _AC=AC, _BUS=(typeof BUS!=='undefined')?BUS:null;
     function MK(path){ var f=function(){}; return new Proxy(f,{get:function(t,k){ if(k==='currentTime') return 1; if(k==='sampleRate') return 44100; if(k==='state') return 'running'; if(k==='length') return 340; if(typeof k==='symbol') return k===Symbol.toPrimitive?function(){ return 1; }:undefined; if(k==='then'||k==='toJSON') return undefined; return MK(path+'.'+k); }, set:function(){ return true; }, apply:function(t,s2,a){ LOG.push({p:path,a:Array.prototype.slice.call(a)}); return MK(path+'()'); }}); }
     var loud=function(){ var m=0; for(var i=0;i<LOG.length;i++){ var L=LOG[i]; if(/gain\.setValueAtTime$/.test(L.p)&&typeof L.a[0]==='number') m=Math.max(m,L.a[0]); } return m; };
     try{
       __topClear();
       AC=MK('AC'); try{ BUS=null; }catch(_b){}
       // The fixture silences blip at the source and keeps the real one aside.
       var BL=(typeof _realBlip==='function')?_realBlip:blip;
       LOG.length=0; BL('pick'); var near=loud();
       // CONTROL: with no distance the pick starts at its full 0.07.
       if(Math.abs(near-0.07)>0.0005) return 'SKIP: the pick voice started at '+near+' with no distance, not 0.07, so its gain cannot be read here';
       LOG.length=0; BL('pick',580); var far=loud();
       if(!(far<0.05)) bad.push('a pick 580 units away started at '+far+', as loud as one in his hands ('+near+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ AC=_AC; try{ BUS=_BUS; }catch(_b2){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
