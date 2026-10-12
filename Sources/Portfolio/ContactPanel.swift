import Elementary
import Foundation
import SiteKit

/**
The end of the home page: how to reach me, a few facts, and the other places I am on. `contact.js` adds the copy button and the local time.
*/
struct ContactPanel: HTML {
	private var channels: [ProfileLink] {
		Resume.links.filter { $0.url.scheme != "mailto" }
	}

	var body: some HTML {
		div {
			div {
				h3 { "Let's talk." }
					.style(Styles.title)

				p { "I'm open to conversations about iOS, app performance, and media playback. Email is the quickest way to reach me." }
					.style(Styles.text)

				div {
					a(.href("mailto:\(Resume.email)")) {
						"Email me"
						span { "→" }
							.accessibilityHidden()
					}
					.style(Styles.button, Styles.primary)

					button(.type(.button), .hidden, .data("copy", value: Resume.email)) { "Copy address" }
						.style(Styles.button, Styles.secondary)
				}
				.hstack(spacing: .rootEm(0.75))
				.style { $0.flexWrap() }
			}

			dl {
				Fact(term: "Location", value: Resume.location)

				div {
					dt { "Local time" }
					dd {
						span(.data("clock", value: "Asia/Kolkata")) { "IST, UTC+5:30" }
					}
				}
				.style(Styles.fact)

				Fact(term: "Currently", value: Resume.jobs.first.map { "\(Resume.role) at \($0.company)" } ?? Resume.role)
				Fact(term: "Email", value: Resume.email)
			}
			.style(Styles.facts)
		}
		.style(Styles.panel)

		ul {
			for channel in channels {
				li {
					a(.href(channel.url.absoluteString)) {
						span { channel.title }
							.style(Styles.channelTitle)
						span(.data("arrow", value: "")) { "↗" }
							.accessibilityHidden()
							.style(Styles.channelArrow)
						span { Self.handle(of: channel.url) }
							.style(Styles.channelHandle)
					}
					.style(Styles.channel)
				}
			}
		}
		.style(Styles.channels)

		script(.type(.module), .src("/scripts/contact.js")) {}
	}

	/**
	A short form of the address, like `github.com/mishandled`, or the file name for a link on this site.
	*/
	private static func handle(of url: URL) -> String {
		guard let host = url.host() else {
			return url.lastPathComponent
		}

		return host.replacing("www.", with: "") + url.path()
	}

	struct Fact: HTML {
		let term: String
		let value: String

		var body: some HTML<HTMLTag.div> {
			div {
				dt { term }
				dd { value }
			}
			.style(Styles.fact)
		}
	}

	enum Styles: StyleSet {
		case panel
		case title
		case text
		case button
		case primary
		case secondary
		case facts
		case fact
		case channels
		case channel
		case channelTitle
		case channelHandle
		case channelArrow

		var style: Style {
			switch self {
			case .panel:
				Style()
					.grid(columns: "1fr")
					.gap(.rootEm(2.5))
					.padding(.rootEm(2))
					.squircle(.rootEm(1.5))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
					.from(Breakpoint(minimumWidthInRem: 48)) { $0.grid(columns: "1.3fr 1fr").gap(.rootEm(3.5)).padding(.rootEm(2.75)) }
			case .title:
				Style()
					.fluidFontSize(fromRem: 1.8, toRem: 2.6, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 60))
					.lineHeight(1.1)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.04))
			case .text:
				Style()
					.frame(maxWidth: .rootEm(30))
					.margin(top: .rootEm(1), bottom: .rootEm(2))
					.font(size: .rootEm(0.9), lineHeight: 1.8)
					.color(.semantic(.secondaryText))
			case .button:
				Style()
					.hstack(alignment: .center, spacing: .rootEm(0.6))
					.padding(vertical: .rootEm(0.75), horizontal: .rootEm(1.25))
					.squircle(.rootEm(0.8))
					.border(.semantic(.separator))
					.font(size: .rootEm(0.85))
					.declaration(.fontFamily, "inherit")
					.cursor(.pointer)
					.transition(.colors, animation: .default(duration: .milliseconds(150)))
					.hover { $0.declaration(.textDecoration, "none") }
			case .primary:
				// The one solid button on the page, black on white or white on black.
				Style()
					.background(.semantic(.primaryText))
					.color(.semantic(.pageBackground))
					.declaration(.borderColor, "var(--primary-text)")
					.fontWeight(.medium)
					.hover { $0.background(.semantic(.accent)).declaration(.borderColor, "var(--accent)") }
			case .secondary:
				Style()
					.background(.transparent)
					.color(.semantic(.primaryText))
					.hover { $0.background(.semantic(.matteHover)) }
			case .facts:
				Style()
					.vstack(spacing: 0)
					.declaration(.alignSelf, "center")
			case .fact:
				Style()
					.hstack(justification: .spaceBetween, spacing: .rootEm(1))
					.padding(.vertical, .rootEm(0.85))
					.border(.bottom, .semantic(.separator))
					.font(size: .rootEm(0.84))
					.lastChild { $0.declaration(.borderBottomWidth, "0") }
					.children("dt") { $0.color(.semantic(.secondaryText)) }
					.children("dd") { $0.color(.semantic(.primaryText)).textAlign(.trailing).monospacedDigit() }
			case .channels:
				Style()
					.grid(columns: 1)
					.gap(.rootEm(1))
					.from(Breakpoint(minimumWidthInRem: 48)) { $0.grid(columns: 3) }
					.margin(.top, .rootEm(1))
			case .channel:
				Style()
					.grid(columns: "1fr auto")
					.gap(row: .rootEm(0.3), column: .rootEm(1))
					.padding(vertical: .rootEm(1.25), horizontal: .rootEm(1.5))
					.squircle(.rootEm(1.25))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
					.color(.inherit)
					.transition(.colors, animation: .default(duration: .milliseconds(200)))
					.hover {
						$0.declaration(.textDecoration, "none")
							.background(.semantic(.matteHover))
							.declaration(.borderColor, "var(--secondary-text)")
							.nested("[data-arrow]") { $0.color(.semantic(.accent)).offset(x: .rootEm(0.15), y: .rootEm(-0.15)) }
					}
			case .channelTitle:
				Style()
					.fontWeight(.medium)
					.color(.semantic(.primaryText))
			case .channelHandle:
				Style()
					.declaration(.gridColumn, "1 / -1")
					.font(size: .rootEm(0.8))
					.color(.semantic(.secondaryText))
					.overflowWrap(.anywhere)
			case .channelArrow:
				Style()
					.color(.semantic(.secondaryText))
					.transition(.transform, .colors, animation: .easeOut(duration: .milliseconds(250)))
			}
		}
	}
}
