import Elementary
import Foundation
import SiteKit

/**
The single page of the site: who I am, what I shipped, and how to reach me.
*/
struct HomePage: HTML {
	let posts: [BlogPost]

	var body: some HTML {
		SiteBackground()
		SiteNav()
		SiteCat()
		EmailToast()

		main {
			header(.id("top")) {
				p {
					span { "~ " }
						.style(Styles.muted)
					"$ whoami"
					span { "" }
						.accessibilityHidden()
						.style(Styles.cursor)
				}
				.style(Styles.prompt)

				h1 { Resume.name }
					.style(Styles.name)

				p {
					Resume.role + " "
					// The Apple logo is in the private use area, so only Apple devices show it. Screen readers skip it.
					span { "\u{F8FF}" }
						.accessibilityHidden()
					" · " + Resume.location
				}
				.style(Styles.muted)

				p { Resume.summary }
					.style(Styles.lead)

				ul {
					for link in Resume.links {
						li {
							ArrowLink(title: link.title, url: link.url.absoluteString)
						}
					}

					li {
						ArrowLink(title: "More about me", url: AboutPage.path.description, isExternal: false)
					}
				}
				.hstack(spacing: .rootEm(1.75))
				.style { $0.flexWrap() }

				// Where the cat sits until the page scrolls. `cat.js` stands it on the line.
				span(.data("cat-perch", value: "")) { "~/cat · pet me" }
					.accessibilityHidden()
					.style(Styles.perch)

				a(.href("#highlights")) {
					"Scroll"
					span { "↓" }
						.accessibilityHidden()
						.style(Styles.scrollArrow)
				}
				.style(Styles.scrollHint)
			}
			.style(Styles.hero)

			Section(number: 1, title: "Highlights", id: "highlights", fillsScreen: true) {
				ul {
					for highlight in Resume.highlights {
						li {
							StatValue(value: highlight.value)
							span { highlight.label }
								.style(Styles.small)
						}
						.style(Styles.stat)
					}
				}
				.style(Styles.stats)
			}

			if !posts.isEmpty {
				Section(number: 2, title: "Writing", id: "writing") {
					ul {
						for (index, post) in posts.enumerated() {
							li {
								PostCard(post: post, number: index + 1)
							}
							.style { $0.display(.grid) }
						}
					}
					.style(Styles.posts)
				}
			}

			Section(number: 3, title: "Experience", id: "experience") {
				div {
					for job in Resume.jobs {
						article {
							p { job.period }
								.style(Styles.small, Styles.period)

							div {
								h3 { job.company }
									.style(Styles.company)
								p { job.role }
									.style(Styles.muted)

								ul {
									for point in job.points {
										li { point }
											.style(Styles.point)
									}
								}
								.vstack(spacing: .rootEm(0.75))
								.style { $0.margin(vertical: .rootEm(1.25), horizontal: 0) }

								TagList(items: job.tech)
							}
						}
						.style(Styles.job)
					}
				}
				.vstack(spacing: .rootEm(4))
			}

			Section(number: 4, title: "Open Source & Talks", id: "open-source") {
				div {
					for project in Resume.projects {
						a(.href(project.url.absoluteString)) {
							span { "Open source" }
								.style(Styles.small, Styles.kicker)
							span {
								project.title + " "
								span(.data("arrow", value: "")) { "↗" }
									.accessibilityHidden()
									.style(Styles.arrow)
							}
							.style(Styles.rowTitle)
							span { project.description }
								.style(Styles.small)
						}
						.style(Styles.card, Styles.linkCard)
					}

					for talk in Resume.talks {
						div {
							span { "Talk · \(talk.date)" }
								.style(Styles.small, Styles.kicker)
							span { talk.title }
								.style(Styles.rowTitle)
							span { "\(talk.venue). \(talk.detail)" }
								.style(Styles.small)
						}
						.style(Styles.card)
					}
				}
				.style(Styles.cards)
			}

			Section(number: 5, title: "Skills", id: "skills") {
				div {
					for group in Resume.skills {
						div {
							h3 { group.title }
								.style(Styles.small, Styles.kicker)
							TagList(items: group.items)
						}
						.vstack(spacing: .rootEm(0.9))
					}

					div {
						h3 { "Education" }
							.style(Styles.small, Styles.kicker)
						p {
							span { Resume.education.school }
								.style(Styles.rowTitle)
							br()
							span { "\(Resume.education.degree), \(Resume.education.year)" }
								.style(Styles.small)
						}
					}
					.vstack(spacing: .rootEm(0.9))
				}
				.style(Styles.skills)
			}

			Section(number: 6, title: "Contact", id: "contact") {
				ContactPanel()
			}

			SiteFooter()
		}
		.style(Styles.root)
	}

