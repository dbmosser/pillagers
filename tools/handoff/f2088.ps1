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

if ($s.Contains("  {v:'20.88',what:")) { throw "check 20.88 is in the fixture already" }

SubRx @'
  {v:'20.87',what:
'@ @'
  {v:'20.88',what:'the floor heading stays out of a station window: with the shop or Fashion open THE UNDERCROFT is not painted behind the window, where its top half showed above the frame, and with the window shut it is painted again',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof __hubStep!=='function') return 'SKIP: no Undercroft floor here';
     var bad=[], t, oFT=ctx.fillText, rec=[], hd='THE UNDER'+'CROFT', ids=['trader','mirror'], i, open;
     function drawn(){ var j; for(j=0;j<rec.length;j++) if(rec[j]===hd) return true; return false; }
     function shut(){ var a=document.querySelectorAll('.modal.on'), k; for(k=0;k<a.length;k++) a[k].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();
       ctx.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); };
       rec=[]; __hubStep(0.016);
       if(!drawn()) return 'SKIP: the floor drew no heading with no window open';
       for(i=0;i<ids.length;i++){
         __station(ids[i],'KeyE');
         open=document.querySelector('.modal.on');
         if(!open){ bad.push('the '+ids[i]+' station opened no window'); continue; }
         rec=[]; __hubStep(0.016);
         if(drawn()) bad.push('the floor heading is painted behind the '+open.id+' window');
         shut();
       }
       rec=[]; __hubStep(0.016);
       if(!drawn()) bad.push('the floor heading did not come back when the window shut');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; shut(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
