param([string]$Root="C:\claudecode\dark raiders",[int]$Port=8802)
$listener=New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
$types=@{".html"="text/html; charset=utf-8";".js"="text/javascript";".css"="text/css";".json"="application/json";".png"="image/png"}
while($listener.IsListening){
  try{
    $ctx=$listener.GetContext()
    $rel=[uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if([string]::IsNullOrWhiteSpace($rel)){ $rel="dark_raiders.html" }
    $path=Join-Path $Root $rel
    if(Test-Path -LiteralPath $path -PathType Leaf){
      $ext=[System.IO.Path]::GetExtension($path).ToLower()
      $ctx.Response.ContentType=$(if($types.ContainsKey($ext)){$types[$ext]}else{"application/octet-stream"})
      $ctx.Response.Headers.Add("Cache-Control","no-store")
      $b=[System.IO.File]::ReadAllBytes($path)
      $ctx.Response.ContentLength64=$b.Length
      $ctx.Response.OutputStream.Write($b,0,$b.Length)
    } else { $ctx.Response.StatusCode=404 }
    $ctx.Response.Close()
  }catch{}
}