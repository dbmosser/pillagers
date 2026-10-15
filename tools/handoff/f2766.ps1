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

if ($s.Contains("  {v:'27.66',what:")) { throw "check 27.66 is in the fixture already" }

SubRx @'
  {v:'27.65',what:
'@ @'
  {v:'27.66',what:'cloud-menus-kid-sync-launch: a window opened after the other window changed the kid rows picks up the shared values at launch, not only when its Settings opens',
   run:function(){
     if(typeof kidSync!=='function'||typeof KID_SHARE_KEY==='undefined') return 'SKIP: this fixture has no shared kid rows';
     var bad=[], Pf=__P(), k0=null, had={}, F=['kidDmg','p2Auto','kidBack','kidAt'], i;
     try{ k0=localStorage.getItem(KID_SHARE_KEY); }catch(_l){}
     for(i=0;i<F.length;i++) had[F[i]]=(F[i] in Pf)?Pf[F[i]]:undefined;
     try{
       var pl='PLOADED'+'=true;', sc=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).filter(function(t){ return t.split(pl).length===2; });
       if(sc.length!==1) bad.push('the boot line that marks the save as read was not found once');
       else if(!(/PLOADED\s*=\s*true;[\s\S]*?\bkidSync\s*\(\s*\)[\s\S]*?ensureContracts\s*\(\s*\)/).test(sc[0])) bad.push('the boot path does not pull the shared kid rows after the save is read, so a window launched later plays stale values until its Settings opens');
       Pf.kidDmg=0.5; Pf.p2Auto=1; Pf.kidBack=1; Pf.kidAt=1000;
       localStorage.setItem(KID_SHARE_KEY, JSON.stringify({kd:1,af:0,kb:0,at:2000}));
       kidSync();
       if(Pf.kidDmg!==1||Pf.p2Auto!==0||Pf.kidBack!==0||Pf.kidAt!==2000) bad.push('a newer share did not replace the own kid rows: '+JSON.stringify({kd:Pf.kidDmg,af:Pf.p2Auto,kb:Pf.kidBack,at:Pf.kidAt}));
       Pf.kidDmg=0.5; Pf.p2Auto=1; Pf.kidBack=1; Pf.kidAt=3000;
       kidSync();
       if(Pf.kidDmg!==0.5||Pf.p2Auto!==1||Pf.kidBack!==1||Pf.kidAt!==3000) bad.push('an older share replaced the own kid rows: '+JSON.stringify({kd:Pf.kidDmg,af:Pf.p2Auto,kb:Pf.kidBack,at:Pf.kidAt}));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(k0===null) localStorage.removeItem(KID_SHARE_KEY); else localStorage.setItem(KID_SHARE_KEY,k0); }catch(_r){}
       for(i=0;i<F.length;i++){ if(had[F[i]]===undefined) delete Pf[F[i]]; else Pf[F[i]]=had[F[i]]; }
       try{ __cleanProfile(); }catch(_c){}
       try{ saveProfile(); }catch(_s){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
