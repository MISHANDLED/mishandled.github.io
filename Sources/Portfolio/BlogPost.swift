import Elementary
import Foundation
import SiteKit

@Frontmatter
struct PostFrontmatter {
	@NonEmpty var title: String
	@NonEmpty var description: String

	@CalendarDay var publicationDate: Date

	var isDraft = false
}

/**
A post, loaded from `content/blog/<slug>.md`. Its page is `/blog/<slug>`.
*/
struct BlogPost: Sendable {
	let frontmatter: PostFrontmatter
	let markdown: MarkdownDocument
	let path: RoutePath

	/**
	Minutes to read the post, at about 200 words a minute, code included.
	*/
	let readingMinutes: Int

	static func loadAll(from project: Project) throws -> [Self] {
		let directory = project.contentDirectory.appending(path: "blog")

		guard directory.isDirectory else {
			return []
		}

		return try directory.filesRecursively()
			.filter { $0.pathExtension == "md" }
			.map { url in
				let file = try MarkdownFile(url: url, relativeTo: directory)
				let markdown = MarkdownDocument(parsing: file.body, options: MarkdownDocument.Options())

				if let problem = markdown.problems.first {
					throw ContentError(file: url, line: problem.line.map { $0 + file.bodyStartLine - 1 }, reason: problem.message)
				}

				return Self(
					frontmatter: try file.decodeFrontmatter(),
					markdown: markdown,
					path: RoutePath("/blog").appending(file.slug),
					readingMinutes: max(1, Int((Double(file.body.split(whereSeparator: \.isWhitespace).count) / 200).rounded(.up)))
				)
			}
			.filter { !$0.frontmatter.isDraft }
			.sorted { $0.frontmatter.publicationDate > $1.frontmatter.publicationDate }
	}

	var formattedDate: String {
		frontmatter.publicationDate.formatted(Date.FormatStyle(date: .long, time: .omitted, locale: Locale(identifier: "en_US"), timeZone: .gmt))
	}
}

struct BlogPostPage: HTML {
	let post: BlogPost

	var body: some HTML {
		SiteBackground()
		SiteNav(current: "writing")
		SiteCat()

		main {
			article {
				header {
					h1 { post.frontmatter.title }
						.style(Styles.title)

					p {
						post.formattedDate
					}
					.style(Styles.date)
				}
				.style(Styles.header)

				div {
					HTMLRaw(post.markdown.html)
				}
				.style(Styles.prose)
			}

			SiteFooter()
		}
		.style(HomePage.Styles.root)
	}

	enum Styles: StyleSet {
		case header
		case title
		case date
		case prose

		var style: Style {
			switch self {
			// The bar at the top leads back, so the post starts with its title.
			case .header:
				Style()
					.padding(.top, .rootEm(5))
			case .title:
				Style()
					.font(size: .rootEm(2), lineHeight: 1.2)
					.letterSpacing(.em(-0.03))
			case .date:
				Style()
					.margin(top: .rootEm(0.6), bottom: .rootEm(2.5))
					.color(.semantic(.secondaryText))
			case .prose:
				// Markdown output has no classes, so the typography styles its elements.
				Style()
					.font(size: .rootEm(1), lineHeight: 1.75)
					.margin(.bottom, .rootEm(3.5))
					.nested("> * + *") { $0.margin(.top, .rootEm(1.1)) }
					.nested("h2") { $0.font(size: .rootEm(1.45)).margin(.top, .rootEm(2.4)) }
					.nested("h3") { $0.font(size: .rootEm(1.15)).margin(.top, .rootEm(1.8)) }
					.nested("ul, ol") { $0.padding(.leading, .rootEm(1.3)) }
					.nested("ul") { $0.declaration(.listStyle, "disc") }
					.nested("ol") { $0.declaration(.listStyle, "decimal") }
					.nested("li + li") { $0.margin(.top, .rootEm(0.35)) }
					.nested("strong") { $0.color(.semantic(.primaryText)) }
					.nested("a") { $0.declaration(.textDecoration, "underline") }
					.nested(":not(pre) > code") {
						$0.font(size: .em(0.88))
							.padding(vertical: .em(0.1), horizontal: .em(0.35))
							.color(.semantic(.accent))
							.squircle(.rootEm(0.4))
							.background(.semantic(.card))
					}
					.nested("pre") {
						$0.padding(.rootEm(1))
							.squircle(.rootEm(1))
							.border(.semantic(.separator))
							.background(.semantic(.card))
							.overflow(.auto)
							.font(size: .rootEm(0.86), lineHeight: 1.55)
					}
					.nested("code") { $0.fontFamily("inherit") }
					.nested("table") {
						$0.frame(width: .percent(100))
							.declaration(.borderCollapse, "collapse")
							.font(size: .rootEm(0.92))
					}
					.nested("th, td") {
						$0.padding(vertical: .rootEm(0.5), horizontal: .rootEm(0.6))
							.border(.bottom, .semantic(.separator))
							.textAlign(.leading)
					}
					.nested("th") { $0.color(.semantic(.primaryText)) }
					.nested("blockquote") {
						$0.padding(.leading, .rootEm(1))
							.border(.leading, .semantic(.accent), width: .pixels(3))
							.color(.semantic(.secondaryText))
					}
			}
		}
	}
}
