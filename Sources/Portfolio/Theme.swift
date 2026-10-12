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

	private var colors: (light: Color, dark: Color) {
		switch self {
		case .primaryText:
			("oklch(21% .006 286)", "oklch(98.5% .002 286)")
		case .bodyText:
			("oklch(37% .006 286)", "oklch(87% .006 286)")
		case .secondaryText:
			("oklch(52% .008 286)", "oklch(71.1% .007 286)")
		// Orange, like Swift.
		case .accent:
			("oklch(58% .2 40)", "oklch(74% .16 50)")
		case .separator:
			("oklch(93.2% .007 286)", "oklch(30% .006 286)")
		case .pageBackground:
			(.white, "oklch(14% .012 264)")
		case .card:
			(Color.black.opacity(0.035), Color.white.opacity(0.06))
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
			Rule(":root", SemanticColor.customProperties
				.colorScheme(.lightDark)
			)

			Rule("*, ::before, ::after", Style()
				.declaration(.boxSizing, "border-box")
				.margin(0)
				.padding(0)
			)

			Rule("body", Style()
				.fontFamily("system-ui, -apple-system, sans-serif")
				.font(size: .rootEm(1), lineHeight: 1.6)
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
