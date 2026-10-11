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

if ($s.Contains("  {v:'23.20',what:")) { throw "check 23.20 is in the fixture already" }

SubRx @'
  {v:'23.19',what:
'@ @'
  {v:'23.20',what:'his order: an arcade session plays on a sandbox profile and never writes his save; leaving puts his profile back',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     var bad=[], s0, c0, st0, pRef;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeSandboxIn!=='function'||typeof arcadeSandboxOut!=='function'||typeof ARCADE!=='object') return 'no arcade sandbox in this build';
       try{ saveProfile(); }catch(_f){}
       s0=localStorage.getItem(SKEY); c0=P.credits; st0=JSON.stringify(P.stash); pRef=P;
       if(!arcadeSandboxIn('host')) bad.push('arcadeSandboxIn did not install the sandbox');
       if(!ARCADE.on) bad.push('ARCADE.on is not set inside the sandbox');
       if(P!==pRef) bad.push('the sandbox replaced the P object instead of filling it in place');
       if(JSON.stringify(P.stash)!=='[]') bad.push('the sandbox kept his stash ('+JSON.stringify(P.stash).slice(0,60)+')');
       if(P.pname!=='PLAYER 1') bad.push('the sandbox name is '+P.pname);
       P.credits=987654; P.stash=['scrap']; saveProfile(); storeSet('{}');
       if(localStorage.getItem(SKEY)!==s0) bad.push('the save on disk changed while the arcade was on');
       arcadeSandboxOut();
       if(ARCADE.on) bad.push('ARCADE.on is still set after the sandbox out');
       if(P.credits!==c0) bad.push('credits after the sandbox out are '+P.credits+', not '+c0);
       if(JSON.stringify(P.stash)!==st0) bad.push('the stash did not come back after the sandbox out');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
