param([string[]]$Files, [int]$X=300, [int]$Y=700, [int]$W=300, [int]$H=200)
Add-Type -AssemblyName System.Drawing
foreach($f0 in ($Files -split ",")){ $f=(Resolve-Path $f0).Path
  $bmp=[System.Drawing.Bitmap]::FromFile($f); $r=0;$g=0;$b=0;$n=0
  for($yy=$Y;$yy -lt $Y+$H;$yy+=4){ for($xx=$X;$xx -lt $X+$W;$xx+=4){ $c=$bmp.GetPixel($xx,$yy); $r+=$c.R;$g+=$c.G;$b+=$c.B;$n++ } }
  $bmp.Dispose()
  $r=[math]::Round($r/$n,1);$g=[math]::Round($g/$n,1);$b=[math]::Round($b/$n,1)
  $mx=[math]::Max($r,[math]::Max($g,$b)); $mn=[math]::Min($r,[math]::Min($g,$b)); $sat=if($mx -gt 0){[math]::Round(($mx-$mn)/$mx,3)}else{0}
  "$([IO.Path]::GetFileName($f)) mean=($r,$g,$b) sat=$sat"
}
