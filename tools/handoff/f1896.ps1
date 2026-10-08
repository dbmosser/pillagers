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

if ($s.Contains("  {v:'18.96',what:")) { throw "check 18.96 is in the fixture already" }

SubRx @'
  {v:'18.95',what:
'@ @'
  {v:'18.96',what:'the warning under THE LAST POUR stays inside the room: as he wrote it, it ends before the right wall',
   run:function(){
     if(typeof __hubEnter!=='function'||typeof __loop!=='function'||typeof HUBW==='undefined') return 'SKIP: no Undercroft floor here';
     var bad=[], t, oT=wc.fillText, rec=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __loop(performance.now());
       wc.fillText=function(s,x,y){ if(String(s)==='***EXPERIMENTAL***'){ var shown=(typeof TX==='function')?TX(String(s)):String(s); rec={x:x,w:CanvasRenderingContext2D.prototype.measureText.call(wc,shown).width}; } return oT.apply(this,arguments); };
       try{ __loop(performance.now()+17); } finally { delete wc.fillText; if(wc.fillText!==oT) wc.fillText=oT; }
       if(!rec) return 'SKIP: the warning was not drawn';
       if(rec.x+rec.w/2>HUBW-20+1) bad.push('the warning ends at '+Math.round(rec.x+rec.w/2)+', past the wall at '+(HUBW-20));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete wc.fillText; if(wc.fillText!==oT) wc.fillText=oT; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
