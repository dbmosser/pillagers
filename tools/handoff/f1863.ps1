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

if ($s.Contains("  {v:'18.63',what:")) { throw "check 18.63 is in the fixture already" }

SubRx @'
  {v:'18.62',what:
'@ @'
  {v:'18.63',what:'every station name sits on its plate: the plate is centred where the name is drawn and covers its letters, and the warning under THE LAST POUR starts below the name plate',
   run:function(){
     if(typeof __hubEnter!=='function'||typeof __loop!=='function'||typeof HB==='undefined') return 'SKIP: no Undercroft floor here';
     var bad=[], oR=wc.fillRect, oT=wc.fillText, ops=[], t, i, j, labs={}, n=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __loop(performance.now());
       (HB.stations||[]).forEach(function(s){ labs[s.label]=s; });
       wc.fillRect=function(x,y,w,h){ ops.push({k:'r',x:x,y:y,w:w,h:h}); return oR.apply(this,arguments); };
       wc.fillText=function(s,x,y){ var m=wc.measureText(String(s)); ops.push({k:'t',s:String(s),x:x,y:y,a:m.actualBoundingBoxAscent||0,d:m.actualBoundingBoxDescent||0}); return oT.apply(this,arguments); };
       try{ __loop(performance.now()+17); } finally { delete wc.fillRect; delete wc.fillText; if(wc.fillRect!==oR) wc.fillRect=oR; if(wc.fillText!==oT) wc.fillText=oT; }
       for(i=0;i<ops.length;i++){
         if(ops[i].k!=='t'||!labs[ops[i].s]) continue;
         var T=ops[i], R=null; for(j=i-1;j>=0;j--) if(ops[j].k==='r'){ R=ops[j]; break; }
         if(!R) continue; n++;
         if(Math.abs((R.x+R.w/2)-T.x)>2) bad.push(T.s+': plate centre '+Math.round(R.x+R.w/2)+', name centre '+Math.round(T.x));
         if(R.y>T.y-T.a*0.85) bad.push(T.s+': the plate covers only the lower part of the letters');
         if(labs[T.s].id==='bar'){ for(j=i+1;j<ops.length;j++) if(ops[j].k==='t'&&ops[j].s.indexOf('EXPERIMENTAL')>=0){ if(ops[j].y-ops[j].a<R.y+R.h-0.5) bad.push('the warning under '+T.s+' prints into its name plate'); break; } }
       }
       if(!n) return 'SKIP: no station names were drawn';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete wc.fillRect; delete wc.fillText; if(wc.fillRect!==oR) wc.fillRect=oR; if(wc.fillText!==oT) wc.fillText=oT; __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'18.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
