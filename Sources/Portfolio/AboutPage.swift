import Elementary
import Foundation
import SiteKit

/**
The about page, `/about`: `whoami` with a few facts and my photo, then the longer version in my own words.
*/
struct AboutPage: HTML {
	static let path: RoutePath = "/about"

	var body: some HTML {
		SiteBackground()
		SiteNav(current: "about")
		SiteCat()

		main {
			header {
				div {
					p {
						span { "~ / " }
							.style(Styles.dim)
						"about"
					}
					.style(Styles.breadcrumb)

					h1 {
						span { "$ " }
							.accessibilityHidden()
							.style(Styles.dim)
						"whoami"
					}
					.style(Styles.title)

					p {
						Resume.name + " · "
						a(.href(Resume.links[0].url.absoluteString)) { Resume.handle }
					}
					.style(Styles.byline)

					p {
						span { Resume.aboutLead.emphasis }
							.style(Styles.accent)
						Resume.aboutLead.rest
					}
					.style(Styles.lead)

					dl {
						for fact in Resume.facts {
							div {
								dt {
									span { "→" }
										.accessibilityHidden()
										.style(Styles.dim)
									fact.label
								}
								dd {
									fact.value
									if let note = fact.note {
										span { " // \(note)" }
											.style(Styles.accent)
									}
								}
							}
							.style(Styles.fact)
						}
					}
					.style(Styles.facts)
				}

				figure {
					span { "★ irl" }
						.accessibilityHidden()
						.style(Styles.badge)

					img(.src("/images/devansh.jpg"), .alt("Devansh Mohata, smiling with arms crossed, in front of green hills"), .width(900), .height(1125), .custom(name: "decoding", value: "async"))
						.style(Styles.photo)

					figcaption { "~/me.jpg" }
						.style(Styles.caption)
				}
				.style(Styles.frame)
			}
			.style(Styles.intro)

			for (index, topic) in Resume.about.enumerated() {
				Section(number: index + 1, title: index == 0 ? "The longer version" : "Off the clock", id: index == 0 ? "longer-version" : "off-the-clock") {
					h2 { topic.title }
						.style(Styles.heading)

					div {
						for paragraph in topic.paragraphs {
							p { paragraph }
						}
					}
					.style(Styles.story)
				}
			}

			SiteFooter()
		}
		.style(HomePage.Styles.root)
	}

	enum Styles: StyleSet {
		case intro
		case breadcrumb
		case dim
		case accent
		case title
		case byline
		case lead
		case facts
		case fact
		case frame
		case badge
		case photo
		case caption
		case heading
		case story

