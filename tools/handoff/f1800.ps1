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

if ($s.Contains("  {v:'18.00',what:")) { throw "check 18.00 is in the fixture already" }

SubRx @'
  {v:'17.99',what:
'@ @'
  {v:'18.00',what:'kid mode set in one window shows in the other: a kid row change is written to shared storage with a stamp, a storage event from the other window puts all three kid rows on this save, and an older stamp never undoes a newer one',
   run:function(){
     if(typeof kidSync!=='function'||typeof KID_SHARE_KEY==='undefined') return 'kid settings are not shared between the windows';
     var bad=[], k0=null, kb0=P.kidBack, af0=P.p2Auto, kd0=P.kidDmg, at0=P.kidAt, o=null, now=Date.now();
     try{ k0=localStorage.getItem(KID_SHARE_KEY); }catch(_r){}
     try{
       P.kidBack=0; P.p2Auto=0; P.kidDmg=1; P.kidAt=0;
       kbCycle();
       try{ o=JSON.parse(localStorage.getItem(KID_SHARE_KEY)); }catch(_j){ o=null; }
       if(!o||o.kb!==1||typeof o.at!=='number') bad.push('the change was not written to shared storage ('+JSON.stringify(o)+')');
       P.kidBack=0; P.p2Auto=0; P.kidDmg=1; P.kidAt=0;
       window.dispatchEvent(new StorageEvent('storage',{key:KID_SHARE_KEY,newValue:JSON.stringify({kd:0.5,af:1,kb:1,at:now+5})}));
       if(P.kidBack!==1||P.p2Auto!==1||Math.abs(P.kidDmg-0.5)>1e-6) bad.push('the other window did not take the change (kb '+P.kidBack+', af '+P.p2Auto+', kd '+P.kidDmg+')');
       window.dispatchEvent(new StorageEvent('storage',{key:KID_SHARE_KEY,newValue:JSON.stringify({kd:1,af:0,kb:0,at:1})}));
       if(P.kidBack!==1||P.p2Auto!==1) bad.push('an old stamp undid a newer setting');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.kidBack=kb0; P.p2Auto=af0; P.kidDmg=kd0; P.kidAt=at0;
       try{ if(k0===null) localStorage.removeItem(KID_SHARE_KEY); else localStorage.setItem(KID_SHARE_KEY,k0); }catch(_c){}
       try{ saveProfile(); }catch(_sv){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
