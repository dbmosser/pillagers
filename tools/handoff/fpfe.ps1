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

if ($s.Contains("  {v:'30.53',what:")) { throw "check 30.53 is in the fixture already" }

SubRx @'
  {v:'30.52',what:
'@ @'
  {v:'30.53',what:'the accent is lime yellow (his Q46): --acc and UIC.acc are the same lime, 7:1 or better against the panel, ink on it 7:1, 20 degrees or more of hue from rarity gold, warn and danger, and the pause Resume button wears it',
   run:function(){
     function rgb(h){ h=String(h).trim().replace('#',''); return [parseInt(h.substr(0,2),16),parseInt(h.substr(2,2),16),parseInt(h.substr(4,2),16)]; }
     function lum(c){ var a=c.map(function(v){ v/=255; return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4); }); return 0.2126*a[0]+0.7152*a[1]+0.0722*a[2]; }
     function cr(a,b){ var x=lum(a), y=lum(b); return (Math.max(x,y)+0.05)/(Math.min(x,y)+0.05); }
     function hue(c){ var r=c[0]/255,g=c[1]/255,b=c[2]/255, mx=Math.max(r,g,b), mn=Math.min(r,g,b), d=mx-mn, h; if(!d) return 0; h=(mx===r)?((g-b)/d)%6:(mx===g)?(b-r)/d+2:(r-g)/d+4; h*=60; return h<0?h+360:h; }
     function dh(a,b){ var d=Math.abs(hue(a)-hue(b)); return d>180?360-d:d; }
     var bad=[], cs=getComputedStyle(document.documentElement), acc=cs.getPropertyValue('--acc').trim(), ink=cs.getPropertyValue('--acc-ink').trim(), pan=cs.getPropertyValue('--ui-panel').trim(), a, n, b, hov, pr;
     if(!/^#[0-9a-f]{6}$/i.test(acc)) return 'the --acc token is not a hex colour: '+acc;
     a=rgb(acc); n=hue(a);
     if(n<58||n>78) bad.push('the accent hue is '+Math.round(n)+' degrees, not lime yellow (58 to 78)');
     if(typeof UIC!=='object'||String(UIC.acc).toLowerCase()!==acc.toLowerCase()) bad.push('UIC.acc ('+(typeof UIC==='object'?UIC.acc:'none')+') is not the --acc token '+acc);
     if(cr(a,rgb(pan))<7) bad.push('the accent on the panel is '+cr(a,rgb(pan)).toFixed(1)+':1, under 7');
     if(cr(a,rgb('#0b0c0d'))<7) bad.push('the accent on the void is under 7:1');
     if(cr(a,rgb(ink))<7) bad.push('the ink on the accent is '+cr(a,rgb(ink)).toFixed(1)+':1, under 7');
     if(dh(a,rgb(cs.getPropertyValue('--r-gold')))<20) bad.push('the accent is within 20 degrees of rarity gold');
     if(dh(a,rgb(cs.getPropertyValue('--danger')))<20) bad.push('the accent is within 20 degrees of danger');
     if(dh(a,rgb(cs.getPropertyValue('--warn')))<20) bad.push('the accent is within 20 degrees of warn');
     hov=cs.getPropertyValue('--acc-hover').trim(); pr=cs.getPropertyValue('--acc-press').trim();
     if(hue(rgb(hov))<58||hue(rgb(hov))>78) bad.push('the hover shade '+hov+' left the lime hue');
     if(hue(rgb(pr))<58||hue(rgb(pr))>78) bad.push('the press shade '+pr+' left the lime hue');
     var rs=document.getElementById('resumebtn'); if(rs){ var bg=getComputedStyle(rs).backgroundColor, m=bg.match(/\d+/g)||[]; if(!(Math.abs(+m[0]-a[0])<3&&Math.abs(+m[1]-a[1])<3&&Math.abs(+m[2]-a[2])<3)) bad.push('the Resume button is '+bg+', not the accent'); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
