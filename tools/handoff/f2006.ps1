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

if ($s.Contains("  {v:'20.06',what:")) { throw "check 20.06 is in the fixture already" }

SubRx @'
  {v:'20.05',what:
'@ @'
  {v:'20.06',what:'a bare-legged outfit wears shorts on a Curved body: the Baller hips are a dark red, not skin, and the legs below stay bare',
   run:function(){
     if(typeof drawOp!=='function'||typeof COSKEY==='undefined'||typeof OUTFITS==='undefined') return 'SKIP: no painter or outfits here';
     var kb=COSKEY.build||'cosBuild', ko=COSKEY.outfit||'cosOutfit', b0=P[kb], o0=P[ko], a0=P.cosAll, w0=wc, cv=document.createElement('canvas'), x2, bad=[], d, sk;
     cv.width=240; cv.height=220; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     try{
       P.cosAll=true; P[kb]='curved'; P[ko]='outballer';
       x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190); wc=x2;
       drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0; x2.setTransform(1,0,0,1,0,0);
       d=x2.getImageData(Math.round(120+4.4*4),Math.round(190-12.6*4),1,1).data;   // out on the hip, past the legs
       sk=(d[0]>200&&d[1]>150);   // skin is light; the shorts are a dark red
       if(d[3]<40) bad.push('nothing drawn at the hip');
       else if(sk) bad.push('the Baller hips are bare skin ('+d[0]+','+d[1]+','+d[2]+')');
       else if(!(d[0]>d[1]+30)) bad.push('the Baller hips are not red ('+d[0]+','+d[1]+','+d[2]+')');
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[kb]=b0; P[ko]=o0; P.cosAll=a0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
