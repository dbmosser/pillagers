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

if ($s.Contains("  {v:'35.10',what:")) { throw "check 35.10 is in the fixture already" }

SubRx @'
  {v:'35.09',what:
'@ @'
  {v:'35.10',what:'hotbar items fixes: key 0 reads 0, a belt key drags off on the lift, the pad reaches the lift belt, lift words show by the belt',
   run:function(){
     var bad=[], sp, spz, src='', sc, i, ht, pm, cl;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.kitPick='mine'; P.stash.push('medkit','medkit','frag','frag'); saveProfile(); renderSector(); openModal('sectormodal');
       sp=document.getElementById('sectorplan');
       if(!sp) bad.push('no lift belt'); else if(sp.getAttribute('data-pan')!=='b') bad.push('lift belt is not a pad panel');
       planPut(3,'frag'); syncSectorKit();
       spz=document.getElementById('sectorpack');
       if(!spz||typeof spz.__grabDrop!=='function') bad.push('pack list takes no drop');
       else { spz.__grabDrop('frag','plan:3'); if((P.hotAssign||{})[3]!==undefined) bad.push('dragging key 4 off kept it'); }
       sc=document.scripts; for(i=0;i<sc.length;i++) src+=sc[i].textContent;
       if(src.indexOf("' to slot '+(at"+"+1)")>=0) bad.push('slot callout still counts key 0 as 9');
       if(src.indexOf("+(d.fromHot"+"+1)")>=0) bad.push('drag callout still counts key 0 as 9');
       ht=document.getElementById('hubtoast'); if(ht) ht.classList.remove('on');
       say2('x');
       pm=document.getElementById('srplanmsg');
       if(!pm) bad.push('no words line by the belt'); else if(pm.textContent!=='x') bad.push('belt words read '+pm.textContent);
       if(ht&&ht.classList.contains('on')) bad.push('words went to the hidden toast');
       hubToast('y');
       if(ht&&ht.classList.contains('on')){ cl=document.getElementById('closesector'); if(cl) cl.click(); if(ht.classList.contains('on')) bad.push('toast still up after the lift closed'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
