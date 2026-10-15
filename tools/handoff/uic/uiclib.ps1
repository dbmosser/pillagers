# shared helpers for the ui5q2* mk scripts (dot-sourced)
$g=[IO.File]::ReadAllText($Src).Replace("`r",'')
function Cnt([string]$t){ return ([regex]::Matches($g,[regex]::Escape($t))).Count }
$edits=New-Object System.Collections.ArrayList
function Add([string]$a,[string]$r){ $n=Cnt $a; if($n -ne 1){ throw "anchor matched $n times: $($a.Substring(0,[Math]::Min(80,$a.Length)))" }; [void]$edits.Add([ordered]@{ anchor=$a; replacement=$r }) }
$CSSA='  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge'
function Css([string]$block){ Add $CSSA ($block.Replace("`r",'').TrimEnd("`n")+"`n"+$CSSA) }
function Draft([string]$title,[string]$why,[string]$now,[string]$chk){
  if($now.Contains("'")){ throw 'apostrophe in now' }
  $d=[ordered]@{ title=$title; why=$why; now=$now; edits=$edits.ToArray(); check=$chk.Replace("`r",'') }
  [IO.File]::WriteAllText($Out,($d | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding $false))
  "written $($edits.Count) edits"
}
