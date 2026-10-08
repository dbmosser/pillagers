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

if ($s.Contains("  {v:'19.14',what:")) { throw "check 19.14 is in the fixture already" }

SubRx @'
  {v:'19.13',what:
'@ @'
  {v:'19.14',what:'a first Blotter dose draws the melt once: with no trip showing, taking a dose arms no crossfade, and with a trip showing it does',
   run:function(){
     if(typeof renderBar!=='function'||typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no bar here';
     var bad=[], c0=P.credits, b0=P.buzz, k0=(typeof BUZZLASTK!=='undefined')?BUZZLASTK:0, p0=BUZZRNDP, r0=BUZZRND, to0=BUZZRNDTO, at0=BUZZRNDAT, t, btn;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('bar','KeyE');
       btn=document.querySelector('.modal.on [data-bz="lsd"]');
       if(!btn||typeof btn.onclick!=='function') return 'SKIP: no Blotter button';
       P.credits=99999; P.buzz=[]; BUZZLASTK=0; BUZZRNDP=null;
       btn.onclick.call(btn);
       if(BUZZRNDP) bad.push('a first dose with nothing showing armed the melt crossfade, drawing the melt twice for 8 s');
       BUZZLASTK=1; BUZZRNDP=null; BUZZRNDTO=null;
       btn.onclick.call(btn);
       if(!BUZZRNDP) bad.push('control: a dose during a visible trip did not arm the crossfade');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.credits=c0; P.buzz=b0; BUZZLASTK=k0; BUZZRNDP=p0; BUZZRND=r0; BUZZRNDTO=to0; BUZZRNDAT=at0; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
