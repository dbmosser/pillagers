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

if ($s.Contains("  {v:'35.20',what:")) { throw "check 35.20 is in the fixture already" }

SubRx @'
  {v:'35.19',what:
'@ @'
  {v:'35.20',what:'cw-newinver, his order 2026-10-27 after he read v0.1137 off the card while playing v0.1149: the new in card on the floor and the what is new window both name the build he plays, so the menu shows one version number',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, want='NEW IN '+verShown(VER), hd=null, i,
         sub=document.getElementById('wnsub'), modal=document.getElementById('wnmodal'), cls=modal?modal.className:undefined, oldSub=sub?sub.textContent:undefined;
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(t){ rec.push(String(t)); return o.apply(this,arguments); };
       __wnseen(0); __hubFrame(0.016);
       proto.fillText=o;
       for(i=0;i<rec.length;i++) if(rec[i].indexOf('NEW IN v')===0){ hd=rec[i]; break; }
       if(!hd) bad.push('control: the new in card was not drawn on the floor');
       else if(hd!==want) bad.push('the floor card says '+hd+', not '+want+', the build he plays');
       if(typeof wnOpen!=='function'||!sub) bad.push('no what is new window to read');
       else { wnOpen(); if(sub.textContent!==want) bad.push('the what is new window says '+sub.textContent+', not '+want); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; try{ if(typeof wnClose==='function') wnClose(); }catch(_w){} if(modal&&cls!==undefined) modal.className=cls; if(sub&&oldSub!==undefined) sub.textContent=oldSub; P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
