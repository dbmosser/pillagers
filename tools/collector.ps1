param(
  [string]$Root = "C:\claudecode\dark raiders",
  [int]$Port = 8799
)
# Telemetry collector. The game POSTs its flight recorder here and this writes it
# straight into exports/, so Daniel never sees a browser save dialog.
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Output "collector on http://localhost:$Port/ writing to $Root\exports"
$types = @{ ".html" = "text/html; charset=utf-8"; ".js" = "text/javascript"; ".css" = "text/css"; ".txt" = "text/plain; charset=utf-8" }
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $res.Headers.Add("Access-Control-Allow-Origin", "*")
    $res.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
    $res.Headers.Add("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
    if ($req.HttpMethod -eq "OPTIONS") { $res.StatusCode = 204; $res.Close(); continue }
    $path = [uri]::UnescapeDataString($req.Url.AbsolutePath.TrimStart('/'))
    if ($req.HttpMethod -eq "POST" -and $path -eq "telemetry") {
      $reader = New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)
      $body = $reader.ReadToEnd(); $reader.Close()
      $dir = Join-Path $Root "exports"
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
      # 2026-09-27: two co-op windows can post in the same second; milliseconds, a p2 tag and a counter keep every report.
      $stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
      $tag = $(if ($body -match "Window: player 2") { "-p2" } else { "" })
      $file = Join-Path $dir "run-$stamp$tag.txt"; $k = 2
      while (Test-Path -LiteralPath $file) { $file = Join-Path $dir "run-$stamp$tag-$k.txt"; $k++ }
      Set-Content -Path $file -Value $body -Encoding utf8
      $out = [System.Text.Encoding]::UTF8.GetBytes("saved")
      $res.ContentType = "text/plain"
      $res.OutputStream.Write($out, 0, $out.Length)
      $res.Close(); continue
    }
    # otherwise behave as a plain static file server for the same folder
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "dark_raiders.html" }
    $full = Join-Path $Root $path
    if (Test-Path -LiteralPath $full -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($full).ToLower()
      $res.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { "application/octet-stream" })
      $res.Headers.Add("Cache-Control", "no-store")
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $b = [System.Text.Encoding]::UTF8.GetBytes("404 $path")
      $res.OutputStream.Write($b, 0, $b.Length)
    }
    $res.Close()
  } catch { }
}
