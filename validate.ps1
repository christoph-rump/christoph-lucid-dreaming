# Exit 0 = healthy: index.html exists, parses as one page, keeps its sections and script.
Set-Location $PSScriptRoot
$fail = @()
if (-not (Test-Path index.html)) { 'FAIL missing index.html'; exit 1 }
$h = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'index.html'), [Text.Encoding]::UTF8)
if ($h -notmatch '(?s)^<!DOCTYPE html>.*<html[^>]*>.*</html>\s*$') { $fail += 'not a complete HTML document' }
foreach ($id in 'main', 'view-lucid-dreaming', 'view-offerings', 'view-events', 'view-contact', 'view-impressum', 'view-privacy', 'nl-form') {
    if ($h -notmatch "id=""$id""") { $fail += "missing #$id" }
}
if (([regex]::Matches($h, '<script>')).Count -ne 1) { $fail += 'expected exactly one inline script' }
if ($h -match 'fonts\.(googleapis|gstatic)\.com') { $fail += 'page still loads Google Fonts' }
if (Test-Path fonts/fonts.css) {
    foreach ($m in [regex]::Matches([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'fonts/fonts.css')), 'url\(([^)]+)\)')) {
        if (-not (Test-Path "fonts/$($m.Groups[1].Value)")) { $fail += "missing font file $($m.Groups[1].Value)" }
    }
}
foreach ($ph in 'pv_ph_host', 'pv_font_ph') { if ($h -match "class=""ph"" data-i18n=""$ph""") { $fail += "privacy placeholder left: $ph" } }
foreach ($f in 'SETUP.md', 'docs/NOTES.md', 'fonts/fonts.css') { if (-not (Test-Path $f)) { $fail += "missing $f" } }
$open = ([regex]::Matches([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'docs/NOTES.md')), '- \[ \]')).Count
if ($fail) { $fail | ForEach-Object { "FAIL $_" }; exit 1 }
"ok: index.html intact, $open launch items open"
exit 0
