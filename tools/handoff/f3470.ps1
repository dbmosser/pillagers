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

if ($s.Contains("  {v:'34.70',what:")) { throw "check 34.70 is in the fixture already" }

SubRx @'
  {v:'34.69',what:
'@ @'
  {v:'34.70',what:'the lost pad title tag takes its p1 or p2 colour from the shared table, not from raw colours in the css (his r3-13: P1 amber, P2 cyan)',
   run:function(){
     var oSame=NET.same, bad=[], css='', i, h, sp, col, box;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); __topClear();
       var st=document.querySelectorAll('style'); for(i=0;i<st.length;i++) css+=st[i].textContent;
       if(/\.pl\.p[12]\s*\{[^}]*#[0-9a-fA-F]{3,8}\b/.test(css)) bad.push('the css still types a raw colour on .pl.p1 or .pl.p2');
       togglePauseBox(true); box=document.getElementById('pausebox'); h=document.querySelector('#pausebox h3');
       if(!box||!h) return 'staging: no pause box';
       box.classList.add('padlost');
       [['p1','rgb(245, 183, 59)'],['p2','rgb(95, 215, 232)']].forEach(function(t){
         NET.same=t[0]; padLostTitle(h,false); sp=h.querySelector('.pl.'+t[0]);
         if(!sp){ bad.push(t[0]+': no tag span'); return; }
         col=getComputedStyle(sp).color; if(col!==t[1]) bad.push(t[0]+' tag is '+col+', not '+t[1]);
       });
       return bad.length?bad.join('; '):null;
     }catch(e){ return 'threw: '+(e&&e.stack||e); }
     finally{ NET.same=oSame; try{ if(pauseOpen) togglePauseBox(false); }catch(_p){} try{ __endRaid('abandon'); }catch(_e){} __topClear(); } }},
  {v:'34.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
