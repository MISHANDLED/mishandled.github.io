import Foundation
import SiteKit

/**
The content of the site, from the résumé. Typed, so a missing field fails the build.
*/
enum Resume {
	static let name = "Devansh Mohata"
	static let role = "iOS Engineer"
	static let location = "Gurugram, India"
	static let email = "devmoh08@gmail.com"

	static let summary = "iOS engineer with 4 years shipping consumer and merchant products at Zomato scale, owning features end-to-end from architecture through phased rollout. I mentor engineers, run the internal iOS knowledge-sharing forum, and interview on the iOS hiring panel."

	static let links: [ProfileLink] = [
		ProfileLink(title: "GitHub", url: #URL("https://github.com/mishandled")),
		ProfileLink(title: "LinkedIn", url: #URL("https://linkedin.com/in/mishandled")),
		ProfileLink(title: "Email", url: #URL("mailto:devmoh08@gmail.com")),
		// Published from `public/resume.pdf`. The link check fails the build if it is missing.
		ProfileLink(title: "Résumé", url: URL(string: "/resume.pdf")!),
	]

	static let highlights: [Highlight] = [
		Highlight(value: "20,000+", label: "orders accepted daily through a flow I built from zero"),
		Highlight(value: "80%", label: "cache hit rate of my video caching layer, in 3 apps"),
		Highlight(value: "−41%", label: "Restaurant Partner app size, 197 MB to 117 MB, and still shrinking"),
		Highlight(value: "4,500+", label: "merchant partners using the order acceptance flow"),
	]

	static let jobs: [Job] = [
		Job(
			company: "Zomato",
			role: "iOS Engineer (SDE II), Consumer & Restaurant Partner apps",
			period: "Oct 2024 – Present",
			points: [
				"Built the Restaurant Partner order acceptance flow from the ground up, taking it from zero to 20,000+ accepted orders per day across 4,500+ merchant partners.",
				"Cut the Restaurant Partner app size by 41%, from 197 MB to 117 MB and still going, for merchants on constrained devices and networks.",
				"Built the video caching layer now used in Zomato, District, and Hyperpure, with an 80% hit rate from partial caching on AVAssetResourceLoader and byte-range requests.",
				"Shipped the Lockdown Dish Craving rail as a fully server-driven component, live on the Zomato home screen at 100% rollout, so merchandising ships changes with zero app releases.",
				"Shipped merchant tools: on-device FSSAI licence OCR with Vision, voice search of reviews with SFSpeechRecognizer, and a QR scanner that marks orders ready in one tap.",
				"Delivered Lookback 2024, the year-in-review, combining Lottie, video overlays, and per-user data in one scroll-driven flow.",
			],
			tech: ["Swift", "SwiftUI", "UIKit", "Objective-C", "AVFoundation", "Vision", "Speech", "Combine", "Lottie"]
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
		SkillGroup(title: "Architecture", items: ["Server-driven UI", "Modular SDK design", "VIPER", "MVVM", "async/await", "GCD", "REST", "Codable"]),
		SkillGroup(title: "Tools", items: ["Xcode", "Instruments", "Git", "GitHub Actions", "CocoaPods", "Swift Package Manager"]),
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

struct Highlight {
	let value: String
	let label: String
}

struct Job {
	let company: String
	let role: String
	let period: String
	let points: [String]
	let tech: [String]
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
