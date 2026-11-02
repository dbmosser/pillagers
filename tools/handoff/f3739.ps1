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

if ($s.Contains("  {v:'37.39',what:")) { throw "check 37.39 is in the fixture already" }

SubRx @'
  {v:'37.38',what:
'@ @'
  {v:'37.39',what:'cw-m2retire2: on a pad the retire confirm card starts on not yet, and the retire button has the danger border and text while it can be pressed, not while it waits on a first raid',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof pilRetireAsk!=='function') return 'no retire in this build';
     var saved=P, snap0=JSON.stringify(P), oldStore=storeSet, oldSave=saveProfile, oldPad=padOn, bad=[], b, red, dg;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       showScreen('hub');
       P.hall=[]; P.pilGen=1; P.pil=pilMake('brakka',1); P.pil.raids=1; delete P.heirs; BIRTH=null;
       openOps('hall'); b=E('hallretire');
       red=document.createElement('i'); red.style.color='var(--danger)'; document.body.appendChild(red); dg=getComputedStyle(red).color; red.remove();
       need(getComputedStyle(b).color===dg&&getComputedStyle(b).borderTopColor===dg,'the button is '+getComputedStyle(b).color+' with border '+getComputedStyle(b).borderTopColor+', not '+dg);
       padOn=function(){ return true; };
       b.click();
       need(E('askmodal').classList.contains('on')&&PAD.focus===E('askno'),'the pad focus starts on '+(PAD.focus&&PAD.focus.id));
       E('askno').click();
       need(!!P.pil,'not yet retired');
       padOn=oldPad; padSetFocus(null); PAD.focus=null;
       P.pil.raids=0; hallMeDraw();
       need(b.disabled&&getComputedStyle(b).color!==dg,'the waiting button is still red');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       padOn=oldPad; try{ padSetFocus(null); PAD.focus=null; }catch(_p){}
       try{ E('askmodal').classList.remove('on'); E('opmodal').classList.remove('on'); }catch(_m){}
       BIRTH=null; P=saved;
       (function(){ var n, s=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s) P[n]=s[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
