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

if ($s.Contains("  {v:'23.27',what:")) { throw "check 23.27 is in the fixture already" }

SubRx @'
  {v:'23.26',what:
'@ @'
  {v:'23.27',what:'from the arcade core review: a dial changed during an arcade session (a Settings row, a preset that puts a new set of dials in place, a tuning slider, a dial added) is put back when the arcade is left, so the dials and his save hold every dial as it was before the arcade',
   run:function(){
     var bad=[], c0=null, o0=null, k, a, b, js, sp, ed0, ex=[];
     try{
       __topClear(); __runPrep();
       if(typeof arcadeSandboxIn!=='function'||typeof arcadeSandboxOut!=='function'||typeof ARCADE!=='object') return 'no arcade in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       o0=CFG; c0={}; for(k in CFG) if(Object.prototype.hasOwnProperty.call(CFG,k)) c0[k]=CFG[k];
       ed0=CFG.eDmg;
       if(!arcadeSandboxIn('host')) return 'arcadeSandboxIn failed';
       arcadeCfgIn();
       CFG.eDmg=0.137; CFG.zzArcLeak=7;
       applyCfg(DEF,null); CFG.eDmg=0.271; CFG.zzArcLeak2=9;
       arcadeSandboxOut();
       if(ARCADE.on) bad.push('the sandbox is still on');
       if(CFG.eDmg!==ed0) bad.push('the enemy damage dial changed in the arcade is '+CFG.eDmg+' after leaving (it was '+ed0+')');
       if(Object.prototype.hasOwnProperty.call(CFG,'zzArcLeak')||Object.prototype.hasOwnProperty.call(CFG,'zzArcLeak2')) bad.push('a dial added in the arcade is still there after leaving');
       for(k in c0) if(Object.prototype.hasOwnProperty.call(c0,k)){ a=c0[k]; b=CFG[k]; if(a!==b&&JSON.stringify(a)!==JSON.stringify(b)) ex.push(k); }
       for(k in CFG) if(Object.prototype.hasOwnProperty.call(CFG,k)&&!Object.prototype.hasOwnProperty.call(c0,k)) ex.push('+'+k);
       if(ex.length) bad.push(ex.length+' dials not as they were before the arcade: '+ex.slice(0,6).join(', '));
       js=null;
       if(!(window.storage&&window.storage.set)&&!SAVE_STALE){ try{ js=localStorage.getItem(SKEY); }catch(_g){ js=null; } }
       if(js){ sp=null; try{ sp=JSON.parse(js); }catch(_p){ sp=null; } if(sp&&sp.cfg&&sp.cfg.eDmg!==ed0) bad.push('his save holds the enemy damage dial set in the arcade ('+sp.cfg.eDmg+')'); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(c0){ CFG=o0; for(k in CFG) if(Object.prototype.hasOwnProperty.call(CFG,k)&&!Object.prototype.hasOwnProperty.call(c0,k)) delete CFG[k]; for(k in c0) if(Object.prototype.hasOwnProperty.call(c0,k)) CFG[k]=c0[k]; saveProfile(); } }catch(_r){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
