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

if ($s.Contains("  {v:'21.53',what:")) { throw "check 21.53 is in the fixture already" }

SubRx @'
  {v:'21.52',what:
'@ @'
  {v:'21.53',what:'the attract titles read over any footage: each sits on a dark band, and PRESS ANY KEY is clear of the recorded belt row',
   run:function(){
     if(typeof attEl!=='function') return 'SKIP: no attract mode here';
     var d=attEl(), p=d.querySelector('.attpress'), n=d.querySelector('.attname'), was=d.style.display, bad=[], sp, sn;
     try{
       d.style.display='block';
       sp=getComputedStyle(p); sn=getComputedStyle(n);
       if(!/gradient/.test(sp.backgroundImage)) bad.push('PRESS ANY KEY has no band behind it');
       if(!/gradient/.test(sn.backgroundImage)) bad.push('PILLAGERS has no band behind it');
       var r=p.getBoundingClientRect();
       if(r.bottom>innerHeight*0.88) bad.push('PRESS ANY KEY sits on the recorded belt row ('+Math.round(r.bottom)+' of '+innerHeight+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ d.style.display=was; }
     return bad.length?bad.join('; '):null; }},
  {v:'21.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
