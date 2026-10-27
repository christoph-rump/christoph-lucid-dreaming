# Setup — only you can do these steps

NOX never creates accounts or handles keys. You already have Vercel and Supabase (GitHub login).

## 1. Put it on Vercel (makes the site reachable — do this when the launch list in docs/NOTES.md is done)
1. vercel.com → **Add New… → Project** → import `christoph-rump/christoph-lucid-dreaming`.
2. Framework: Next.js (detected). No settings needed. **Deploy.**
3. Optional: **Settings → Domains** to add your own domain.

## 2. Supabase (only needed once the newsletter / members area is built)
1. supabase.com → **New project** (separate from the facilitator network's project).
2. **Settings → API**: copy the Project URL and the `anon` public key.
3. Vercel → this project → **Settings → Environment Variables**:
   `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Redeploy.