	enum Styles: StyleSet {
		case root
		case hero
		case perch
		case scrollHint
		case scrollArrow
		case prompt
		case cursor
		case muted
		case name
		case lead
		case small
		case stats
		case stat
		case posts
		case rowTitle
		case arrow
		case job
		case period
		case company
		case point
		case cards
		case card
		case linkCard
		case kicker
		case skills

		var style: Style {
			switch self {
			case .root:
				Style()
					.frame(maxWidth: .pageWidth)
					.margin(vertical: 0, horizontal: .auto)
					.padding(top: 0, bottom: .rootEm(4))
					.padding(.horizontal, .pageGutter)
			case .hero:
				// The hero fills the first screen, with its content a quarter of the way down, and the page snaps gently between it and the highlights.
				Style()
					.vstack()
					.frame(minHeight: .smallViewportHeight(100) - .rootEm(3.5))
					.padding(top: .screenTop, bottom: .rootEm(4.5))
					.position(.relative)
					.declaration(.scrollSnapAlign, "start")
					.onPageRoot {
						$0.declaration(.scrollSnapType, "y proximity")
							.declaration(.scrollPaddingTop, "3.5rem")
					}
			case .perch:
				// A ledge on the empty side of the hero, on screens wide enough to have one.
				Style()
					.position(.absolute)
					.top(.percent(52))
					.declaration(.insetInlineEnd, "0")
					.frame(width: .rootEm(11))
					.padding(.top, .rootEm(0.6))
					.border(.top, .semantic(.separator))
					.font(size: .rootEm(0.7))
					.color(.semantic(.secondaryText))
					.textAlign(.center)
					.hidden(below: Breakpoint(minimumWidthInRem: 56))
			case .scrollHint:
				Style()
					.hidden(below: Breakpoint(minimumWidthInRem: 56))
					.position(.absolute)
					.declaration(.bottom, "2rem")
					.leading(0)
					.hstack(alignment: .center, spacing: .rootEm(0.5))
					.font(size: .rootEm(0.75))
					.declaration(.textTransform, "uppercase")
					.letterSpacing(.em(0.14))
					.color(.semantic(.secondaryText))
					.transition(.colors, animation: .default(duration: .milliseconds(150)))
					.hover { $0.declaration(.textDecoration, "none").color(.semantic(.primaryText)) }
			case .scrollArrow:
				Style()
					.display(.inlineBlock)
					.color(.semantic(.accent))
					.animation(Animations.drift, .easeInOut(duration: .milliseconds(1800)).repeatForever(autoreverses: true))
					.reducedMotion { $0.declaration(.animation, .none) }
			case .prompt:
				Style()
					.color(.semantic(.accent))
					.font(size: .rootEm(0.85))
					.margin(.bottom, .rootEm(1.5))
			case .cursor:
				// A thin block, like a terminal cursor, that blinks in steps instead of fading.
				Style()
					.display(.inlineBlock)
					.frame(width: .em(0.55), height: .em(1.1))
					.margin(.leading, .em(0.35))
					.declaration(.verticalAlign, "-0.2em")
					.background(.semantic(.accent))
					.animation(Animations.blink, .linear(duration: .milliseconds(1100)).repeatForever(autoreverses: false))
					.reducedMotion { $0.declaration(.animation, .none) }
			case .muted:
				Style()
					.color(.semantic(.secondaryText))
			case .name:
				Style()
					.fluidFontSize(fromRem: 2.4, toRem: 4.6, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 70))
					.lineHeight(1.1)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.045))
					.margin(.bottom, .rootEm(0.75))
			case .lead:
				Style()
					.frame(maxWidth: .rootEm(42))
					.font(size: .rootEm(1.12), lineHeight: 1.8)
					.margin(vertical: .rootEm(2.25), horizontal: 0)
			case .small:
				Style()
					.font(size: .rootEm(0.84), lineHeight: 1.7)
					.color(.semantic(.secondaryText))
			case .stats:
				// Two by two on phones, one row of four on wider screens.
				Style()
					.grid(columns: 2)
					.gap(row: .rootEm(3), column: .rootEm(2))
					.from(Breakpoint(minimumWidthInRem: 56)) { $0.grid(columns: 4).gap(.rootEm(3)) }
			case .stat:
				// A hairline above each number, green at the start, that fills with green on hover.
				Style()
					.vstack(spacing: .rootEm(0.6))
					.padding(.top, .rootEm(1.25))
					.position(.relative)
					.border(.top, .semantic(.separator))
					.before {
						$0.content("", alternativeText: "")
							.position(.absolute)
							.top(.pixels(-1))
							.leading(0)
							.frame(width: .rootEm(2.5), height: .pixels(1))
							.background(.semantic(.accent))
							.transition(TransitionProperty(.width), animation: .easeOut(duration: .milliseconds(400)))
					}
					.hover { $0.nested("&::before") { $0.frame(width: .percent(100)) } }
			case .posts:
				// The posts are the main thing to read here, so they get large cards, two across on wider screens.
				Style()
					.grid(columns: 1)
					.gap(.rootEm(1.25))
					.from(Breakpoint(minimumWidthInRem: 48)) { $0.grid(columns: 2) }
			case .rowTitle:
				Style()
					.fontWeight(.medium)
					.color(.semantic(.primaryText))
					.lineHeight(1.5)
			case .arrow:
				Style()
					.display(.inlineBlock)
					.color(.semantic(.secondaryText))
					.transition(.transform, .colors, animation: .easeOut(duration: .milliseconds(250)))
			case .job:
				Style()
					.grid(columns: "1fr")
					.gap(row: .rootEm(0.5), column: .rootEm(2))
					.from(Breakpoint(minimumWidthInRem: 40)) { $0.grid(columns: "12rem minmax(0, 46rem)") }
			case .period:
				Style()
					.padding(.top, .rootEm(0.2))
			case .company:
				Style()
					.font(size: .rootEm(1.15))
					.fontWeight(.medium)
					.margin(.bottom, .rootEm(0.25))
			case .point:
				Style()
					.padding(.leading, .rootEm(1.25))
					.position(.relative)
					.lineHeight(1.75)
					.before {
						$0.content("–", alternativeText: "")
							.position(.absolute)
							.leading(0)
							.color(.semantic(.secondaryText))
					}
			case .cards:
				Style()
					.grid(minimumColumnWidth: .rootEm(17))
					.gap(.rootEm(1))
			case .card:
				Style()
					.vstack(spacing: .rootEm(0.5))
					.padding(.rootEm(1.75))
					.squircle(.rootEm(1.5))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
			case .linkCard:
				Style()
					.color(.inherit)
					.transition(.colors, animation: .default(duration: .milliseconds(200)))
					.hover {
						$0.declaration(.textDecoration, "none")
							.background(.semantic(.matteHover))
							.declaration(.borderColor, "var(--secondary-text)")
							.nested("[data-arrow]") { $0.color(.semantic(.accent)).offset(x: .rootEm(0.15), y: .rootEm(-0.15)) }
					}
			case .kicker:
				Style()
					.font(size: .rootEm(0.75))
					.declaration(.textTransform, "uppercase")
					.letterSpacing(.em(0.12))
			case .skills:
				Style()
					.grid(minimumColumnWidth: .rootEm(14))
					.gap(row: .rootEm(2.5), column: .rootEm(2))
			}
		}
	}

	enum Animations: KeyframeSet {
		case blink
		case drift

		var keyframes: [Keyframe] {
			switch self {
			case .blink:
				[.at(50, Style().opacity(1)), .at(51, Style().opacity(0)), .to(Style().opacity(0))]
			case .drift:
				[.from(Style().offset(y: 0)), .to(Style().offset(y: .rootEm(0.3)))]
			}
		}
	}
}

