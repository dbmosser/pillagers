$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.03',what:
'@ @'
  {v:'14.04',what:'a restore code replaces the hire, contracts, cutting, map and Terms too: restoring a code over a character with a paid hire, a contract at five of six, thirty seconds of cutting on a seal and signed Terms leaves none of them, while the code own name is applied (saving, profile and settings audit 2026-09-15, finding 3)',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot load a profile';
     if(typeof restoreMake!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function') return 'SKIP: no restore codes in this build';
     var bad=[], keep=JSON.parse(JSON.stringify(__P()));
     try{
       __topClear(); __cleanProfile();
       var P2=__P();
       P2.pname='PROBESOURCE'; P2.credits=4242;
       var code=restoreMake();
       if(typeof code!=='string'||!code) return 'SKIP: restoreMake made no code';
       var o=restoreRead(code);
       if(!o) return 'SKIP: the code made here does not read back';
       // The character the code is pasted over.
       P2.pname='OLDCHAR';
       P2.merc=(typeof IDENTITIES!=='undefined'&&IDENTITIES.length)?IDENTITIES[0].id:'probe';
       P2.contracts=[{type:'kill',kind:'crawler',n:6,prog:5,reward:1,tier:'std',desc:'probe kill card'}];
       P2.seals={'0':{cut:30,tier:0,done:0}};
       P2.terms=['blackout'];
       restoreApply(o);
       var P3=__P();
       // CONTROL: the code was applied.
       if(P3.pname!=='PROBESOURCE') return 'SKIP: the code was not applied (name '+P3.pname+'), so nothing here can be measured';
       if(P3.merc) bad.push('the restored character kept the old one hire ('+P3.merc+')');
       if((P3.contracts||[]).some(function(c){ return c&&c.prog===5; })) bad.push('the restored character kept the old contract at five of six');
       if(P3.seals&&P3.seals['0']&&P3.seals['0'].cut>0) bad.push('the restored character kept thirty seconds of cutting on a seal');
       if((P3.terms||[]).length) bad.push('the restored character kept the old signed Terms');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __applyLoaded(keep); saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
