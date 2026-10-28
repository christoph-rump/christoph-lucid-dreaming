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

## Newsletter (B-015b) — your steps, about 10 minutes
All in the lucid site's **own** Supabase project (not the facilitator network's).
1. **SQL:** SQL editor → paste `supabase/newsletter.sql` → Run.
2. **Email sender:** Project Settings → Authentication → SMTP → enable custom SMTP with the same Resend
   settings as the facilitator project (host `smtp.resend.com`, port 465, user `resend`, password = a Resend
   API key you create and paste yourself; sender address on your verified Resend domain).
3. **Links:** Authentication → URL Configuration → Site URL `https://christoph-rump.github.io/christoph-lucid-dreaming/`
   (add your own domain later, e.g. after the all-inkl move) and the same URL under Redirect URLs.
4. **Template:** Authentication → Email Templates → *Magic Link*: copy your facilitator template and make it a
   newsletter confirmation, e.g. subject "Please confirm your newsletter sign-up / Bitte bestätige deine Anmeldung",
   button linking to `{{ .ConfirmationURL }}`.
5. **Send NOX** the Project URL and the **anon public** key (Project Settings → API). Never the `service_role` key.
   NOX puts them into `index.html`; `validate.ps1` refuses any key that is not the anon key.

Unsubscribe links in each newsletter: `https://…/#unsubscribe=<unsubscribe_token>` (column in `subscribers`).
Your list: Table editor → `subscribers`, rows with `confirmed_at` set and `unsubscribed_at` empty.
