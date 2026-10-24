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

if ($s.Contains("  {v:'34.22',what:")) { throw "check 34.22 is in the fixture already" }

SubRx @'
  {v:'34.21',what:
'@ @'
  {v:'34.22',what:'welcome pack and party card (critic 02 and 07 = 2): the welcome pack has no intro line or stash hints, its close is a 48px X in the card corner and its primary is lime; the party card is a fitted 960 card with a lime host button and a one line 56px invite field, no trade line',
   run:function(){
     if(typeof openParty!=='function'||typeof openModal!=='function') return 'SKIP: no party window';
     var wm, pm, c, r, b, q, z=1, cx, cy, res=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       wm=document.getElementById('welcomemodal'); pm=document.getElementById('partymodal');
       openModal('welcomemodal');
       if(getComputedStyle(wm.querySelector('.msub')).display!=='none') return 'the welcome pack still shows its explaining line';
       r=document.getElementById('welcomeno').getBoundingClientRect();
       z=r.width/48;
       if(Math.abs(r.width-r.height)>1||z<0.6||z>1.6) return 'the welcome close is '+Math.round(r.width)+'x'+Math.round(r.height)+', not a square X';
       q=wm.getBoundingClientRect(); cx=q.left+q.width/2; cy=q.top+q.height/2;
       if(r.left+r.width/2<cx+300*z||r.left+r.width/2>cx+480*z||r.top+r.height/2>cy-60*z) return 'the welcome X is not in the top right corner of the card ('+Math.round(r.left)+','+Math.round(r.top)+' in modal '+Math.round(q.left)+','+Math.round(q.top)+','+Math.round(q.width)+'x'+Math.round(q.height)+' z '+z.toFixed(2)+')';
       b=getComputedStyle(document.getElementById('welcometake')).backgroundColor;
       if(b!=='rgb(230, 255, 61)') return 'the welcome primary is not lime: '+b;
       openParty();
       c=getComputedStyle(pm,'::before');
       if(parseFloat(c.width)>961) return 'the party card is '+c.width+' wide, not a fitted 960 card';
       if(getComputedStyle(document.getElementById('partytrade')).display!=='none') return 'the party card still shows the trade line';
       b=getComputedStyle(document.getElementById('partyhost')).backgroundColor;
       if(b!=='rgb(230, 255, 61)') return 'host a party is not the lime primary: '+b;
       r=document.getElementById('partyin').getBoundingClientRect();
       if(Math.abs(r.height/z-56)>2) return 'the invite field is '+Math.round(r.height)+'px high, not one 56px line';
       if(document.getElementById('partyin').placeholder.length>20) return 'the invite field still holds a sentence';
       r=document.getElementById('closeparty').getBoundingClientRect();
       if(Math.abs(r.width-r.height)>1||r.width/z<44||r.width/z>52) return 'the party close is not a square X';
       return null;
     } finally {
       try{ __topClear(); }catch(_e){}
     } }},
  {v:'34.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
