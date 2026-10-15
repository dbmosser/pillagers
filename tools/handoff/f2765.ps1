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

if ($s.Contains("  {v:'27.65',what:")) { throw "check 27.65 is in the fixture already" }

SubRx @'
  {v:'27.64',what:
'@ @'
  {v:'27.65',what:'cloud-menus-keys-x-no-board: the Keys window rows and the controls card never use the retired word board; the X row says call for extraction, then extract',
   run:function(){
     if(typeof keysOpen!=='function'||typeof KEYS==='undefined'||typeof KEYS_ACTS==='undefined'||!KEYS_ACTS.length||typeof LEGEND==='undefined') return 'SKIP: this fixture has no Keys window or controls card';
     var bad=[], Pf=__P(), km0=JSON.stringify(Pf.keymap===undefined?null:Pf.keymap), m, t, i, j, x=null;
     try{
       __topClear(); __runPrep();
       Pf.keymap={}; KEYS.inv=null; keysInv();
       keysOpen(false);
       m=document.getElementById('keysmodal');
       if(!m||!m.classList.contains('on')) return 'SKIP: the Keys window did not open';
       t=m.querySelectorAll('.row b');
       if(!t.length) bad.push('the Keys window drew no action rows');
       for(i=0;i<t.length;i++) if((/(^|[^a-z])board([^a-z]|$)/i).test(String(t[i].textContent||''))) bad.push('the Keys window row reads '+JSON.stringify(String(t[i].textContent)));
       for(i=0;i<KEYS_ACTS.length;i++){ if((/(^|[^a-z])board([^a-z]|$)/i).test(String(KEYS_ACTS[i][1]))) bad.push('the Keys row for '+KEYS_ACTS[i][0]+' reads '+JSON.stringify(KEYS_ACTS[i][1])); if(KEYS_ACTS[i][0]==='KeyX') x=String(KEYS_ACTS[i][1]); }
       if(x===null) bad.push('X is not on the Keys list'); else if(!(/call for extraction, then extract/).test(x)) bad.push('the Keys row for X reads '+JSON.stringify(x));
       for(i=0;i<LEGEND.length;i++) for(j=0;j<LEGEND[i][1].length;j++) if((/(^|[^a-z])board([^a-z]|$)/i).test(String(LEGEND[i][1][j][1]))) bad.push('the controls card row '+LEGEND[i][1][j][0]+' reads '+JSON.stringify(LEGEND[i][1][j][1]));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ KEYS.waiting=null; KEYS.note=null; KEYS.pad=false; }catch(_k){}
       try{ if(m) m.classList.remove('on'); }catch(_m){}
       try{ var _k0=JSON.parse(km0); if(_k0===null) delete Pf.keymap; else Pf.keymap=_k0; KEYS.inv=null; keysInv(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
