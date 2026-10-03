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

if ($s.Contains("  {v:'17.84',what:")) { throw "check 17.84 is in the fixture already" }

SubRx @'
  {v:'17.83',what:
'@ @'
  {v:'17.84',what:'under the title only the world shows: no THE UNDERCROFT header, no NEW IN card, no station names; with the title gone they draw as before',
   run:function(){
     if(typeof titleOn!=='function'||typeof drawHubHUD!=='function') return 'SKIP: this build has no title backdrop';
     if(typeof loop!=='function'||!window.__hubEnter) return 'SKIP: no loop or floor in this fixture';
     var bad=[], t=document.getElementById('title'), was=t&&t.classList.contains('on'), st0=state, oF1=ctx.fillText, oF2=wc.fillText, seen=[], has=function(s){ return seen.some(function(q){ return q.indexOf(s)>=0; }); };
     try{
       if(!t) return 'SKIP: no title in this fixture';
       __runPrep(); __hubEnter();
       ctx.fillText=function(s){ seen.push(String(s)); return oF1.apply(this,arguments); }; wc.fillText=function(s){ seen.push(String(s)); return oF2.apply(this,arguments); };
       t.classList.add('on'); state='hub';
       HID.fromWorker=1; try{ loop(performance.now()); loop(performance.now()+16); }finally{ HID.fromWorker=0; }
       if(has('THE UNDERCROFT')) bad.push('the floor header shows through the title');
       if(has('NEW IN v')) bad.push('the NEW IN card shows through the title');
       if(has('ENTER RAID')||has('THE MAINFRAME')) bad.push('the station names show through the title');
       t.classList.remove('on'); seen.length=0;
       HID.fromWorker=1; try{ loop(performance.now()+32); loop(performance.now()+48); }finally{ HID.fromWorker=0; }
       if(!has('THE UNDERCROFT')) bad.push('with the title gone the floor header does not draw');
       if(!has('ENTER RAID')) bad.push('with the title gone the station names do not draw');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx.fillText=oF1; wc.fillText=oF2; if(was&&t) t.classList.add('on'); else if(t) t.classList.remove('on'); state=st0; try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
