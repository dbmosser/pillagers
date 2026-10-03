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

if ($s.Contains("  {v:'18.25',what:")) { throw "check 18.25 is in the fixture already" }

SubRx @'
  {v:'18.24',what:
'@ @'
  {v:'18.25',what:'the floor says how to trade while a party is on: the pause-box key line names the trade key, the stash idle text says how to offer when the windows are linked, and the Undercroft bottom line and H card gain the take line',
   run:function(){
     if(typeof keysLegendHtml!=='function') return 'SKIP: no key line here';
     var bad=[], keep={on:NET.on,role:NET.role,peers:NET.peers}, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, lines=[], src='', oFT=ctx.fillText, det=document.getElementById('invdetail')||document.querySelector('#hub .detail');
     if(!/offer|trade/.test(keysLegendHtml())) bad.push('the pause-box key line does not name the trade key');
     try{
       NET.on=true; NET.role='host'; NET.peers=[peer];
       try{ if(typeof renderHub==='function') renderHub(); }catch(_r){}   // the stash screen render is what writes the idle text
       src=(document.getElementById('stashdetail')||{}).textContent||'';   // textContent: the stash screen is hidden here and innerText leaves hidden text out
       if(!/pick Offer|choose Offer/.test(src)) bad.push('the stash idle text does not say how to offer while linked');
       if(typeof drawHubHUD==='function'&&typeof HB!=='undefined'&&HB){
         ctx.fillText=function(s){ lines.push(String(s)); return oFT.apply(this,arguments); };
         try{ HB.legend=true; drawHubHUD(0,0); }catch(_h){ bad.push('the floor HUD threw: '+(_h&&_h.message||_h)); }
         finally{ HB.legend=false; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
         if(!lines.some(function(s){ return /TAKE AN OFFER/.test(s); })) bad.push('the Undercroft bottom line does not say T TAKE AN OFFER with a party on');
         if(!lines.some(function(s){ return /take an offer/.test(s); })) bad.push('the floor H card has no trade row with a party on');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; try{ if(typeof renderHub==='function') renderHub(); }catch(_r2){} try{ __topClear(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
