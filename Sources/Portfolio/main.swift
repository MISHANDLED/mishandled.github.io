import Elementary
import Foundation
import SiteKit

// `swift run Portfolio` builds to `dist`. `swift run Portfolio serve` also serves it and rebuilds on changes to `content` and `public`. A change in `Sources` needs a restart.

let siteURL = #URL("https://mishandled.github.io")
let project = Project(root: URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory))
let output = project.root.appending(path: "dist")

struct Layout: HTMLDocument {
	let title: String
	let description: String
	let path: RoutePath
	let bodyHTML: String
	let resources: PageResources

	var lang: String {
		"en"
	}

	var head: some HTML {
		meta(.name(.viewport), .content("width=device-width, initial-scale=1"))
		meta(.name(.description), .content(description))
		meta(.name("color-scheme"), .content("light dark"))
		meta(.property("og:title"), .content(title))
		meta(.property("og:description"), .content(description))
		link(.rel(.canonical), .href(path.absoluteURL(site: siteURL).absoluteString))
		link(.rel(.icon), .href("/favicon.svg"))
		link(.rel(.stylesheet), .href(Stylesheet.sitePath))

		// Only the rules of the components this page uses.
		Elementary.style {
			HTMLRaw(Stylesheet {
				Layer(.components) {
					resources.styleNodes
				}

				Layer(.elements) {
					resources.elementStyleNodes
				}
			}.css)
		}
	}

	var body: some HTML {
		HTMLRaw(bodyHTML)
	}
}

/**
A page in the layout. The body renders first and collects the styles it uses, so the page gets only those.
*/
func page(_ path: RoutePath, title: String, description: String, body: @escaping @Sendable () -> some HTML) -> Route {
	.page(path) {
		let resources = PageResources(sharedStylesheet: .site)
		let bodyHTML = try resources.collect {
			body().render()
		}

		return Layout(title: title, description: description, path: path, bodyHTML: bodyHTML, resources: resources).render()
	}
}

/**
Every published file.
*/
func routes() throws -> [Route] {
	let posts = try BlogPost.loadAll(from: project)

	return [
		page(.root, title: "\(Resume.name) · \(Resume.role)", description: Resume.summary) {
			HomePage(posts: posts)
		},
		.text(Stylesheet.sitePath) {
			Stylesheet.site.css
		},
	] + posts.map { post in
		page(post.path, title: "\(post.frontmatter.title) · \(Resume.name)", description: post.frontmatter.description) {
			BlogPostPage(post: post)
		}
	}
}

func build() async throws -> Bool {
	let routes = try routes()
	let files = try await Publisher(site: siteURL, project: project, output: output).publish(routes)
	let brokenLinks = try await LinkValidator(site: siteURL, output: output).brokenLinks(in: routes, files: files)
	print("Published \(routes.count) routes to \(output.path(percentEncoded: false)).")

	for link in brokenLinks {
		print("Broken link: \(link)")
	}

	return brokenLinks.isEmpty
}

if CommandLine.arguments.dropFirst().first == "serve" {
	let server = PreviewServer(directory: output, port: 4321, reloadsPages: true)
	_ = try await build()

	try await withThrowingTaskGroup { group in
		group.addTask {
			try await server.run { print("Serving at http://127.0.0.1:\($0)") }
		}

		group.addTask {
			for await _ in DirectoryWatcher(directories: [project.contentDirectory, project.publicDirectory]) {
				do {
					_ = try await build()
					server.show(error: nil)
				} catch {
					server.show(error: "\(error)")
				}

				server.reload()
			}
		}

		try await group.waitForAll()
	}
} else if try await !build() {
	exit(1)
}
