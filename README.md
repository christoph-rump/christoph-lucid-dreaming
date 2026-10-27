# Christoph Rump – Lucid dreaming

Personal site for lucid dreaming workshops, retreats and courses. Separate project from the
facilitator network (`lucid-dreaming-network`); built and maintained by NOX (backlog item B-015).

- Stack: Next.js (static), plain JS. Supabase comes in with the newsletter and members area.
- `content/body.html` — page markup (ported 1:1 from the original single-file page)
- `app/globals.css` — styles · `public/site.js` — language switch (EN/DE), views, animation, newsletter form
- `npm run dev` / `npm run build` · `validate.ps1` checks the build and the page structure

First-time deploy: see [SETUP.md](SETUP.md). Open items before going live: [docs/NOTES.md](docs/NOTES.md).
