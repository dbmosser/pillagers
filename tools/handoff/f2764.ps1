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

if ($s.Contains("  {v:'27.64',what:")) { throw "check 27.64 is in the fixture already" }

SubRx @'
  {v:'27.63',what:
'@ @'
  {v:'27.64',what:'cloud-menus-keys-hold-toggle-labels: the Keys window rows for SHIFT, CTRL and C name sprint and crouch without claiming hold or toggle, since the CROUCH and SPRINT settings decide that (by default Ctrl toggles)',
   run:function(){
     if(typeof keysOpen!=='function'||typeof KEYS==='undefined'||typeof KEYS_ACTS==='undefined'||!KEYS_ACTS.length) return 'SKIP: this fixture has no Keys window';
     var bad=[], P2=__P(), km0=JSON.stringify(P2.keymap===undefined?null:P2.keymap), m, rows, i, k, lab={}, want={ShiftLeft:'sprint',ControlLeft:'crouch',KeyC:'crouch'};
     try{
       __topClear(); __runPrep();
       P2.keymap={}; KEYS.inv=null; keysInv();
       for(i=0;i<KEYS_ACTS.length;i++) lab[KEYS_ACTS[i][0]]=String(KEYS_ACTS[i][1]);
       for(k in want){ if(lab[k]===undefined){ bad.push(k+' is not on the Keys list'); continue; }
         if((/hold|toggle/i).test(lab[k])) bad.push('the Keys row for '+k+' reads '+JSON.stringify(lab[k])+', a mode the CROUCH and SPRINT settings decide');
         if(lab[k].toLowerCase().indexOf(want[k])<0) bad.push('the Keys row for '+k+' reads '+JSON.stringify(lab[k])+' and does not name '+want[k]); }
       keysOpen(false);
       m=document.getElementById('keysmodal');
       if(!m||!m.classList.contains('on')) return 'SKIP: the Keys window did not open';
       rows=m.querySelectorAll('.row b');
       if(!rows.length) bad.push('the Keys window drew no action rows');
       for(i=0;i<rows.length;i++){ var tx=String(rows[i].textContent||''); if((/^(sprint|crouch)/i).test(tx)&&(/hold|toggle/i).test(tx)) bad.push('the Keys window row reads '+JSON.stringify(tx)); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ KEYS.waiting=null; KEYS.note=null; KEYS.pad=false; }catch(_k){}
       try{ if(m) m.classList.remove('on'); }catch(_m){}
       try{ var _k0=JSON.parse(km0); if(_k0===null) delete P2.keymap; else P2.keymap=_k0; KEYS.inv=null; keysInv(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
