import Elementary
import SiteKit

/**
The bar at the top of every page, like a terminal: my name, the sections as `~/paths`, a theme button, and a hairline that fills as the page scrolls.

On the home page, `nav.js` turns the link of the section on screen green. On phones, the links move into a drawer that slides in from the side.
*/
struct SiteNav: HTML {
	/**
	The ID of the link that starts out green, like `writing` on a post, or `about` on the about page.
	*/
	var current = "top"

	private static let menuID = "site-menu"

	// Each link: its title, where it goes, and the ID that `nav.js` follows. About is a page of its own, the rest are sections of the home page.
	private static let sections = [
		("home", "/#top", "top"),
		("about", AboutPage.path.description, "about"),
		("writing", "/#writing", "writing"),
		("experience", "/#experience", "experience"),
		("work", "/#open-source", "open-source"),
		("contact", "/#contact", "contact"),
	]

	var body: some HTML {
		header {
			div {
				Brand()

				nav(.custom(name: "aria-label", value: "Primary")) {
					links(style: Styles.link)
				}
				.style(Styles.links)

				div {
					button(.type(.button), .data("theme-toggle", value: ""), .custom(name: "aria-label", value: "Switch between light and dark")) {
						HTMLRaw(Icons.theme)
					}
					.style(Styles.iconButton)

					button(.type(.button), .popoverTarget(Self.menuID), .custom(name: "aria-label", value: "Open menu")) {
						HTMLRaw(Icons.menu)
					}
					.style(Styles.iconButton, Styles.menuButton)
				}
				.style(Styles.actions)
			}
			.style(Styles.inner)

			span { "" }
				.accessibilityHidden()
				.style(Styles.progress)
		}
		.style(Styles.root)

		div(.id(Self.menuID), .custom(name: "popover", value: "")) {
			div {
				Brand()

				button(.type(.button), .popoverTarget(Self.menuID), .custom(name: "popovertargetaction", value: "hide"), .custom(name: "aria-label", value: "Close menu")) {
					HTMLRaw(Icons.close)
				}
				.style(Styles.iconButton)
			}
			.style(Styles.drawerHeader)

			nav(.custom(name: "aria-label", value: "Menu")) {
				links(style: Styles.drawerLink)
			}
			.style(Styles.drawerLinks)
		}
		.style(Styles.drawer)

		script(.type(.module), .src("/scripts/nav.js")) {}
	}

	private func links(style: Styles) -> some HTML<HTMLTag.ul> {
		ul {
			for (title, href, id) in Self.sections {
				li {
					if id == current {
						a(.href(href), .data("section", value: id), .ariaCurrent("true")) { title }
							.style(style)
					} else {
						a(.href(href), .data("section", value: id)) { title }
							.style(style)
					}
				}
			}
		}
	}

	/**
	My name, like a domain: a green dot, `devansh` bright, and `.mohata` dim.
	*/
	struct Brand: HTML {
		var body: some HTML<HTMLTag.a> {
			a(.href("/#top")) {
				span { "" }
					.accessibilityHidden()
					.style(Styles.dot)
				"devansh"
				span { ".mohata" }
					.style(Styles.dim)
			}
			.style(Styles.root)
		}

		enum Styles: StyleSet {
			case root
			case dot
			case dim

			var style: Style {
				switch self {
				case .root:
					Style()
						.hstack(alignment: .center, spacing: 0)
						.declaration(.justifySelf, "start")
						.color(.semantic(.primaryText))
						.fontWeight(.medium)
						.hover { $0.declaration(.textDecoration, "none") }
				case .dot:
					Style()
						.frame(width: .rootEm(0.45), height: .rootEm(0.45))
						.margin(.trailing, .rootEm(0.65))
						.cornerRadius(.percent(50))
						.background(.semantic(.accent))
						.declaration(.boxShadow, "0 0 0.6rem var(--accent)")
				case .dim:
					Style()
						.color(.semantic(.secondaryText))
						.fontWeight(.regular)
				}
			}
		}
	}

	enum Styles: StyleSet {
		case root
		case inner
		case links
		case link
		case actions
		case iconButton
		case menuButton
		case progress
		case drawer
		case drawerHeader
		case drawerLinks
		case drawerLink

