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

if ($s.Contains("  {v:'27.29',what:")) { throw "check 27.29 is in the fixture already" }

SubRx @'
  {v:'27.28',what:
'@ @'
  {v:'27.29',what:'his note: the press E prompts over a crate, a door or a body are 60 percent of their old size, in the keycap, the words and the plate, and keep their place',
   run:function(){
     if(!window.__textTrace||typeof hudPrompt!=='function') return 'SKIP: no prompts here';
     var bad=[], tr, ref, pr, r, ratio, w1, by1, w0;
     try{
       ctx.save();
       try{
         tr=__textTrace(function(){
           ctx.font=FS(TYPE.head); ctx.textAlign='left'; ctx.fillStyle='#fff'; ctx.fillText('REFHEAD',10,10);
           r=hudPrompt('SEARCH CRATE PROMPT',W/2,H/2,{});
         });
       } finally { ctx.restore(); }
       ref=tr.filter(function(e){ return e.t==='REFHEAD'; })[0];
       pr=tr.filter(function(e){ return e.t==='SEARCH CRATE PROMPT'; })[0];
       if(!ref||!pr) return 'SKIP: the prompt text was not traced';
       ratio=pr.px/ref.px;
       if(ratio>0.66||ratio<0.54) bad.push('the prompt type is '+ratio.toFixed(2)+' of the head size, not 0.6');
       if(!r||!(r.w>0)||!(r.by>H/2)) bad.push('the prompt returned no size ('+JSON.stringify(r)+')');
       if(r&&r.by>H/2+LH(40)) bad.push('the prompt plate reaches '+Math.round(r.by-H/2)+' below its anchor, far more than a shrunk prompt');
       w0=ctx.getTransform().a; if(Math.abs(pr.x/w0-W/2)>2) bad.push('the prompt moved off its anchor (x '+Math.round(pr.x/w0)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
