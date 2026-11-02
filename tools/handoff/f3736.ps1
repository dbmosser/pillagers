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

if ($s.Contains("  {v:'37.36',what:")) { throw "check 37.36 is in the fixture already" }

SubRx @'
  {v:'37.35',what:
'@ @'
  {v:'37.36',what:'cw-m2hallb, critic on the hall (3 of 5): the sign of the hall wall sits right under its ring, gen has a 32px gutter before how it ended, and the empty line is a quiet left aligned row at 20px',
   run:function(){
     if(!(window.__runPrep&&window.__cleanProfile&&window.__topClear&&window.__hubEnter)) return 'SKIP: no hub fixture';
     if(typeof renderHall!=='function'||typeof hubStationNames!=='function'||typeof openOps!=='function') return 'SKIP: no hall here';
     var bad=[], saved=P, st, y=null, o, S, a, b, e, cs, rg;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     try{
       P=JSON.parse(JSON.stringify(saved));
       __runPrep(); __topClear(); __cleanProfile(); __hubEnter(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
       st=hubStationById('hall');
       need(!!st,'no hall station');
       S=hubScale(); o=wc.fillText;
       wc.fillText=function(s,x,yy){ if(String(s)===st.label) y=yy; return o.apply(this,arguments); };
       wc.save(); wc.setTransform(1,0,0,1,0,0);
       try{ hubStationNames(S,0,0); }finally{ wc.restore(); delete wc.fillText; if(wc.fillText!==o) wc.fillText=o; }
       rg=st.y+6+st.r*0.42;
       need(y!==null&&y>rg&&y-rg<=16,'the sign is at y '+y+', the ring ends at '+rg);
       P.hall=[]; P.pil=null; P.pilGen=0; pilNow(); P.runs=0; P.ext=0; P.best=0; P.achN={};
       openOps('hall');
       e=document.getElementById('hallempty'); cs=e?getComputedStyle(e):null;
       need(!!e&&cs.textAlign==='left'&&Math.abs(parseFloat(cs.fontSize)-20)<0.5,'the empty line: '+(cs?cs.textAlign+' '+cs.fontSize:'missing'));
       a=document.querySelector('#halllist .hallhead > :nth-child(2)'); b=document.querySelector('#halllist .hallhead > :nth-child(3)');
       cs=a?getComputedStyle(a):null;
       need(!!a&&!!b&&parseFloat(cs.marginRight)===16&&parseFloat(getComputedStyle(a.parentNode).columnGap)===16,'gen gutter: margin '+(cs&&cs.marginRight));
       P.hall=[{name:'brakka',gen:1,raids:3,kills:1,best:50,lvl:1,end:{how:'dead'}}]; P.pil=pilMake('live',2); renderHall();
       [].forEach.call(document.querySelectorAll('#opane_hall .hv,#opane_hall .hname'),function(el){ var l=parseFloat(getComputedStyle(el).lineHeight)/parseFloat(getComputedStyle(el).fontSize); need(l>=1.3,'a name line of '+l+' cuts its tails: '+el.textContent); });
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       P=saved;
       try{ document.getElementById('opmodal').classList.remove('on'); HALLW.k=''; __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