/**
A titled section with a number like `01`, a hairline that fills the row, and content that rises in as it scrolls into view.
*/
struct Section<Content: HTML>: HTML {
	let number: Int
	let title: String
	let id: String
	var fillsScreen = false
	@HTMLBuilder let content: Content

	var body: some HTML<HTMLTag.section> {
		section(.id(id), .ariaLabelledBy("\(id)-title")) {
			h2(.id("\(id)-title")) {
				span { String(format: "%02d", number) }
					.accessibilityHidden()
					.style(SectionStyles.number)
				title
			}
			.style(SectionStyles.heading)

			content
		}
		.style(fillsScreen ? SectionStyles.screen : SectionStyles.root)
	}
}

// Outside `Section`: it is generic, and each specialization would generate the same class names.
enum SectionStyles: StyleSet {
	case root
	case screen
	case heading
	case number

	var style: Style {
		switch self {
		case .root:
			Style()
				.padding(.top, .rootEm(7))
				.reveal()
		case .screen:
			// A section that starts on a screen of its own, with its content a quarter of the way down like the hero. It stops short of a full screen, so the next section peeks in below.
			Style()
				.vstack()
				.frame(minHeight: .smallViewportHeight(72))
				.padding(top: .screenTop, bottom: .rootEm(4))
				.declaration(.scrollSnapAlign, "start")
				.reveal()
		case .heading:
			Style()
				.hstack(alignment: .center, spacing: .rootEm(1))
				.font(size: .rootEm(0.75))
				.fontWeight(.regular)
				.declaration(.textTransform, "uppercase")
				.letterSpacing(.em(0.14))
				.color(.semantic(.secondaryText))
				.margin(.bottom, .rootEm(2.75))
				.after {
					$0.content("", alternativeText: "")
						.declaration(.flex, "1")
						.border(.top, .semantic(.separator))
				}
		case .number:
			Style()
				.color(.semantic(.accent))
		}
	}
}

