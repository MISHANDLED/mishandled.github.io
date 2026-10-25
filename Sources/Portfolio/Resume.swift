import Foundation
import SiteKit

/**
The content of the site, from the résumé. Typed, so a missing field fails the build.
*/
enum Resume {
	static let name = "Devansh Mohata"
	static let role = "iOS Engineer, SDE III"
	static let location = "Gurugram, India"
	static let email = "devmoh08@gmail.com"

	static let summary = "SDE III at Zomato. iOS engineer with 4 years shipping consumer and merchant products at Zomato scale, owning features end-to-end from architecture through phased rollout. I mentor engineers, run the internal iOS knowledge-sharing forum, and interview on the iOS hiring panel."

	static let links: [ProfileLink] = [
		ProfileLink(title: "GitHub", url: #URL("https://github.com/mishandled")),
		ProfileLink(title: "LinkedIn", url: #URL("https://linkedin.com/in/mishandled")),
		ProfileLink(title: "Email", url: #URL("mailto:devmoh08@gmail.com")),
		// Published from `public/resume.pdf`. The link check fails the build if it is missing.
		ProfileLink(title: "Résumé", url: URL(string: "/resume.pdf")!),
	]

	static let handle = "@mishandled"

	/**
	The line under my name on the about page. The first part is green.
	*/
	static let aboutLead = (emphasis: "iOS engineer", rest: " fascinated by the intersection of engineering and experience, from crafting fluid interfaces to rethinking app architecture.")

	/**
	The facts on the about page, each with an optional note after `//`.
	*/
	static let facts: [Fact] = [
		Fact(label: "name", value: "Devansh Mohata"),
		Fact(label: "based in", value: "Gurugram, India", note: "IST"),
		Fact(label: "role", value: "iOS Engineer, SDE III", note: "Zomato"),
		Fact(label: "shipping iOS", value: "since 2022", note: "4 years"),
		Fact(label: "studied", value: "B.Tech, IT", note: "MSIT 2022"),
		Fact(label: "off the clock", value: "badminton, walks, tinkering"),
	]

	static let about: [AboutTopic] = [
		AboutTopic(
			title: "A little about how I build things",
			paragraphs: [
				"I started out as an iOS developer almost by accident. My first job put me on the iOS side of things, and with practically zero frontend experience, I was a little hesitant at first. That changed about 15 days in, when I shipped my first end-to-end feature. Seeing something I had built come to life on a screen, shaping what a user sees, feels, and experiences, just clicked.",
				"Since then, I’ve been fascinated by the intersection of engineering and experience. I enjoy working across the stack, from crafting fluid interfaces to rethinking app architecture, reducing app size, and building systems that make life easier for the developers who come after me. My favourite kind of engineering? Making the next feature so easy to build that it almost feels like plug-and-play.",
			]
		),
		AboutTopic(
			title: "Outside the Xcode window",
			paragraphs: [
				"I have a habit of taking things apart just to understand how they work. Electronic gadgets, unfamiliar components, the occasional mystery of modern technology, if it has parts worth investigating, I’m probably curious about what’s inside.",
				"When I’m not experimenting with Swift or tinkering with electronics, you’ll usually find me playing badminton, out on a walk, or on a call with my favourite person.",
				"Someday, I’d love to lead a team of curious, ambitious engineers working on problems that genuinely matter. Until then, I’m happy learning, building, breaking things (preferably not in production), and figuring out how to make them better.",
			]
		),
	]

	static let highlights: [Highlight] = [
		Highlight(value: "20,000+", label: "orders accepted daily through a flow I built from zero"),
		Highlight(value: "80%", label: "cache hit rate of my video caching layer, in 3 apps"),
		Highlight(value: "−41%", label: "Restaurant Partner app size, 199 MB to 117 MB, and still shrinking"),
		Highlight(value: "6,000+", label: "merchant partners using the order acceptance flow"),
	]

	static let jobs: [Job] = [
		Job(
			company: "Zomato",
			role: "iOS Engineer, Consumer & Restaurant Partner apps",
			period: "Oct 2024 – Present",
			points: [
				"Built the Restaurant Partner order management flow from scratch as modular Swift packages (orders, push notifications, login), taking it from zero to 20,000+ orders per day across 6,000+ merchant partners.",
				"Made real-time order delivery reliable: moved MQTT into a shared connection module with session recovery, added backoff retries for failed order fetches, and stopped a refresh loop firing 300+ requests a minute.",
				"Cut the Restaurant Partner app size by 41%, from 199 MB to 117 MB and still going, for merchants on constrained devices and networks.",
				"Built the video caching layer now used in Zomato, District, and Hyperpure, with an 80% hit rate from partial caching on AVAssetResourceLoader and byte-range requests.",
				"Built the iOS CI/CD pipeline on GitHub Actions (App Store uploads, version bumps, PR linting, SwiftFormat hooks, Slack release tracking), 143 snapshot tests for server-driven UI, and an in-app debugger for network and analytics.",
				"Shipped a personalised dish-discovery rail as a fully server-driven component, live on the Zomato home screen at 100% rollout, so merchandising ships changes with zero app releases.",
				"Shipped merchant tools: on-device FSSAI licence OCR with Vision, voice search of reviews with SFSpeechRecognizer, and a QR scanner that marks orders ready in one tap.",
				"Delivered Lookback 2024, the year-in-review, combining Lottie, video overlays, and per-user data in one scroll-driven flow.",
				"Drove platform migrations (scene-based lifecycle, Decodable models, a shared networking layer, a Kotlin Multiplatform module) and contributed 58 PRs to the merchant API gateway backend.",
				"Mentor 3 engineers through code reviews, run the internal iOS knowledge-sharing forum, and sit on the iOS hiring panel.",
			],
			visiblePoints: 4,
			steps: [
				Step(title: "SDE III", period: "Oct 2026 – Present", note: "still cooking"),
				Step(title: "SDE II", period: "Oct 2024 – Oct 2026"),
			],
			tech: ["Swift", "SwiftUI", "UIKit", "Objective-C", "SPM", "MQTT", "Core Data", "AVFoundation", "Vision", "Speech", "Combine", "Lottie", "GitHub Actions"]
		),
		Job(
			company: "Deutsche Telekom Digital Labs",
			role: "iOS Engineer",
			period: "Jun 2024 – Sep 2024",
			points: [
				"Built finance screens for payments and transaction tracking in SwiftUI, and fixed memory leaks across core modules.",
			],
			tech: ["Swift", "SwiftUI"]
		),
		Job(
			company: "LikeMinds",
			role: "iOS Engineer, SDK Platform",
			period: "Aug 2023 – Jun 2024",
			points: [
				"Core contributor to the open-source iOS Feed SDK (31,000+ lines): a plug-and-play social feed with infinite scrolling and media caching.",
				"Shipped Topic Feed end-to-end, so host apps filter a feed by topic without custom code.",
				"Split the SDK into standalone widgets, so integrators adopt single components instead of the whole framework.",
				"Owned 5 public releases, v1.0.0 to v1.3.0, with publishing automated through GitHub Actions.",
				"Built the Chat SDK with offline support through local persistence and sync on reconnect.",
			],
			tech: ["Swift", "UIKit", "CocoaPods", "Swift Package Manager", "GitHub Actions"]
		),
		Job(
			company: "TravClan",
			role: "iOS Engineer",
			period: "Aug 2022 – Aug 2023",
			points: [
				"Led iOS development of the Hotels product on VIPER as the sole iOS owner: search, booking, and payment.",
				"Built the KYC module for travel-agent verification, and raised crash-free sessions by fixing recurring crashes and memory pressure.",
			],
			tech: ["Swift", "UIKit", "VIPER"]
		),
	]

	static let projects: [OpenSourceProject] = [
		OpenSourceProject(
			title: "LikeMinds Feed SDK",
			description: "Open-source, plug-and-play social feed for iOS apps. 224 Swift files, 5 public releases.",
			url: #URL("https://github.com/LikeMindsCommunity/likeminds-feed-ios")
		),
	]

	static let talks: [Talk] = [
		Talk(
			title: "iOS 26 adoption strategy",
			venue: "Apple Developer Center, representing Zomato",
			date: "July 2025",
			detail: "A talk to 30+ iOS developers."
		),
	]

	static let skills: [SkillGroup] = [
		SkillGroup(title: "Languages & frameworks", items: ["Swift", "Objective-C", "SwiftUI", "UIKit", "Combine", "AVFoundation", "Vision", "Speech", "Core Animation", "Lottie"]),
		SkillGroup(title: "Architecture", items: ["Server-driven UI", "Modular SDK design", "VIPER", "MVVM", "async/await", "GCD", "REST", "Codable", "MQTT/WebSockets", "Feature flags & phased rollouts"]),
		SkillGroup(title: "Tools", items: ["Xcode", "Instruments", "XCTest", "Snapshot testing", "Git", "GitHub Actions", "CocoaPods", "Swift Package Manager", "Claude Code", "Codex"]),
	]

	static let education = Education(
		school: "Maharaja Surajmal Institute of Technology",
		degree: "B.Tech, Information Technology",
		year: "2022"
	)
}

struct ProfileLink {
	let title: String
	let url: URL
}

struct Fact {
	let label: String
	let value: String
	var note: String?
}

struct AboutTopic {
	let title: String
	let paragraphs: [String]
}

struct Highlight {
	let value: String
	let label: String
}

struct Job {
	let company: String
	let role: String
	let period: String
	let points: [String]
	/**
	How many points show before the rest fold behind a toggle. All of them when nil.
	*/
	var visiblePoints: Int?
	/**
	The titles held at the company, newest first, shown as a timeline.
	*/
	var steps: [Step] = []
	let tech: [String]
}

struct Step {
	let title: String
	let period: String
	var note: String?
}

struct OpenSourceProject {
	let title: String
	let description: String
	let url: URL
}

struct Talk {
	let title: String
	let venue: String
	let date: String
	let detail: String
}

struct SkillGroup {
	let title: String
	let items: [String]
}

struct Education {
	let school: String
	let degree: String
	let year: String
}
