import Elementary
import SiteKit

/**
The background of every page: a grid of dots, drawn by `background.js`, that lights up around the pointer. Without scripts, the page keeps its plain background.
*/
struct SiteBackground: HTML {
	var body: some HTML {
		canvas(.data("background", value: ""))
			.accessibilityHidden()
			.style(Styles.root)

		script(.type(.module), .src("/scripts/background.js")) {}
	}

	enum Styles: StyleSet {
		case root

		var style: Style {
			// Fixed behind the content, so it fills the screen while the page scrolls.
			Style()
				.position(.fixed)
				.declaration(.inset, "0")
				.frame(width: .percent(100), height: .percent(100))
				.declaration(.zIndex, "-1")
				.allowsHitTesting(false)
		}
	}
}
