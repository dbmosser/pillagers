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

if ($s.Contains("  {v:'23.83',what:")) { throw "check 23.83 is in the fixture already" }

SubRx @'
  {v:'23.82',what:
'@ @'
  {v:'23.83',what:'graphics program gfx3: Settings has LIGHTING, POST FX, EFFECT INTENSITY and HUD SIZE rows in caps right after Effects, defaulting to HIGH, ON, FULL and STANDARD, and each click steps the dial (LIGHTING 2, 1, 0, 2)',
   run:function(){
     if(!(window.__opts&&window.__opts.rows&&window.__opts.cycle&&window.__opts.apply)) return 'SKIP: this fixture cannot reach the Settings rows';
     if(typeof gameOptLive!=='function') return 'SKIP: this build has no live row reader';
     var bad=[], rows=__opts.rows()||[], keepG=P.gameOpts, keepT=P.tuned, i, j, k, row, seen, ks, b,
         want=[['gfxLight',2,[2,1,0,2]],['gfxPost',1,[1,0,1]],['fxInt',1,[1,0.5,0,1]],['hudTv',0,[0,1,0]]];
     function rowOf(q){ for(var z=0;z<rows.length;z++) if(rows[z].k===q) return rows[z]; return null; }
     try{
       P.tuned={}; P.gameOpts={}; __opts.apply();
       for(i=0;i<want.length;i++){
         k=want[i][0]; row=rowOf(k);
         if(!row){ bad.push('Settings has no '+k+' row'); continue; }
         if(!row.opts[row.def]||row.opts[row.def].cfg[k]!==want[i][1]) bad.push('the '+k+' row calls '+(row.opts[row.def]?row.opts[row.def].n:row.def)+' its default, not the option that sets '+want[i][1]);
         if(CFG[k]!==want[i][1]) bad.push('a fresh profile has '+k+' '+CFG[k]+', not '+want[i][1]);
         if(gameOptLive(k)!==row.def) bad.push('on a fresh profile the '+k+' row reads option '+gameOptLive(k)+' (CUSTOM or the changed colour), not its default');
         if(row.label!==String(row.label).toUpperCase()) bad.push('the '+k+' label '+row.label+' is not short caps');
         for(j=0;j<row.opts.length;j++) if(row.opts[j].n!==String(row.opts[j].n).toUpperCase()) bad.push('the '+k+' option '+row.opts[j].n+' is not caps');
         seen=[CFG[k]];
         for(j=1;j<want[i][2].length;j++){ __opts.cycle(k); seen.push(CFG[k]); }
         if(seen.join(',')!==want[i][2].join(',')) bad.push('clicking '+k+' steps it '+seen.join(' > ')+', not '+want[i][2].join(' > '));
       }
       ks=rows.map(function(o){ return o.k; });
       if(ks.indexOf('gfxLight')>=0&&ks.indexOf('gfxLight')!==ks.indexOf('fxLevel')+1) bad.push('the LIGHTING row does not sit right after Effects');
       P.tuned={}; P.gameOpts={}; __opts.apply();
       if(typeof renderSettings==='function'&&document.getElementById('setlist')){
         renderSettings();
         b=document.getElementById('go_gfxLight');
         if(!b) bad.push('the Settings page draws no LIGHTING button');
         else if(b.textContent!=='HIGH') bad.push('the LIGHTING button reads '+b.textContent+' on a fresh profile, not HIGH');
         b=document.getElementById('go_hudTv');
         if(!b) bad.push('the Settings page draws no HUD SIZE button');
         else if(b.textContent!=='STANDARD') bad.push('the HUD SIZE button reads '+b.textContent+' on a fresh profile, not STANDARD');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.tuned=keepT||{}; P.gameOpts=keepG||{}; try{ __opts.apply(); }catch(_a){} try{ if(typeof renderSettings==='function'&&document.getElementById('setlist')) renderSettings(); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
