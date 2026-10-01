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

if ($s.Contains("  {v:'17.52',what:")) { throw "check 17.52 is in the fixture already" }

SubRx @'
  {v:'17.51',what:
'@ @'
  {v:'17.52',what:'a trade offer stays on screen while it is open: the HUD names who offers what, the keys that take it and the seconds left, the giver sees who it waits on, and the line goes when the offer runs out',
   run:function(){
     if(typeof drawGiftLine!=='function') return 'this build shows a trade offer only once in the message feed';
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no raid in this fixture';
     var bad=[], s, o=drawGiftLine, n=0, nm;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       nm=ITEMS.codex?ITEMS.codex.name:'codex';
       G.t=50; G.giftIn={id:'tst',k:'codex',from:1,t:50};
       s=drawGiftLine();
       if(!s||s.indexOf(nm)<0||s.indexOf('T or Y')<0||s.indexOf('12s')<0) bad.push('an open offer showed '+JSON.stringify(s));
       G.giftIn.yes=1; if(drawGiftLine()) bad.push('the offer line stayed after the item was taken');
       G.giftIn={id:'tst',k:'codex',from:1,t:50}; G.t=63;
       if(drawGiftLine()) bad.push('the offer line stayed after the offer ran out');
       G.giftIn=null; G.giftOut={id:'out',k:'codex',to:1,t:63};
       s=drawGiftLine();
       if(!s||s.indexOf('Offered')<0||s.indexOf(nm)<0) bad.push('the giver saw '+JSON.stringify(s));
       G.giftOut=null;
       drawGiftLine=function(){ n++; return null; };
       try{ drawHUD(); }catch(_h){}
       if(!n) bad.push('the HUD does not draw the offer line');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       drawGiftLine=o;
       try{ if(G){ G.giftIn=null; G.giftOut=null; } }catch(_g){}
       try{ __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
