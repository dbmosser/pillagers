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

if ($s.Contains("  {v:'22.12',what:")) { throw "check 22.12 is in the fixture already" }

SubRx @'
  {v:'22.11',what:
'@ @'
  {v:'22.12',what:'a district contract rolled on one sector and played on another names the place on the sector played, in the Mainframe detail card, the raid CONTRACT DONE line and the run card',
   run:function(){
     if(typeof contractDesc!=='function'||typeof contractStep!=='function'||typeof renderConDetail!=='function'||typeof districtPlaceName!=='function'||typeof FIXED_MAPS==='undefined') return 'SKIP: no contract board here';
     var bad=[], oMap=P.mapIx, oCon=P.contracts, oSel=P._conSel, oG=G, oSay=say, said=[], mA=-1, mB=-1, dd=-1, nA, nB, i, j, d, c, el=null, h4, made=null, oHtml=null, want, mid;
     try{
       for(i=0;i<FIXED_MAPS.length&&mA<0;i++) for(j=0;j<FIXED_MAPS.length&&mA<0;j++){ if(i===j) continue;
         for(d=0;d<4;d++){ P.mapIx=i; nA=districtPlaceName(d); P.mapIx=j; nB=districtPlaceName(d); if(nA&&nB&&nA!==nB){ mA=i; mB=j; dd=d; break; } } }
       if(mA<0) return 'SKIP: no two sectors name a district differently';
       P.mapIx=mA; nA=districtPlaceName(dd);
       c={type:'district',d:dd,n:13,prog:12,reward:1313,tier:'std',gear:null,desc:'Search 13 containers in '+nA};
       P.mapIx=mB; nB=districtPlaceName(dd); want='Search 13 containers in '+nB;
       if(contractDesc(c)!==want) return 'SKIP: staging: the live sentence reads '+contractDesc(c);
       el=document.getElementById('condetail');
       if(!el){ made=el=document.createElement('div'); el.id='condetail'; document.body.appendChild(el); } else oHtml=el.innerHTML;
       P.contracts=[c]; P._conSel=0;
       renderConDetail();
       h4=el.querySelector('h4');
       if(!h4) bad.push('the detail card drew no heading');
       else if(h4.textContent!==want) bad.push('the detail card reads "'+h4.textContent+'" on the sector where the place is '+nB);
       say=function(m){ said.push(String(m)); };
       G={tel:{},sim:false};
       contractStep(c);
       mid=(G.tel&&G.tel.contractsMid)||[];
       if(!(mid.length===1&&mid[0].desc===want)) bad.push('the run card will read '+JSON.stringify(mid.length?mid[0].desc:null)+' for '+want);
       if(!said.some(function(m){ return m.indexOf(want+'.')>=0; })) bad.push('the raid line read '+JSON.stringify(said[0]||null));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       G=oG; say=oSay; P.mapIx=oMap; P.contracts=oCon;
       if(oSel===undefined) delete P._conSel; else P._conSel=oSel;
       if(made){ if(made.parentNode) made.parentNode.removeChild(made); }
       else if(el&&oHtml!==null) el.innerHTML=oHtml;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
