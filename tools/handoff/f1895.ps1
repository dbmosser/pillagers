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

if ($s.Contains("  {v:'18.95',what:")) { throw "check 18.95 is in the fixture already" }

SubRx @'
  {v:'18.94',what:
'@ @'
  {v:'18.95',what:'the Undercroft floor text grows with the screen: at 4K the title and the key footer are drawn at least 1.6 times their 1080p size',
   run:function(){
     if(typeof __hubEnter!=='function'||typeof __loop!=='function'||!window.__forceSize) return 'SKIP: no Undercroft floor here';
     var bad=[], t, oFT=ctx.fillText, a1, a4, f1, f4;
     function grab(){ var out={t:null,f:null}; ctx.fillText=function(s){ var m=(/([\d.]+)px/).exec(String(ctx.font)), px=m?parseFloat(m[1]):0, sc=ctx.getTransform().a/((typeof DPR==='number'&&DPR>0)?DPR:1); if(String(s)==='THE UNDERCROFT') out.t=px*sc; if(String(s).indexOf('USE STATION')>=0) out.f=px*sc; return oFT.apply(this,arguments); }; try{ __loop(performance.now()); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return out; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __forceSize(1920,1080); __hubEnter(); __loop(performance.now()); a1=grab();
       __forceSize(3840,2160); __loop(performance.now()+17); a4=grab();
       if(a1.t===null||a4.t===null) return 'SKIP: the floor title was not drawn';
       if(a4.t<a1.t*1.6) bad.push('at 4K the title is '+a4.t.toFixed(1)+'px against '+a1.t.toFixed(1)+'px at 1080p');
       if(a1.f!==null&&a4.f!==null&&a4.f<a1.f*1.6) bad.push('at 4K the key footer is '+a4.f.toFixed(1)+'px against '+a1.f.toFixed(1)+'px at 1080p');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
