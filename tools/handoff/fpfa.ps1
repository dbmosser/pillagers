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

if ($s.Contains("  {v:'29.32',what:")) { throw "check 29.32 is in the fixture already" }

SubRx @'
  {v:'29.31',what:
'@ @'
  {v:'29.32',what:'the title and mode menu run on the shared look: tokens in the CSS equal UIT, the ui-shared block has no raw color or font-size literals, the mode rows are 20px with a 4px radius, Panel P draws (his order 2026-10-18, one shared UI)',
   run:function(){
     if(typeof UIT==='undefined'||typeof uiFont!=='function'||typeof uiPanel!=='function') return 'no shared UI object (UIT, uiFont, uiPanel)';
     var st=document.getElementById('ui-shared'), cs=getComputedStyle(document.documentElement), k, txt, bodies, i, bad=[], cv, c, d, e;
     if(!st) return 'no <style id=ui-shared> block';
     for(k in UIT.fs){ if(cs.getPropertyValue('--fs-'+k).trim()!==UIT.fs[k]+'px') return 'token --fs-'+k+' is not UIT.fs.'+k; }
     for(k in UIT.sp){ if(cs.getPropertyValue('--sp-'+k).trim()!==UIT.sp[k]+'px') return 'token --sp-'+k+' is not UIT.sp.'+k; }
     if(cs.getPropertyValue('--rad').trim()!==UIT.rad+'px') return 'token --rad is not UIT.rad';
     txt=st.textContent.replace(/\/\*[\s\S]*?\*\//g,'');
     bodies=txt.match(/\{[^}]*\}/g)||[];
     for(i=0;i<bodies.length;i++){
       if(/#[0-9a-fA-F]{3,8}\b/.test(bodies[i])||/rgba?\(/.test(bodies[i])||/font-size\s*:\s*[\d.]+(px|em|rem)/.test(bodies[i])||/font\s*:[^;]*[\d.]+px/.test(bodies[i])||/(^|[^\w.-])(?!1px\b|3px\b)\d+(\.\d+)?px/.test(bodies[i])) bad.push(bodies[i].slice(0,70));
     }
     if(bad.length) return 'ui-shared still has raw literals: '+bad[0];
     if(!bodies.length||txt.indexOf('#title')<0) return 'ui-shared has no title rules';
     e=document.getElementById('modecoop'); if(!e) return 'no mode row';
     if(getComputedStyle(e).fontSize!=='20px') return 'mode row font is '+getComputedStyle(e).fontSize+', not the 20px body size';
     if(getComputedStyle(e).borderTopLeftRadius!=='4px') return 'mode row radius is '+getComputedStyle(e).borderTopLeftRadius+', not 4px';
     if(getComputedStyle(document.getElementById('titlestart')).minHeight!=='56px') return 'the 1 player button is not the 56px primary';
     if(uiFont('title',2).indexOf('64px')<0) return 'uiFont(title,2) is '+uiFont('title',2);
     cv=document.createElement('canvas'); cv.width=40; cv.height=30; c=cv.getContext('2d');
     uiPanel(c,0,0,40,30,null);
     d=c.getImageData(20,15,1,1).data;
     if(Math.abs(d[0]-22)>2||Math.abs(d[1]-25)>2||Math.abs(d[2]-27)>2||Math.abs(d[3]-230)>3) return 'uiPanel fill is '+d[0]+','+d[1]+','+d[2]+','+d[3]+', not panel at 90 percent';
     d=c.getImageData(20,0,1,1).data;
     if(d[3]<200||d[0]<60) return 'uiPanel has no 1px border';
     return null;
   }},
  {v:'29.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
