import { readFileSync } from "node:fs";
import path from "node:path";
import Script from "next/script";

// Slice 1 of B-015: the original page, ported as-is. The markup lives in content/body.html
// and the page script in public/site.js; later slices turn sections into components.
const body = readFileSync(path.join(process.cwd(), "content", "body.html"), "utf8");

export default function Home() {
  return (
    <>
      <div id="site" dangerouslySetInnerHTML={{ __html: body }} />
      <Script src="/site.js" strategy="afterInteractive" />
    </>
  );
}
