# Exit 0 = healthy: production build passes and the page keeps its structure.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$fail = @()
$env:NEXT_TELEMETRY_DISABLED = '1'
if (-not (Test-Path node_modules)) { npm ci --no-audit --no-fund | Out-Null }
npm run build *> $null
if ($LASTEXITCODE -ne 0) { $fail += 'npm run build failed' }
$body = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'content/body.html'), [Text.Encoding]::UTF8)
foreach ($id in 'main', 'view-lucid-dreaming', 'view-offerings', 'view-events', 'view-contact', 'view-impressum', 'view-privacy', 'nl-form') {
    if ($body -notmatch "id=""$id""") { $fail += "missing #$id" }
}
$js = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'public/site.js'), [Text.Encoding]::UTF8)
if ($js -match 'body > svg') { $fail += 'site.js still uses "body > svg" (markup is inside #site)' }
foreach ($f in 'SETUP.md', 'docs/NOTES.md') { if (-not (Test-Path $f)) { $fail += "missing $f" } }
$open = ([regex]::Matches([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'docs/NOTES.md')), '- \[ \]')).Count
if ($fail) { $fail | ForEach-Object { "FAIL $_" }; exit 1 }
"ok: build green, page structure intact, $open launch items open"
exit 0
