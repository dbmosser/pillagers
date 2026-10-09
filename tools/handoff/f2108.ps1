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

if ($s.Contains("  {v:'21.08',what:")) { throw "check 21.08 is in the fixture already" }

SubRx @'
  {v:'21.07',what:
'@ @'
  {v:'21.08',what:'the pause box key line is one style: every entry starts with its key in bold, and the TAB key is named once',
   run:function(){
     if(typeof keysLegendHtml!=='function') return 'SKIP: no pause key line here';
     var bad=[], hasPad=(typeof PAD==='object'&&PAD), on0=hasPad?PAD.on:false, h='', parts, i, txt, tabs, nd='T'+'AB';
     try{
       if(hasPad) PAD.on=false;
       h=String(keysLegendHtml());
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(hasPad) PAD.on=on0; }
     if(!h) return bad.length?bad.join('; '):'SKIP: the key line is empty';
     parts=h.split(' &nbsp; ');
     for(i=0;i<parts.length;i++){ if(!(/^<b[ >]/).test(parts[i])) bad.push('the entry '+parts[i].replace(/<[^>]*>/g,'')+' has no bold key'); }
     txt=h.replace(/<[^>]*>/g,'').replace(/&nbsp;/g,' ');
     tabs=txt.split(nd).length-1;
     if(tabs!==1) bad.push(nd+' is named '+tabs+' times in the key line');
     return bad.length?bad.slice(0,5).join('; '):null; }},
  {v:'21.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
