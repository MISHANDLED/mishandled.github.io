import SiteKit

/**
Colors named by their role, with a light and a dark value. Each is a custom property on `:root`, so a typo is a build error, not a missing color.
*/
enum SemanticColor: String, CaseIterable {
	case primaryText
	case bodyText
	case secondaryText
	case accent
	case separator
	case pageBackground
	case card
	case matte
	case matteHover

	private var colors: (light: Color, dark: Color) {
		switch self {
		case .primaryText:
			("oklch(14% 0 0)", "oklch(98% 0 0)")
		case .bodyText:
			("oklch(30% 0 0)", "oklch(86% 0 0)")
		case .secondaryText:
			("oklch(50% 0 0)", "oklch(64% 0 0)")
		// Terminal green, on black and white.
		case .accent:
			("oklch(54% .19 148)", "oklch(84% .23 148)")
		case .separator:
			("oklch(90% 0 0)", "oklch(26% 0 0)")
		case .pageBackground:
			(.white, .black)
		case .card:
			(Color.black.opacity(0.025), Color.white.opacity(0.035))
		// Opaque, so the dots of the background do not show through panels.
		case .matte:
			("oklch(97.5% 0 0)", "oklch(16.5% 0 0)")
		case .matteHover:
			("oklch(95% 0 0)", "oklch(20.5% 0 0)")
		}
	}

	private var variable: StyleVariable<Color> {
		StyleVariable("--" + rawValue.kebabCased)
	}

	var color: Color {
		variable.value
	}

	static var customProperties: Style {
		allCases.reduce(Style()) { $0.setting($1.variable, to: .lightDark($1.colors.light, $1.colors.dark)) }
	}
}

extension Color {
	static func semantic(_ color: SemanticColor) -> Self {
		color.color
	}
}

extension Length {
	/**
	The widest the content gets. It uses most of a laptop screen, and stays readable on a large monitor.
	*/
	static let pageWidth: Self = .rootEm(76)

	/**
	The space at the sides of the page, wider on wider screens.
	*/
	static let pageGutter: Self = .clamp(.rootEm(1.25), .viewportWidth(5), .rootEm(4))
}

extension Style {
	/**
	Continuous corners, like Apple's squircle. Browsers without `corner-shape` show plain rounded corners.
	*/
	func squircle(_ radius: Length) -> Self {
		cornerRadius(radius)
			.declaration(.cornerShape, "squircle")
	}
}

extension CascadeLayer {
	static let base = Self("base")
	static let components = Self("components")
	static let elements = Self("elements")
}

extension Stylesheet {
	static let sitePath: RoutePath = "/site.css"

	/**
	The element defaults that every page links to. Components add their own rules to the page that uses them.
	*/
	static let site = Stylesheet {
		Layer(.base) {
			// Everything is sized in rem, so the whole page scales up with the screen, from 16 px on a phone to about 21 px on a large monitor.
			Rule(":root", SemanticColor.customProperties
				.colorScheme(.lightDark)
				.declaration(.fontSize, "clamp(1rem, 0.55vw + 0.75rem, 1.3rem)")
				.declaration(.scrollBehavior, "smooth")
				.reducedMotion { $0.declaration(.scrollBehavior, "auto") }
			)

			Rule("*, ::before, ::after", Style()
				.declaration(.boxSizing, "border-box")
				.margin(0)
				.padding(0)
			)

			Rule("body", Style()
				.fontFamily(#""JetBrains Mono", ui-monospace, "SF Mono", Menlo, monospace"#)
				.font(size: .rootEm(1), lineHeight: 1.65)
				.color(.semantic(.bodyText))
				.background(.semantic(.pageBackground))
			)

			Rule("h1, h2, h3", Style()
				.color(.semantic(.primaryText))
				.lineHeight(1.2)
				.textWrap(.balance)
			)

			Rule("p, li", Style().textWrap(.pretty))

			Rule("ul", Style().declaration(.listStyle, .none))

			Rule("a", Style()
				.color(.semantic(.accent))
				.declaration(.textDecoration, "none")
			)

			Rule("a:hover", Style().declaration(.textDecoration, "underline"))

			Rule("::selection", Style().background(Color.semantic(.accent).opacity(0.25)))
		}

		Layer(.components) {}
		Layer(.elements) {}
	}
}
