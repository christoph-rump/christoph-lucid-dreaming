# Exit 0 = healthy: index.html exists, parses as one page, keeps its sections and script.
Set-Location $PSScriptRoot
$fail = @()
if (-not (Test-Path index.html)) { 'FAIL missing index.html'; exit 1 }
$h = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'index.html'), [Text.Encoding]::UTF8)
if ($h -notmatch '(?s)^<!DOCTYPE html>.*<html[^>]*>.*</html>\s*$') { $fail += 'not a complete HTML document' }
foreach ($id in 'main', 'view-lucid-dreaming', 'view-offerings', 'view-events', 'view-contact', 'view-impressum', 'view-privacy', 'nl-form', 'view-members', 'mb-form') {
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
if ($h -match 'class="ph" data-i18n="pv_ph_nl"') { $fail += 'privacy placeholder left: pv_ph_nl' }
# The page may only ever hold the anon public key, never the service_role key (B-015b)
$key = [regex]::Match($h, 'var SUPABASE_ANON_KEY = "([^"]*)"').Groups[1].Value
if ($key) {
    try {
        $p = $key.Split('.')[1].Replace('-', '+').Replace('_', '/'); $p += '=' * ((4 - $p.Length % 4) % 4)
        $role = ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($p)) | ConvertFrom-Json).role
        if ($role -ne 'anon') { $fail += "SUPABASE_ANON_KEY has role '$role' - only the anon public key belongs in the page" }
    } catch { if ($key -notmatch '^sb_publishable_') { $fail += 'SUPABASE_ANON_KEY is neither an anon JWT nor a publishable key' } }
}
foreach ($f in 'SETUP.md', 'docs/NOTES.md', 'fonts/fonts.css', 'supabase/newsletter.sql', 'supabase/members.sql') { if (-not (Test-Path $f)) { $fail += "missing $f" } }
$open = ([regex]::Matches([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'docs/NOTES.md')), '- \[ \]')).Count
if ($fail) { $fail | ForEach-Object { "FAIL $_" }; exit 1 }
"ok: index.html intact, $open launch items open"
exit 0
