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

if ($s.Contains("  {v:'25.04',what:")) { throw "check 25.04 is in the fixture already" }

SubRx @'
  {v:'25.03',what:
'@ @'
  {v:'25.04',what:'his answer 14: one set of rarity colours, green blue purple gold, the same in the world table, the HUD palette and the stylesheet',
   run:function(){
     var bad=[], R=['common','uncommon','rare','elite','gold'], i, r, cs, css, sp, want, n, hx;
     function rgb(h){ n=parseInt(String(h).replace('#',''),16); return 'rgb('+((n>>16)&255)+', '+((n>>8)&255)+', '+(n&255)+')'; }
     function hue(h){ n=parseInt(String(h).replace('#',''),16); var R0=((n>>16)&255)/255, G0=((n>>8)&255)/255, B0=(n&255)/255, mx=Math.max(R0,G0,B0), mn=Math.min(R0,G0,B0), d=mx-mn, hh;
       if(d<0.05) return -1; if(mx===R0) hh=((G0-B0)/d)%6; else if(mx===G0) hh=(B0-R0)/d+2; else hh=(R0-G0)/d+4; hh*=60; return hh<0?hh+360:hh; }
     try{
       css=getComputedStyle(document.documentElement);
       for(i=0;i<R.length;i++){
         r=R[i];
         if(String(RCOL[r]).toLowerCase()!==String(UIC['r_'+r]).toLowerCase()) bad.push(r+': the world draws '+RCOL[r]+', the HUD palette '+UIC['r_'+r]);
         cs=css.getPropertyValue('--r-'+r).trim().toLowerCase();
         if(cs!==String(RCOL[r]).toLowerCase()) bad.push(r+': the stylesheet says '+cs+', the world '+RCOL[r]);
         sp=document.createElement('span'); sp.className='r-'+r; document.body.appendChild(sp);
         if(getComputedStyle(sp).color!==rgb(RCOL[r])) bad.push(r+': a .r-'+r+' name is '+getComputedStyle(sp).color);
         sp.remove();
       }
       want={uncommon:[95,150],rare:[195,225],elite:[255,300],gold:[38,52]};
       for(r in want){ hx=hue(RCOL[r]); if(!(hx>=want[r][0]&&hx<=want[r][1])) bad.push(r+' is not '+({uncommon:'green',rare:'blue',elite:'purple',gold:'gold'})[r]+' (hue '+Math.round(hx)+')'); }
       if(String(RCOL.gold).toLowerCase()!=='#ffc72e') bad.push('gold moved off #ffc72e');
       if(rfill('gold').indexOf('255,199,46')<0) bad.push('the gold tile tint is '+rfill('gold'));
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
