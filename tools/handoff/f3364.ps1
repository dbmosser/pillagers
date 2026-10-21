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

if ($s.Contains("  {v:'33.64',what:")) { throw "check 33.64 is in the fixture already" }

SubRx @'
  {v:'33.63',what:
'@ @'
  {v:'33.64',what:'the player 2 address made inside itch frame drops netslot (a window with netslot is never player 2) and keeps the frame own query; the top level address is unchanged',
   run:function(){
     var oEmb=reportEmbedded, bad=[], u, top;
     try{
       reportEmbedded=function(){ return true; };
       u=netP2Url('coop','zqxpair','?netslot=A&v=123');
       if(u.indexOf('netslot')>=0) bad.push('embedded address carries netslot: '+u);
       if(u.indexOf('v=123')<0) bad.push('embedded address lost the frame v=123: '+u);
       if(u.indexOf('p2=1')<0||u.indexOf('emb=1')<0) bad.push('embedded address lacks p2=1 or emb=1: '+u);
       reportEmbedded=function(){ return false; };
       top=netP2Url('coop','zqxpair','?netslot=A&v=123');
       if(top.indexOf('?p2=1&mode=coop&pair=zqxpair')<0||top.indexOf('netslot')>=0||top.indexOf('v=123')>=0||top.indexOf('emb=1')>=0) bad.push('top level address changed: '+top);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally { reportEmbedded=oEmb; }
     return bad.length?bad.join('; '):null; }},
  {v:'33.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
