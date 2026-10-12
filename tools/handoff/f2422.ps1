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

if ($s.Contains("  {v:'24.22',what:")) { throw "check 24.22 is in the fixture already" }

SubRx @'
  {v:'24.21',what:
'@ @'
  {v:'24.22',what:'his #50 (UI redesign ui6b, from the visual QA): the station windows have no faint or undersized words: THE GAMBLE is not in the hairline colour, the contract tier tag is 13px, a locked Fashion tile keeps its name and requirement at full strength, the rack heads are 13px, and the stash hint line is not dimmed',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], r, el, s, op, q, n=0;
     function opac(e){ var o=1; for(var p=e;p&&p.nodeType===1;p=p.parentElement){ o*=parseFloat(getComputedStyle(p).opacity); } return o; }
     try{
       __topClear(); __hubEnter(); r=__station('gamble','KeyE');
       el=document.querySelector('#wirtsec_gamble > div');
       if(el){ n++; s=getComputedStyle(el).color; if(s==='rgb(74, 82, 87)') bad.push('THE GAMBLE is in the hairline colour'); }
       __topClear(); __hubEnter(); r=__station('mf','KeyE');
       el=document.querySelector('#contracts .cd > span');
       if(el){ n++; if(parseFloat(getComputedStyle(el).fontSize)<13) bad.push('the contract tier tag is '+getComputedStyle(el).fontSize); }
       __topClear(); __hubEnter(); r=__station('mirror','KeyE');
       el=document.querySelector('#appavatarpicker .costile.lock .cosname');
       if(el){ n++; op=opac(el); if(op<0.99) bad.push('a locked Fashion tile dims its name to '+op.toFixed(2)); }
       q=document.querySelector('#appavatarpicker .costile.lock .cosreq');
       if(q&&opac(q)<0.99) bad.push('a locked Fashion tile dims what unlocks it to '+opac(q).toFixed(2));
       el=document.querySelector('#appavatarpicker > div');
       if(el){ n++; if(parseFloat(getComputedStyle(el).fontSize)<13||opac(el)<0.99) bad.push('the rack head is '+getComputedStyle(el).fontSize+' at opacity '+opac(el).toFixed(2)); }
       __topClear(); __hubEnter(); r=__station('term','KeyE');
       el=document.querySelector('#stashdetail span');
       if(el){ n++; op=opac(el); if(op<0.99) bad.push('the stash hint line is dimmed to '+op.toFixed(2)); }
       if(n<4) bad.push('only '+n+' of the five words were found');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
