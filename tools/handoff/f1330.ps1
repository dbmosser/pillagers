$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v13.30 HARNESS: THE CORPUS RUNNER TAKES A SLICE, so the checks can run in parallel
# across separate-origin fixture servers, on his order of 2026-09-13 to use the whole
# machine while he is away. The runner stepped the whole list on one JavaScript
# thread in one tab, about one of his sixteen threads for twenty-five minutes.
#
# CALLED WITH NO ARGUMENTS IT IS THE SAME RUNNER: the slice defaults to the whole
# list, so every existing call, and the loop step that makes it, is unchanged.
SubRx @'
window.__regressBg=function(){
  var res={pass:true,checked:0,fail:[],skipped:[],cleared:0}, i=0;
  __runPrep();
  window.__PROG={done:0,total:__REGRESS.length,cur:'',finished:false,res:null};
'@ @'
window.__regressBg=function(a,b){
  // v13.30: an optional slice [a,b) of the list, so shards on separate origins can
  // split the corpus. With no arguments the slice is the whole list, as before.
  a=(a|0)||0; b=(b===undefined||b===null)?__REGRESS.length:Math.min(b|0,__REGRESS.length);
  var res={pass:true,checked:0,fail:[],skipped:[],cleared:0,range:[a,b]}, i=a;
  __runPrep();
  window.__PROG={done:0,total:b-a,cur:'',finished:false,res:null,range:[a,b]};
'@

SubRx @'
    if(i>=__REGRESS.length){
'@ @'
    if(i>=b){
'@

SubRx @'
    i++; __PROG.done=i; ch.port2.postMessage(0);
'@ @'
    i++; __PROG.done=i-a; ch.port2.postMessage(0);
'@

SubRx @'
  return 'started '+__REGRESS.length;
'@ @'
  return 'started '+(b-a)+' of '+__REGRESS.length+' ['+a+','+b+')';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
