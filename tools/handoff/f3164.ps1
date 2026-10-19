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

if ($s.Contains("  {v:'31.64',what:")) { throw "check 31.64 is in the fixture already" }

SubRx @'
  {v:'31.63',what:
'@ @'
  {v:'31.64',what:'his order 2026-10-18 (no raider on screen; the AI ones are pillager bots): the settings rows, the pillager bots option, the board title, the sound key, the contract words, the callouts and the bush hint say pillager bot(s) and none of them says raider',
   run:function(){
     var bad=[], i, s, src, rx=/\braiders?\b/i, g=null, draws, head=false, old=false, want, txt;
     try{
       // 1. the settings rows (key, label)
       want={nRaider:/pillager bots/i,raiderExtract:/pillager bot/i,raiderFeud:/pillager bot/i,raiderFloorN:/pillager bots/i};
       for(i=0;i<SLIDERS.length;i++){ s=SLIDERS[i];
         if(rx.test(String(s[1]))) bad.push('settings row '+s[0]+' says '+s[1]);
         if(want[s[0]]&&!want[s[0]].test(String(s[1]))) bad.push('settings row '+s[0]+' reads '+JSON.stringify(s[1])+', not pillager bots');
         if(/\bAI pillagers\b|\bpillagers alive\b/i.test(String(s[1]))) bad.push('settings row '+s[0]+' still names the AI ones pillagers: '+s[1]); }
       // 2. the pillager bots option (label and hint)
       for(i=0;i<GAMEOPTS.length;i++){ s=GAMEOPTS[i];
         if(rx.test(String(s.label)+' '+String(s.hint))) bad.push('option '+s.k+' says raider');
         if(s.k==='raiders'&&!/pillager bots/i.test(String(s.label))) bad.push('the AI pillagers option reads '+JSON.stringify(s.label)); }
       // 3. the kind-to-word tables and the sound key
       if(UNITNAME.raider!=='pillager bot'||UNITPLURAL.raider!=='pillager bots'||KINDWORD.raider!=='PILLAGER BOT') bad.push('the kind words read '+UNITNAME.raider+' / '+UNITPLURAL.raider+' / '+KINDWORD.raider);
       txt=JSON.stringify(SOUNDKEY);
       if(txt.indexOf('pillager bot moving')<0||txt.indexOf('pillager bot firing')<0) bad.push('the sound key does not say pillager bot moving and firing');
       // 4. the bush hint on the roadmap, and no raider anywhere on it
       txt=JSON.stringify(ROADMAP);
       if(txt.indexOf('pillager bots who hide in them too')<0) bad.push('the bush hint does not say pillager bots');
       if(rx.test(txt)) bad.push('the roadmap still says raider');
       if(rx.test(JSON.stringify(TERMS))||rx.test(JSON.stringify(ACHS))) bad.push('the heat terms or the achievements say raider');
       // 5. the callouts and legend rows in the page source
       src=[].slice.call(document.scripts).map(function(x){ return x.textContent||''; }).join('\n');
       // (the strings are split so this check does not find itself in the page source)
       ["say('PILLAGER BOT"+" REINFORCEMENTS'","say('PILLAGER BOT"+" TURNED HOSTILE'","say('PILLAGER BOT"+" CALLED EXTRACTION'","hold to finish a pillager"+" bot'","|  Pillager bots"+" extracted: '","pillager bots trust"+" you less.","Kill 25 pillager"+" bots in all.","t:'3 PILLAGER"+" BOTS'","BOUNTY PILLAGER"+" BOT'","a pillager bot"+" who had not fought you."].forEach(function(n){
         if(src.indexOf(n)<0) bad.push('the page has no '+n); });
       ["say('PILLAGER"+" REINFORCEMENTS'","say('PILLAGER"+" TURNED HOSTILE'","say('PILLAGER"+" CALLED EXTRACTION'","hold to finish a pillager"+"'","AI pillagers"+" extracted","and pillagers"+" trust you less","raiders who"+" hide"].forEach(function(n){
         if(src.indexOf(n)>=0) bad.push('the page still says '+n); });
       // 6. the board of who is still out there, drawn in a real raid
       if(typeof __frame==='function'&&typeof __textTrace==='function'){
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state();
         if(g&&g.player){
           draws=__textTrace(function(){ __frame(0.016); });
           for(i=0;i<draws.length;i++){ s=String(draws[i].t);
             if(/^CURRENT PILLAGER BOTS\s+\d+$/.test(s)) head=true;
             if(/^CURRENT PILLAGERS/.test(s)) old=true; }
           if(!head) bad.push('the board drew no CURRENT PILLAGER BOTS heading');
           if(old) bad.push('the board still reads CURRENT PILLAGERS');
         }
       }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
