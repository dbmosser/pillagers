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

if ($s.Contains("  {v:'16.52',what:")) { throw "check 16.52 is in the fixture already" }

SubRx @'
  {v:'16.51',what:
'@ @'
  {v:'16.52',what:'a controller never lands on the CONTROLLER row of the PARTY window, and in a same machine pair never on END THE PARTY, where one press took the pad away or split the pair',
   run:function(){
     if(typeof padFocusables!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this build has no pad focus list';
     var d=document.createElement('div'), keep=NET.same, bad=[], ids;
     d.style.cssText='position:fixed;left:10px;top:10px;z-index:9999';
     d.innerHTML='<button id=partypadbtn>A</button><button id=partyquit>B</button><button id=chkplain>C</button>';
     function list(){ return padFocusables(d).map(function(e){ return e.id; }); }
     try{
       document.body.appendChild(d);
       NET.same='p2'; ids=list();
       if(ids.indexOf('chkplain')<0) return 'SKIP: staging: a plain button in the test panel is not in the pad list ('+ids.join(',')+')';
       if(ids.indexOf('partypadbtn')>=0) bad.push('a controller can land on the CONTROLLER row');
       if(ids.indexOf('partyquit')>=0) bad.push('in a same machine pair a controller can land on END THE PARTY');
       NET.same=null; ids=list();
       if(ids.indexOf('partyquit')<0) bad.push('control: away from a same machine pair END THE PARTY left the pad list');
     } finally { NET.same=keep; try{ document.body.removeChild(d); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