		var style: Style {
			switch self {
			case .root:
				Style()
					.position(.sticky)
					.top(0)
					.zIndex(10)
					.background(Color.semantic(.pageBackground).opacity(0.75))
					.backdropFilter(.blur(radius: .pixels(12)))
					.border(.bottom, .semantic(.separator))
			case .inner:
				// Name on the left, links in the middle, buttons on the right.
				Style()
					.grid(columns: "1fr auto 1fr")
					.declaration(.alignItems, "center")
					.gap(.rootEm(1))
					.frame(maxWidth: .pageWidth, minHeight: .rootEm(3.5))
					.margin(vertical: 0, horizontal: .auto)
					.padding(.horizontal, .pageGutter)
					.font(size: .rootEm(0.85))
			case .links:
				// The list and its hiding are one rule, so the hiding is not overridden on phones.
				Style()
					.hidden(below: .navLinks)
					.children("ul") { $0.hstack(spacing: .rootEm(0.15)) }
			case .link:
				Style()
					.display(.block)
					.padding(vertical: .rootEm(0.45), horizontal: .rootEm(0.75))
					.squircle(.rootEm(0.5))
					.font(size: .rootEm(0.8))
					.color(.semantic(.secondaryText))
					.transition(.colors, animation: .default(duration: .milliseconds(150)))
					.before { $0.content("~/", alternativeText: "").opacity(0.4) }
					.hover {
						$0.declaration(.textDecoration, "none")
							.color(.semantic(.primaryText))
							.background(.semantic(.matteHover))
					}
					.nested("&[aria-current]") { $0.color(.semantic(.accent)) }
			case .actions:
				// Always the last column, so the buttons stay on the right when the links are hidden.
				Style()
					.hstack(alignment: .center, justification: .end, spacing: .rootEm(0.5))
					.declaration(.gridColumn, "3")
					.declaration(.justifySelf, "end")
			case .iconButton:
				Style()
					.display(.grid)
					.declaration(.alignItems, "center")
					.declaration(.justifyContent, "center")
					.frame(width: .rootEm(2.25), height: .rootEm(2.25))
					.padding(0)
					.squircle(.rootEm(0.6))
					.border(.semantic(.separator))
					.background(.transparent)
					.color(.semantic(.secondaryText))
					.cursor(.pointer)
					.transition(.colors, animation: .default(duration: .milliseconds(150)))
					.hover {
						$0.color(.semantic(.primaryText))
							.background(.semantic(.matteHover))
					}
					.focusVisible { $0.declaration(.outline, "2px solid var(--accent)").declaration(.outlineOffset, "2px") }
			case .menuButton:
				Style()
					.hidden(from: .navLinks)
			case .progress:
				// Without scroll-driven animations, the line stays empty.
				Style()
					.position(.absolute)
					.declaration(.inset, "auto 0 -1px 0")
					.frame(height: .pixels(1))
					.background(.semantic(.accent))
					.declaration(.transformOrigin, "left")
					.declaration(.transform, "scaleX(0)")
					.animation(Animations.fill, timeline: .scroll, range: "normal")
					.reducedMotion { $0.declaration(.animation, .none) }
			case .drawer:
				// A popover, so it opens and closes without a script, and closes with Escape or a tap outside it. It slides in from the side.
				Style()
					.position(.fixed)
					.declaration(.inset, "0 0 0 auto")
					.frame(width: .min(.rootEm(18), .percent(85)), height: .percent(100))
					.declaration(.maxHeight, "none")
					.margin(0)
					.padding(0)
					.declaration(.border, "0")
					.border(.leading, .semantic(.separator))
					.background(.semantic(.pageBackground))
					.color(.semantic(.bodyText))
					.declaration(.transform, "translateX(100%)")
					.transition(.transform, .display, animation: .easeOut(duration: .milliseconds(300)))
					.popoverOpen {
						$0.declaration(.transform, "none")
							.startingStyle { $0.declaration(.transform, "translateX(100%)") }
					}
					.backdrop {
						$0.background(Color.black.opacity(0.4))
							.backdropFilter(.blur(radius: .pixels(6)))
					}
					.reducedMotion { $0.noTransition() }
			case .drawerHeader:
				Style()
					.hstack(alignment: .center, justification: .spaceBetween, spacing: .rootEm(1))
					.frame(minHeight: .rootEm(3.5))
					.padding(.horizontal, .rootEm(1.25))
					.border(.bottom, .semantic(.separator))
					.font(size: .rootEm(0.85))
			case .drawerLinks:
				Style()
					.padding(vertical: .rootEm(1.5), horizontal: .rootEm(1.25))
					.children("ul") { $0.vstack(spacing: .rootEm(0.25)) }
			case .drawerLink:
				Style()
					.display(.block)
					.padding(vertical: .rootEm(0.75), horizontal: .rootEm(0.5))
					.squircle(.rootEm(0.6))
					.font(size: .rootEm(1.05))
					.color(.semantic(.secondaryText))
					.before { $0.content("~/", alternativeText: "").opacity(0.4) }
					.hover {
						$0.declaration(.textDecoration, "none")
							.color(.semantic(.primaryText))
							.background(.semantic(.matteHover))
					}
					.nested("&[aria-current]") { $0.color(.semantic(.accent)) }
			}
		}
	}

	enum Animations: KeyframeSet {
		case fill

		var keyframes: [Keyframe] {
			[.to(Style().declaration(.transform, "scaleX(1)"))]
		}
	}

	/**
	Outline icons, 18 points, in the color of the text.
	*/
	private enum Icons {
		private static func icon(_ paths: String) -> String {
			#"<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">\#(paths)</svg>"#
		}

		// A circle, half filled, for light and dark.
		static let theme = icon(#"<circle cx="12" cy="12" r="8.5"/><path d="M12 3.5a8.5 8.5 0 0 0 0 17z" fill="currentColor"/>"#)
		static let menu = icon(#"<path d="M4 7h16M4 12h16M4 17h16"/>"#)
		static let close = icon(#"<path d="M6 6l12 12M18 6L6 18"/>"#)
	}
}

extension Breakpoint {
	/**
	Wide enough for the links in the bar. Below it, they are in the drawer.
	*/
	static let navLinks = Self(minimumWidthInRem: 60)
}