extension Length {
	/**
	The space above the content of a section that fills the screen, so the content starts a quarter of the way down, below the 3.5 rem bar.
	*/
	fileprivate static let screenTop: Self = .smallViewportHeight(25) - .rootEm(3.5)
}

extension Style {
	/**
	Fades the element in and up as it scrolls into view. Without scroll-driven animations, the element shows its last keyframe, so it is never left hidden.
	*/
	fileprivate func reveal() -> Self {
		animation(SectionAnimations.reveal, timeline: .scroll, range: "entry 0% entry 40%")
			.declaration(.animationTimeline, "view()")
			.reducedMotion { $0.declaration(.animation, .none) }
	}
}

enum SectionAnimations: KeyframeSet {
	case reveal

	var keyframes: [Keyframe] {
		[.from(Style().opacity(0).offset(y: .rootEm(1.5))), .to(Style().opacity(1).offset(y: 0))]
	}
}

/**
A text link with an arrow that moves on hover: ↗ for a link that leaves the site, → for a page on it.
*/
struct ArrowLink: HTML {
	let title: String
	let url: String
	var isExternal = true

	var body: some HTML<HTMLTag.a> {
		a(.href(url)) {
			title
			span(.data("arrow", value: "")) { isExternal ? "↗" : "→" }
				.accessibilityHidden()
				.style(Styles.arrow)
		}
		.style(Styles.root)
	}

	enum Styles: StyleSet {
		case root
		case arrow

		var style: Style {
			switch self {
			case .root:
				Style()
					.color(.semantic(.primaryText))
					.underline(color: .semantic(.separator), thickness: .pixels(1), offset: .em(0.35))
					.transition(.colors, animation: .default(duration: .milliseconds(200)))
					.hover {
						$0.declaration(.textDecorationColor, "var(--accent)")
							.nested("[data-arrow]") { $0.color(.semantic(.accent)).offset(x: .rootEm(0.12), y: .rootEm(-0.12)) }
					}
			case .arrow:
				Style()
					.display(.inlineBlock)
					.margin(.leading, .em(0.3))
					.color(.semantic(.secondaryText))
					.transition(.transform, .colors, animation: .easeOut(duration: .milliseconds(250)))
			}
		}
	}
}

/**
A post on the home page: a large matte card with its number, reading time, title, and summary. On hover, it lifts, its border turns green, and the arrow moves.
*/
struct PostCard: HTML {
	let post: BlogPost
	let number: Int

	var body: some HTML<HTMLTag.a> {
		a(.href(post.path)) {
			span {
				span { String(format: "[%02d]", number) }
					.style(Styles.number)
				span { "\(post.readingMinutes) min read" }
			}
			.hstack(justification: .spaceBetween, spacing: .rootEm(1))
			.style(Styles.meta)

			h3 { post.frontmatter.title }
				.style(Styles.title)

			p { post.frontmatter.description }
				.style(Styles.summary)

			span {
				span { post.formattedDate }
				span {
					"Read"
					span(.data("arrow", value: "")) { "→" }
						.accessibilityHidden()
						.style(Styles.arrow)
				}
				.style(Styles.read)
			}
			.hstack(alignment: .center, justification: .spaceBetween, spacing: .rootEm(1))
			.style(Styles.meta, Styles.footer)
		}
		.style(Styles.root)
	}

