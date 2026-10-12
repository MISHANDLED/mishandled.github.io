# mishandled.github.io

My personal site, written in Swift.

- Content: `Sources/Portfolio/Resume.swift` and the posts in `content/blog`.
- Build: `swift run Portfolio` writes the site to `dist`.
- Preview: `swift run Portfolio serve` serves it at http://127.0.0.1:4321 and rebuilds when `content` or `public` change.

Pushing to `main` builds and deploys it to GitHub Pages.

`Sources/SiteKit` is copied from [Sindre Sorhus's website](https://github.com/sindresorhus/sindresorhus.github.com) (MIT, see `Sources/SiteKit/LICENSE-SiteKit`).
