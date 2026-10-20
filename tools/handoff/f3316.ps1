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

if ($s.Contains("  {v:'33.16',what:")) { throw "check 33.16 is in the fixture already" }

SubRx @'
  {v:'33.15',what:
'@ @'
  {v:'33.16',what:'cw-partycallouts, job 66 (RULES: never an explaining sentence on screen; his answer 27): every 2-player party status line, hub toast and teammate-out line is a short lower-case callout with no full stop and no second sentence',
   run:function(){
     var F={}, names=['netOnMsg0','netDrop','netSamePick','netSameHostDone','netGuestHeld','netUpStart','netLateAsk','netUpWord','netUpWhyText','netSpecStart','netSpecEnd','netKitGate','netHostGone'];
     var bad=[], i, k, src, m, re, lits, s, n=0, per, bare;
     try{ F.netOnMsg0=netOnMsg0; F.netDrop=netDrop; F.netSamePick=netSamePick; F.netSameHostDone=netSameHostDone; F.netGuestHeld=netGuestHeld; F.netUpStart=netUpStart;
          F.netLateAsk=netLateAsk; F.netUpWord=netUpWord; F.netUpWhyText=netUpWhyText; F.netSpecStart=netSpecStart; F.netSpecEnd=netSpecEnd; F.netKitGate=netKitGate; F.netHostGone=netHostGone; }
     catch(e){ return 'SKIP: the party code is not in this build ('+(e&&e.message||e)+')'; }
     for(i=0;i<names.length;i++){
       if(typeof F[names[i]]!=='function') return 'SKIP: no '+names[i]+' here';
       // the code alone: block comments and line comments go, so a note that quotes an old line is never read as a line
       src=String(F[names[i]]).replace(/\/\*[\s\S]*?\*\//g,'').replace(/(^|[\s;{}])\/\/[^\n]*/g,'$1');
       re=/(NET\.status\s*\+?=|netSay\(|\bln\s*=|\breturn\s+)([^;\n]*)/g; per=0;
       while((m=re.exec(src))){
         if(m[1].indexOf('return')===0&&names[i]!=='netUpWhyText') continue;
         lits=m[2].match(/'(?:[^'\\]|\\.)*'/g)||[];
         for(k=0;k<lits.length;k++){
           s=lits[k].slice(1,-1); bare=s.replace(/\\u[0-9a-fA-F]{4}/g,' ');
           if(!/[a-z]{2}/i.test(bare)) continue;
           n++; per++;
           if(/\./.test(bare)) bad.push(names[i]+': "'+s+'" has a full stop');
           else if(/[A-Z]/.test(bare)) bad.push(names[i]+': "'+s+'" is not lower case');
         }
       }
       if(!per) bad.push(names[i]+': no party line found to read');
     }
     if(n<25) bad.push('only '+n+' party lines read, 25 or more expected');
     if(typeof netUpWhyText==='function'){ s=netUpWhyText('on the title'); if(!/title/.test(s)) bad.push('the on-the-title reason lost its word ("'+s+'")'); }
     return bad.length?bad.slice(0,8).join('; ')+(bad.length>8?' (+'+(bad.length-8)+' more)':''):null; }},
  {v:'33.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
