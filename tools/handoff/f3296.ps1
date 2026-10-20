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

if ($s.Contains("  {v:'32.96',what:")) { throw "check 32.96 is in the fixture already" }

SubRx @'
  {v:'32.95',what:
'@ @'
  {v:'32.96',what:'the same fault repeating for 6 s asks for exactly one reload and sets the title note; 3 s of it, or one fault, does not (his answer: a crash reloads into the title with a note)',
   run:function(){
     if(typeof crashLoopSeen!=='function'||typeof crashReload!=='function') return 'a repeating fault never reloads (no crashLoopSeen)';
     var rn=crashNow, rh=crashHidden, rr=crashReload, rs=say, sc=P.crashes, t=1000000, reloads=0, ok1, ok2, ok3;
     function burst(ms,msg){ var e=t+ms; while(t<e){ t+=16; noteCrash('error',msg,'x.js:10:5'); } }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       say=function(){}; window.__crashReloadTest=1;
       crashNow=function(){ return t; }; crashHidden=function(){ return false; };
       crashReload=function(){ reloads++; };
       P.crashes=[]; CRASH_RESTART=false; CRASH_RUN=null; try{ sessionStorage.removeItem(CRASH_NOTE_KEY); }catch(_a){}
       noteCrash('error','one fault 1','x.js:1:1'); t+=3000;
       burst(3000,'three seconds 5');
       if(reloads!==0) return 'a single fault or a 3 s burst asked for a reload';
       t+=2000; CRASH_RUN=null;
       burst(6500,'boom 7');
       if(reloads!==1) return 'a fault every frame for 6.5 s asked for '+reloads+' reloads, wanted exactly 1';
       var note=null; try{ note=sessionStorage.getItem(CRASH_NOTE_KEY); }catch(_b){}
       if(note!=='restarted after an error') return 'the title note was not set ('+note+')';
       CRASH_RESTART=false; CRASH_RUN=null; reloads=0; t+=9000;
       crashHidden=function(){ return true; }; burst(7000,'hidden 3');
       if(reloads!==0) return 'a fault while the page was hidden asked for a reload';
       return null;
     } finally {
       crashNow=rn; crashHidden=rh; crashReload=rr; say=rs; P.crashes=sc; CRASH_RESTART=false; CRASH_RUN=null;
       window.__crashReloadTest=0; try{ sessionStorage.removeItem(CRASH_NOTE_KEY); }catch(_c){}
       __topClear();
     } }},
  {v:'32.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
