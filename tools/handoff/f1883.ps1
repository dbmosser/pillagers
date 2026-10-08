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

if ($s.Contains("  {v:'18.83',what:")) { throw "check 18.83 is in the fixture already" }

SubRx @'
  {v:'18.82',what:
'@ @'
  {v:'18.83',what:'a tattoo tile is a close-up: the tattoo preview figure is drawn larger than the whole-figure previews, so the ink can be seen',
   run:function(){
     if(typeof cosPreviewURL!=='function'||typeof COSMETICS==='undefined') return 'SKIP: no rack previews here';
     var t=COSMETICS.filter(function(c){ return c&&c.kind==='tattoo'; })[0], f=COSMETICS.filter(function(c){ return c&&c.kind==='fit'; })[0];
     if(!t||!f) return 'SKIP: no tattoo or fit in the racks';
     var oD=drawOp, sc=[], st, sf;
     function scaleOf(kind,id){ var k; for(k in COSPREV) if(k.indexOf('box|')!==0) delete COSPREV[k]; sc=[]; drawOp=function(){ try{ sc.push(wc.getTransform().a); }catch(_t){} return oD.apply(this,arguments); }; try{ cosPreviewURL(kind,id); } finally { drawOp=oD; } return sc.length?sc[sc.length-1]:0; }
     try{ st=scaleOf('tattoo',t.id); sf=scaleOf('fit',f.id); } finally { drawOp=oD; }
     if(!(st>0&&sf>0)) return 'SKIP: no previews painted';
     if(!(st>sf*1.3)) return 'the tattoo tile is drawn at ' + st.toFixed(2) + ', no closer than a whole figure (' + sf.toFixed(2) + ')';
     return null; }},
  {v:'18.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
