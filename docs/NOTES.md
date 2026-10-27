# Notes and launch list

## Must be done before going live
- [ ] **Privacy — hosting:** the privacy text says "hosted by [hosting provider]" → Vercel Inc. (review the wording).
- [ ] **Privacy — fonts:** fonts still load from Google Fonts (your own draft note says: self-host before launch).
      Plan: serve the font files from this site, then delete the draft note.
- [ ] **Newsletter:** the form has no backend (`action=""`) and the privacy text says "[newsletter provider]".
      Needs a provider with double opt-in — a decision for you.
- [ ] Legal notice (Impressum): check the address and contact details are current.

## Port details (slice 1)
- The page is the original file split into markup/CSS/script, unchanged except one selector in `public/site.js`:
  `body > svg[...]` → `#site > svg[...]` (the markup now sits in `<div id="site">`).
- Checked in a browser: renders, EN/DE switch (persists), views (Offerings, etc.), animation pause, phone width
  with no horizontal scroll, no console errors.
