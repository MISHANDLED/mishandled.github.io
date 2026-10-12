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

		main {
			header {
				p {
					Resume.role + " "
					// The Apple logo is in the private use area, so only Apple devices show it. Screen readers skip it.
					span { "\u{F8FF}" }
						.accessibilityHidden()
					" · " + Resume.location
				}
					.style(Styles.eyebrow)

				h1 { Resume.name }
					.style(Styles.name)

				p { Resume.summary }
					.style(Styles.lead)

				ul {
					for link in Resume.links {
						li {
							a(.href(link.url.absoluteString)) { link.title }
								.style(Styles.chip)
						}
					}
				}
				.hstack(spacing: .rootEm(0.5))
				.style { $0.flexWrap() }
			}
			.style(Styles.section)

			section(.id("highlights"), .ariaLabelledBy("highlights-title")) {
				h2(.id("highlights-title")) { "Highlights" }
					.style(Styles.heading)

				ul {
					for highlight in Resume.highlights {
						li {
							span { highlight.value }
								.style(Styles.statValue)
							span { highlight.label }
								.style(Styles.statLabel)
						}
						.style(Styles.card)
					}
				}
				.style(Styles.grid)
			}
			.style(Styles.section)

			if !posts.isEmpty {
				section(.id("writing"), .ariaLabelledBy("writing-title")) {
					h2(.id("writing-title")) { "Writing" }
						.style(Styles.heading)

					div {
						for post in posts {
							a(.href(post.path)) {
								span { post.frontmatter.title }
									.style(Styles.cardTitle)
								span { post.frontmatter.description }
									.style(Styles.statLabel)
								span { post.formattedDate }
									.style(Styles.statLabel)
							}
							.style(Styles.card, Styles.linkCard)
						}
					}
					.vstack(spacing: .rootEm(0.75))
				}
				.style(Styles.section)
			}

			section(.id("experience"), .ariaLabelledBy("experience-title")) {
				h2(.id("experience-title")) { "Experience" }
					.style(Styles.heading)

				for job in Resume.jobs {
					article {
						div {
							h3 { job.company }
								.style(Styles.company)
							span { job.period }
								.style(Styles.meta)
						}
						.hstack(alignment: .baseline, justification: .spaceBetween, spacing: .rootEm(1))
						.style { $0.flexWrap() }

						p { job.role }
							.style(Styles.meta)

						ul {
							for point in job.points {
								li { point }
									.style(Styles.point)
							}
						}
						.vstack(spacing: .rootEm(0.4))
						.style { $0.margin(.vertical, .rootEm(0.75)) }

						TagList(items: job.tech)
					}
					.style(Styles.job)
				}
			}
			.style(Styles.section)

			section(.id("open-source"), .ariaLabelledBy("open-source-title")) {
				h2(.id("open-source-title")) { "Open Source & Talks" }
					.style(Styles.heading)

				div {
					for project in Resume.projects {
						a(.href(project.url.absoluteString)) {
							span { project.title }
								.style(Styles.cardTitle)
							span { project.description }
								.style(Styles.statLabel)
						}
						.style(Styles.card, Styles.linkCard)
					}

					for talk in Resume.talks {
						div {
							span { talk.title }
								.style(Styles.cardTitle)
							span { "\(talk.venue), \(talk.date). \(talk.detail)" }
								.style(Styles.statLabel)
						}
						.style(Styles.card)
					}
				}
				.style(Styles.grid, Styles.wideGrid)
			}
			.style(Styles.section)

			section(.id("skills"), .ariaLabelledBy("skills-title")) {
				h2(.id("skills-title")) { "Skills" }
					.style(Styles.heading)

				div {
					for group in Resume.skills {
						div {
							h3 { group.title }
								.style(Styles.meta)
							TagList(items: group.items)
						}
						.vstack(spacing: .rootEm(0.5))
					}
				}
				.vstack(spacing: .rootEm(1.25))
			}
			.style(Styles.section)

			section(.id("education"), .ariaLabelledBy("education-title")) {
				h2(.id("education-title")) { "Education" }
					.style(Styles.heading)

				p {
					strong { Resume.education.school }
					br()
					"\(Resume.education.degree), \(Resume.education.year)"
				}
			}
			.style(Styles.section)

			SiteFooter()
		}
		.style(Styles.root)
	}

	enum Styles: StyleSet {
		case root
		case section
		case eyebrow
		case name
		case lead
		case chip
		case heading
		case grid
		case wideGrid
		case card
		case linkCard
		case cardTitle
		case statValue
		case statLabel
		case job
		case company
		case meta
		case point

		var style: Style {
			switch self {
			case .root:
				Style()
					.frame(maxWidth: .rootEm(46))
					.margin(vertical: 0, horizontal: .auto)
					.padding(vertical: .rootEm(4), horizontal: .rootEm(1))
			case .section:
				Style()
					.margin(.bottom, .rootEm(3.5))
			case .eyebrow:
				Style()
					.color(.semantic(.accent))
					.fontWeight(.semibold)
					.font(size: .rootEm(0.9))
			case .name:
				Style()
					.font(size: .rootEm(3), lineHeight: 1.05)
					.letterSpacing(.em(-0.03))
					.margin(vertical: .rootEm(0.4), horizontal: 0)
			case .lead:
				Style()
					.font(size: .rootEm(1.15))
					.margin(.bottom, .rootEm(1.5))
			case .chip:
				Style()
					.display(.inlineBlock)
					.padding(vertical: .rootEm(0.4), horizontal: .rootEm(0.9))
					.cornerRadius(.rootEm(2))
					.background(.semantic(.card))
					.fontWeight(.medium)
			case .heading:
				Style()
					.font(size: .rootEm(0.8))
					.declaration(.textTransform, "uppercase")
					.letterSpacing(.em(0.08))
					.color(.semantic(.secondaryText))
					.margin(.bottom, .rootEm(1.25))
			case .grid:
				Style()
					.grid(minimumColumnWidth: .rootEm(9.5))
					.gap(.rootEm(0.75))
			case .wideGrid:
				Style()
					.grid(minimumColumnWidth: .rootEm(17))
			case .card:
				Style()
					.vstack(spacing: .rootEm(0.35))
					.padding(.rootEm(1.1))
					.cornerRadius(.rootEm(0.9))
					.background(.semantic(.card))
			case .linkCard:
				Style()
					.color(.inherit)
					.hover { $0.declaration(.textDecoration, "none").background(Color.semantic(.accent).opacity(0.1)) }
			case .cardTitle:
				Style()
					.fontWeight(.semibold)
					.color(.semantic(.primaryText))
			case .statValue:
				Style()
					.font(size: .rootEm(1.9), lineHeight: 1)
					.fontWeight(.bold)
					.color(.semantic(.primaryText))
					.monospacedDigit()
			case .statLabel:
				Style()
					.font(size: .rootEm(0.92), lineHeight: 1.45)
					.color(.semantic(.secondaryText))
			case .job:
				Style()
					.padding(.vertical, .rootEm(1.25))
					.border(.top, .semantic(.separator))
			case .company:
				Style()
					.font(size: .rootEm(1.25))
			case .meta:
				Style()
					.font(size: .rootEm(0.92))
					.color(.semantic(.secondaryText))
			case .point:
				Style()
					.padding(.leading, .rootEm(1))
					.position(.relative)
					.before {
						$0.content("–", alternativeText: "")
							.position(.absolute)
							.leading(0)
							.color(.semantic(.accent))
					}
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
		.hstack(spacing: .rootEm(0.4))
		.style { $0.flexWrap() }
	}

	enum Styles: StyleSet {
		case tag

		var style: Style {
			Style()
				.padding(vertical: .rootEm(0.15), horizontal: .rootEm(0.6))
				.cornerRadius(.rootEm(0.4))
				.border(.semantic(.separator))
				.font(size: .rootEm(0.8))
				.color(.semantic(.secondaryText))
		}
	}
}
