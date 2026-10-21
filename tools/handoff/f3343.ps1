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

if ($s.Contains("  {v:'33.43',what:")) { throw "check 33.43 is in the fixture already" }

SubRx @'
  {v:'33.42',what:
'@ @'
  {v:'33.43',what:'public report text has no private contact name and successful report copy says report copied',
   run:function(){
     var bad=[], btn=document.getElementById('copybtn'), ta=document.getElementById('exporttext');
     var desc=Object.getOwnPropertyDescriptor(navigator,'clipboard'), ex=document.execCommand, timer=window.setTimeout, oldText, oldValue;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!btn||!ta) return 'report copy controls missing';
       oldText=btn.textContent; oldValue=ta.value;
       var hint=document.getElementById('oc_copynote'), oc=document.getElementById('oc_copy');
       var texts=[hint?hint.textContent:'',WHATSNEW.join('|'),JSON.stringify(TXSHIP),String(btn.onclick),String(oc&&oc.onclick),String(window.__realDownloadExport||downloadExport)];
       var modal=document.getElementById('spane_rec'); if(modal) texts.push(modal.textContent);
       if(/daniel/i.test(texts.join('|'))) bad.push('report text still names a private contact');
       Object.defineProperty(navigator,'clipboard',{value:undefined,configurable:true});
       document.execCommand=function(cmd){ return cmd==='copy'; };
       window.setTimeout=function(){ return 0; };
       ta.value='report copy probe'; btn.onclick();
       if(btn.textContent!=='report copied') bad.push('successful report copy says '+btn.textContent);
       if(ta.value!=='report copy probe') bad.push('copy changed the report');
       return bad.length?bad.join('; '):null;
     } finally {
       document.execCommand=ex; window.setTimeout=timer;
       if(desc) Object.defineProperty(navigator,'clipboard',desc); else delete navigator.clipboard;
       if(btn&&oldText!==undefined) btn.textContent=oldText; if(ta&&oldValue!==undefined) ta.value=oldValue;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'33.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
