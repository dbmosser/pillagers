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

if ($s.Contains("  {v:'35.05',what:")) { throw "check 35.05 is in the fixture already" }

SubRx @'
  {v:'35.04',what:
'@ @'
  {v:'35.05',what:'cw-fsgatewarn, the may cause glitches line on the fullscreen gate of his 2026-10-27 order reads at 4.5 to 1 or better against the gate card',
   run:function(){
     if(typeof fsGateShow!=='function'||typeof FSG!=='object') return 'no fullscreen gate here';
     var bad=[], ff0=fsFull, fsg0={ok:FSG.ok,force:FSG.force,why:FSG.why,was:FSG.was};
     function rgb(s){ var m=/rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)/.exec(s||''); return m?[+m[1],+m[2],+m[3]]:null; }
     function lum(c){ var a=c.map(function(v){ v/=255; return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4); }); return 0.2126*a[0]+0.7152*a[1]+0.0722*a[2]; }
     try{
       __topClear();
       fsFull=function(){ return false; }; FSG.force=1; FSG.ok=0; FSG.why='start';
       fsGateShow('start');
       var g=document.getElementById('fsgate'), card=g&&g.firstElementChild, w=null;
       if(card) [].slice.call(card.querySelectorAll('div')).forEach(function(d){ if((d.textContent||'').trim()==='may cause glitches') w=d; });
       if(!w) throw new Error('no may cause glitches line on the gate');
       var fg=rgb(getComputedStyle(w).color), bg=rgb(getComputedStyle(card).backgroundColor);
       if(!fg||!bg) throw new Error('colours not readable: '+getComputedStyle(w).color+' on '+getComputedStyle(card).backgroundColor);
       var l1=lum(fg), l2=lum(bg), cr=(Math.max(l1,l2)+0.05)/(Math.min(l1,l2)+0.05);
       if(cr<4.5) bad.push('may cause glitches reads at '+cr.toFixed(2)+' to 1 (needs 4.5): '+getComputedStyle(w).color+' on '+getComputedStyle(card).backgroundColor);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fsFull=ff0; }catch(_r){}
       try{ FSG.why='start'; fsGateHide(); }catch(_h){}
       try{ for(var q in fsg0) FSG[q]=fsg0[q]; }catch(_q){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
