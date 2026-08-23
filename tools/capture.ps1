# Tiny sink so the page can hand a rendered frame straight to disk. Avoids
# round-tripping a few thousand base64 characters through the transcript.
param([int]$Port=8779,
      [string]$Out='C:\Users\User1\Desktop\dark raiders\tools\shots')
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Output "capture sink on http://localhost:$Port/"
while ($l.IsListening) {
  try {
    $ctx = $l.GetContext()
    $res = $ctx.Response
    $res.Headers.Add('Access-Control-Allow-Origin','*')
    $res.Headers.Add('Access-Control-Allow-Headers','*')
    $res.Headers.Add('Access-Control-Allow-Methods','POST,OPTIONS')
    if ($ctx.Request.HttpMethod -eq 'OPTIONS') { $res.StatusCode = 204; $res.Close(); continue }
    $name = [uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($name)) { $name = 'capture' }
    $name = ($name -replace '[^A-Za-z0-9_.-]','_')
    $sr = New-Object System.IO.StreamReader($ctx.Request.InputStream, $ctx.Request.ContentEncoding)
    $body = $sr.ReadToEnd(); $sr.Close()
    $body = $body.Trim()
    try {
      [System.IO.File]::WriteAllBytes((Join-Path $Out $name), [System.Convert]::FromBase64String($body))
      $msg = "ok $($body.Length)"
    } catch { $msg = "ERR $($_.Exception.Message)" }
    $b = [System.Text.Encoding]::UTF8.GetBytes($msg)
    $res.ContentLength64 = $b.Length
    $res.OutputStream.Write($b, 0, $b.Length)
    $res.Close()
  } catch { }
}
