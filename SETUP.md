# Setup

## Publish with GitHub Pages
GitHub Pages serves `index.html` from the `main` branch root. No Vercel needed for this static page.
On a free GitHub plan Pages only works for **public** repos (GitHub Pro allows private ones).
Settings → Pages → Source: *Deploy from a branch* → `main` / `/ (root)`.
URL: https://christoph-rump.github.io/christoph-lucid-dreaming/ (optional own domain: Settings → Pages → Custom domain).

## Supabase (only for the newsletter / members area later)
A static page can talk to Supabase directly (like the facilitator network does): create a separate Supabase
project and put its URL + `anon` public key into the page config — the anon key is meant to be public;
row-level security protects the data.
