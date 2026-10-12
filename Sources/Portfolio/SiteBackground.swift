import Elementary
import SiteKit

/**
The animated background of every page, drawn by `background.js` with WebGL. Without WebGL, the page keeps its plain background.
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
