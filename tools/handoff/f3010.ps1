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

if ($s.Contains("  {v:'30.10',what:")) { throw "check 30.10 is in the fixture already" }

SubRx @'
  {v:'30.09',what:
'@ @'
  {v:'30.10',what:'the controls card on the arcade drop is the how to play table on the HUD: light action names, a key cap for every key, the extract ring as a ring glyph and no amber names; the run over footer is 104px and its title the muted colour (critic: 47 48 = 2, 46 55 = 3; screens 46 47 48 52 55)',
   run:function(){
     if(typeof arcadeCardHud!=='function'||typeof arcadeCardOn!=='function'||typeof ctx==='undefined'||!ctx) return 'SKIP: no arcade controls card here';
     var proto=CanvasRenderingContext2D.prototype, oa=proto.arc, ot=proto.arcTo, oft=proto.fillText, oOn=arcadeCardOn, na=0, nt=0, nameCol=null, amber=0, bad=null, d, oc, s, z, wasDisp, cs;
     try{
       __topClear(); __runPrep();
       arcadeCardOn=function(){ return 1; };
       proto.arc=function(){ na++; return oa.apply(this,arguments); };
       proto.arcTo=function(){ nt++; return ot.apply(this,arguments); };
       proto.fillText=function(t){ var f=String(this.fillStyle).toLowerCase(); if(/^move$/i.test(String(t))) nameCol=f; if(f==='#ffc04a'||f==='#f5b73b') amber++; return oft.apply(this,arguments); };
       arcadeCardHud();
       if(nt<40) bad='the controls card draws '+nt+' key cap corners, not a cap for every key';
       else if(na<2) bad='the extract ring is not drawn as a ring glyph';
       else if(nameCol!==String(UIC.tx_1).toLowerCase()) bad='the action names are '+nameCol+', not the light text colour';
       else if(amber>0) bad=amber+' words are still amber on the controls card';
     } finally { proto.arc=oa; proto.arcTo=ot; proto.fillText=oft; arcadeCardOn=oOn; }
     if(bad) return bad;
     if(typeof arcadeAttEl==='function'&&typeof attEl==='function'){
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{
         try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
         z=parseFloat(d.style.getPropertyValue('--attz'))||1;
         oc=arcadeAttEl('arcover'); oc.textContent=''; oc.style.display='block';
         s=document.createElement('div'); s.className='aoh'; s.textContent='Run over'; oc.appendChild(s);
         s=document.createElement('div'); s.className='aos'; s.textContent='Score 1 SP'; oc.appendChild(s);
         cs=getComputedStyle(oc);
         if(Math.abs(parseFloat(cs.paddingBottom)-104*z)>2) bad='the run over footer is '+cs.paddingBottom+', not 104px x '+z;
       } finally { try{ oc.textContent=''; oc.style.display='none'; d.style.display=wasDisp; }catch(_f){} }
     }
     return bad;
   }},
  {v:'30.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