		var style: Style {
			switch self {
			case .intro:
				// The facts on the left and my photo on the right, on screens wide enough for both.
				Style()
					.grid(columns: 1)
					.gap(.rootEm(3.5))
					.padding(top: .rootEm(5), bottom: .rootEm(2))
					.from(Breakpoint(minimumWidthInRem: 56)) {
						$0.grid(columns: "minmax(0, 1fr) minmax(0, 0.7fr)")
							.gap(.rootEm(5))
							.declaration(.alignItems, "center")
					}
			case .breadcrumb:
				Style()
					.font(size: .rootEm(0.8))
					.color(.semantic(.primaryText))
					.margin(.bottom, .rootEm(1.25))
			case .dim:
				Style()
					.color(.semantic(.secondaryText))
			case .accent:
				Style()
					.color(.semantic(.accent))
			case .title:
				Style()
					.fluidFontSize(fromRem: 2.6, toRem: 4.6, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 70))
					.lineHeight(1.05)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.045))
			case .byline:
				Style()
					.margin(top: .rootEm(0.9), bottom: .rootEm(1.75))
					.font(size: .rootEm(0.9))
					.color(.semantic(.secondaryText))
			case .lead:
				Style()
					.frame(maxWidth: .rootEm(36))
					.font(size: .rootEm(1.12), lineHeight: 1.75)
					.color(.semantic(.primaryText))
					.margin(.bottom, .rootEm(2.25))
			case .facts:
				Style()
					.frame(maxWidth: .rootEm(36))
					.border(.top, .semantic(.separator))
			case .fact:
				// Like a listing in a terminal: an arrow and a label, then the value.
				Style()
					.grid(columns: "9.5rem 1fr")
					.gap(.rootEm(1))
					.padding(.vertical, .rootEm(0.8))
					.border(.bottom, .semantic(.separator))
					.font(size: .rootEm(0.85))
					.children("dt") { $0.color(.semantic(.secondaryText)).nested("span") { $0.margin(.trailing, .rootEm(0.6)) } }
					.children("dd") { $0.color(.semantic(.primaryText)) }
			case .frame:
				// The photo in a frame with green corners and a soft green glow, like a window on the desktop.
				Style()
					.position(.relative)
					.frame(width: .percent(100), maxWidth: .rootEm(24))
					.padding(.rootEm(0.65))
					.squircle(.rootEm(1.5))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
					.declaration(.boxShadow, "0 0 4rem -1.5rem var(--accent)")
					.from(Breakpoint(minimumWidthInRem: 56)) { $0.declaration(.justifySelf, "end") }
					.before {
						$0.content("", alternativeText: "")
							.position(.absolute)
							.declaration(.inset, "-0.4rem auto auto -0.4rem")
							.frame(width: .rootEm(1.1), height: .rootEm(1.1))
							.border(.top, .semantic(.accent), width: .pixels(2))
							.border(.leading, .semantic(.accent), width: .pixels(2))
					}
					.after {
						$0.content("", alternativeText: "")
							.position(.absolute)
							.declaration(.inset, "auto -0.4rem -0.4rem auto")
							.frame(width: .rootEm(1.1), height: .rootEm(1.1))
							.border(.bottom, .semantic(.accent), width: .pixels(2))
							.border(.trailing, .semantic(.accent), width: .pixels(2))
					}
			case .badge:
				Style()
					.position(.absolute)
					.declaration(.inset, "-0.85rem -0.85rem auto auto")
					.zIndex(1)
					.padding(vertical: .rootEm(0.3), horizontal: .rootEm(0.8))
					.cornerRadius(.rootEm(2))
					.background(.semantic(.accent))
					.color(.semantic(.pageBackground))
					.font(size: .rootEm(0.72))
					.fontWeight(.medium)
					.declaration(.boxShadow, "0 0 1.5rem -0.25rem var(--accent)")
			case .photo:
				Style()
					.display(.block)
					.frame(width: .percent(100), height: .auto)
					.declaration(.aspectRatio, "4 / 5")
					.declaration(.objectFit, "cover")
					.squircle(.rootEm(1))
			case .caption:
				Style()
					.padding(top: .rootEm(0.6), bottom: .rootEm(0.1))
					.font(size: .rootEm(0.72))
					.color(.semantic(.secondaryText))
					.before { $0.content("● ", alternativeText: "").color(.semantic(.accent)) }
			case .heading:
				Style()
					.fluidFontSize(fromRem: 1.8, toRem: 2.8, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 70))
					.lineHeight(1.15)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.04))
					.margin(.bottom, .rootEm(2))
			case .story:
				// Two columns on wide screens, starting with a large green letter, like the first page of a chapter.
				Style()
					.columns(2, minimumWidth: .rootEm(22))
					.declaration(.columnGap, "4rem")
					.font(size: .rootEm(0.95), lineHeight: 1.85)
					.color(.semantic(.bodyText))
					.children("p") { $0.margin(.bottom, .rootEm(1.25)).keepsTogether() }
					.nested("& > p:first-child::first-letter") {
						$0.declaration(.float, "left")
							.font(size: .em(3.1), lineHeight: 0.9)
							.margin(top: .em(0.05), bottom: 0)
							.margin(.trailing, .em(0.12))
							.fontWeight(.medium)
							.color(.semantic(.accent))
					}
			}
		}
	}
}