	enum Styles: StyleSet {
		case root
		case meta
		case number
		case title
		case summary
		case footer
		case read
		case arrow

		var style: Style {
			switch self {
			case .root:
				Style()
					.vstack(spacing: .rootEm(1.1))
					.frame(minHeight: .rootEm(19))
					.padding(.rootEm(2))
					.position(.relative)
					.overflow(.hidden)
					.squircle(.rootEm(1.5))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
					.color(.inherit)
					.transition(.colors, .transform, .shadow, animation: .easeOut(duration: .milliseconds(250)))
					.hover {
						$0.declaration(.textDecoration, "none")
							.background(.semantic(.matteHover))
							.declaration(.borderColor, "var(--accent)")
							.declaration(.boxShadow, "0 0 0 1px var(--accent)")
							.declaration(.transform, "translateY(-3px)")
							.nested("[data-arrow]") { $0.offset(x: .rootEm(0.35)) }
					}
					.focusVisible { $0.declaration(.borderColor, "var(--accent)") }
					.reducedMotion { $0.hover { $0.declaration(.transform, "none") } }
			case .meta:
				Style()
					.font(size: .rootEm(0.8))
					.color(.semantic(.secondaryText))
			case .number:
				Style()
					.color(.semantic(.accent))
			case .title:
				Style()
					.fluidFontSize(fromRem: 1.3, toRem: 1.7, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 70))
					.lineHeight(1.3)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.025))
					.color(.semantic(.primaryText))
			case .summary:
				Style()
					.font(size: .rootEm(0.9), lineHeight: 1.75)
					.color(.semantic(.secondaryText))
			case .footer:
				// Pushed to the bottom, so the footers of cards side by side line up.
				Style()
					.margin(.top, .auto)
					.padding(.top, .rootEm(1.1))
					.border(.top, .semantic(.separator))
			case .read:
				Style()
					.color(.semantic(.accent))
					.fontWeight(.medium)
			case .arrow:
				Style()
					.display(.inlineBlock)
					.margin(.leading, .em(0.5))
					.transition(.transform, animation: .easeOut(duration: .milliseconds(250)))
			}
		}
	}
}

/**
A number like `20,000+`, with its sign and unit in green.
*/
struct StatValue: HTML {
	let value: String

	private var parts: (prefix: Substring, number: Substring, suffix: Substring) {
		let isNumeric: (Character) -> Bool = { $0.isNumber || $0 == "," || $0 == "." }
		let prefix = value.prefix { !isNumeric($0) }
		let rest = value.dropFirst(prefix.count)
		let number = rest.prefix(while: isNumeric)
		return (prefix, number, rest.dropFirst(number.count))
	}

	var body: some HTML<HTMLTag.span> {
		span {
			span { String(parts.prefix) }
				.style(Styles.unit)
			String(parts.number)
			span { String(parts.suffix) }
				.style(Styles.unit)
		}
		.style(Styles.root)
	}

	enum Styles: StyleSet {
		case root
		case unit

		var style: Style {
			switch self {
			case .root:
				Style()
					.fluidFontSize(fromRem: 1.6, toRem: 3, between: Breakpoint(minimumWidthInRem: 24), and: Breakpoint(minimumWidthInRem: 70))
					.lineHeight(1)
					.fontWeight(.medium)
					.letterSpacing(.em(-0.04))
					.color(.semantic(.primaryText))
					.monospacedDigit()
			case .unit:
				Style()
					.color(.semantic(.accent))
			}
		}
	}
}

/**
A row of small labels, like the technologies of a job.
*/
struct TagList: HTML {
	let items: [String]

	var body: some HTML<HTMLTag.ul> {
		ul {
			for item in items {
				li { item }
					.style(Styles.tag)
			}
		}
		.hstack(spacing: .rootEm(0.45))
		.style { $0.flexWrap() }
	}

	enum Styles: StyleSet {
		case tag

		var style: Style {
			Style()
				.padding(vertical: .rootEm(0.2), horizontal: .rootEm(0.65))
				.squircle(.rootEm(0.55))
				.background(.semantic(.card))
				.border(.semantic(.separator))
				.font(size: .rootEm(0.75))
				.color(.semantic(.secondaryText))
		}
	}
}
