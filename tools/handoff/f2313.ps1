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

if ($s.Contains("  {v:'23.13',what:")) { throw "check 23.13 is in the fixture already" }

SubRx @'
  {v:'23.12',what:
'@ @'
  {v:'23.13',what:'the party summary on the run card writes money as $1,234, the one way the game writes Credits since R48, and never as 1,234c',
   run:function(){
     if(typeof netSumDraw!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no party summary in this build';
     var el=document.getElementById('oc_party'); if(!el) return 'SKIP: no party summary element here';
     var bad=[], k, keep={}, h0=el.innerHTML, d0=el.style.display, h, want='$'+(4321).toLocaleString(), old=(4321).toLocaleString()+'c';
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       NET.on=true; NET.seat=0; NET.sc=null; NET.scSd=undefined;
       NET.roster=[{seat:0,name:'Zqxone'},{seat:1,name:'Zqxtwo'}];
       NET.sum={0:{how:'extract',k:2,v:4321},1:{how:'dead',k:0,v:0}};
       netSumDraw();
       h=String(el.innerHTML||'');
       if(h.indexOf('Zqxtwo')<0) return 'SKIP: staging: the party summary did not draw the staged party';
       if(h.indexOf(want)<0) bad.push('the party summary does not write '+want+' ('+h.replace(/<[^>]+>/g,' ').replace(/\s+/g,' ').slice(0,200)+')');
       if(h.indexOf(old)>=0) bad.push('the party summary still writes '+old);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       el.innerHTML=h0; el.style.display=d0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
