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

if ($s.Contains("  {v:'20.70',what:")) { throw "check 20.70 is in the fixture already" }

SubRx @'
  {v:'20.69',what:
'@ @'
  {v:'20.70',what:'a contract gun he already owns pays the value the game shows for that gun: with the loot dial off its default the payment and the receipt are the scaled value, not the table value',
   run:function(){
     if(typeof payGear!=='function'||typeof ival!=='function'||typeof CGEAR!=='object'||!CGEAR||!window.__P) return 'SKIP: no contract gear here';
     var P2=__P(), bad=[], k=null, t, i, q, lm=CFG.lootMult, cr=P2.credits, hadW=Array.isArray(P2.weapons), wp=hadW?P2.weapons.slice():null, eq=P2.equipped, got, want, d;
     for(t in CGEAR){ for(i=0;i<(CGEAR[t]||[]).length;i++){ q=CGEAR[t][i]; if(q&&q.kind==='wep'&&WEAPONS[q.k]&&ITEMS['gun_'+q.k]&&ITEMS['gun_'+q.k].val>0){ k=q.k; break; } } if(k) break; }
     if(!k) return 'SKIP: no contract gun with a value';
     try{
       CFG.lootMult=1.37;
       if(!hadW) P2.weapons=[];
       if(P2.weapons.indexOf(k)<0) P2.weapons.push(k);
       P2.credits=5000;
       want=ival('gun_'+k);
       if(want===ITEMS['gun_'+k].val) return 'SKIP: the scaled value is the table value here';
       got=String(payGear({kind:'wep',k:k}));
       d=(P2.credits|0)-5000;
       if(d!==want) bad.push('the owned '+WEAPONS[k].name+' paid '+d+', not the '+want+' the stash shows for it');
       if(got.indexOf('$'+want.toLocaleString())<0) bad.push('the receipt reads "'+got+'", not the shown value of '+want);
       if(P2.weapons.filter(function(w){ return w===k; }).length!==1) bad.push('control: the armoury now holds the gun '+P2.weapons.filter(function(w){ return w===k; }).length+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.lootMult=lm; P2.credits=cr; if(hadW) P2.weapons=wp; else delete P2.weapons; P2.equipped=eq; try{ saveProfile(); }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'20.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
