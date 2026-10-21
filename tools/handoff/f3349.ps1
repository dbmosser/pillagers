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

if ($s.Contains("  {v:'33.49',what:")) { throw "check 33.49 is in the fixture already" }

SubRx @'
  {v:'33.48',what:
'@ @'
  {v:'33.49',what:'both what is new views show three short lowercase real notes without alpha or polish fillers',
   run:function(){
     var bad=[], list=document.getElementById('wnlist'), modal=document.getElementById('wnmodal'), cls, html, sub=document.getElementById('wnsub'), oldSub;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!list||!modal||typeof wnList!=='function') return 'what is new controls missing';
       cls=modal.className; html=list.innerHTML; oldSub=sub&&sub.textContent;
       var lines=wnList(), want=['experimental switches in settings','one feed for loot, kills and sp','full raid log with copy report'];
       if(JSON.stringify(lines)!==JSON.stringify(want)) bad.push('the shown news is not the three short real notes');
       if(/\balpha\b|polish pass|daniel/i.test(WHATSNEW.join('|'))) bad.push('the news still contains private or filler copy');
       for(var i=0;i<lines.length;i++){
         if(lines[i]!==lines[i].toLowerCase()||lines[i].length>48) bad.push('note '+i+' is not short lowercase text');
         if(wnHead(lines[i])!==lines[i]||wnShort(lines[i])!==lines[i]) bad.push('the card clips note '+i);
       }
       wnOpen();
       if(list.children.length!==3) bad.push('the pause window does not show three notes');
       for(i=0;i<list.children.length;i++) if(list.children[i].textContent!==TX((i+1)+'. '+want[i])) bad.push('the pause window changed note '+i);
       return bad.length?bad.join('; '):null;
     } finally {
       if(cls!==undefined) modal.className=cls; if(html!==undefined) list.innerHTML=html; if(sub&&oldSub!==undefined) sub.textContent=oldSub;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'33.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
