import Elementary
import SiteKit

/**
A small line-drawn cat that lives at the bottom of the screen. `cat.js` walks it to the pointer, sits it down, and lets it fall asleep. Clicking it makes it meow. Without scripts, it sits in the corner.
*/
struct SiteCat: HTML {
	var body: some HTML {
		button(.type(.button), .data("cat", value: ""), .data("state", value: "sit"), .data("facing", value: "left"), .custom(name: "aria-label", value: "Pet the cat")) {
			span(.data("cat-bubble", value: "")) { "meow" }
				.accessibilityHidden()
				.style(Styles.bubble)

			HTMLRaw(Self.drawing)
		}
		.style(Styles.root)

		script(.type(.module), .src("/scripts/cat.js")) {}
	}

	// Drawn facing right: the tail and back legs first, so the body covers where they join.
	private static let drawing = """
	<svg viewBox="0 0 64 44" width="72" height="49.5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
		<path class="cat-tail" d="M15 27C7 26 4 17 9 11"/>
		<line class="cat-leg cat-leg-a" x1="20" y1="32" x2="20" y2="41"/>
		<line class="cat-leg cat-leg-b" x1="25" y1="33" x2="25" y2="41"/>
		<ellipse class="cat-fill" cx="29" cy="28" rx="15" ry="8"/>
		<line class="cat-leg cat-leg-b" x1="36" y1="33" x2="36" y2="41"/>
		<line class="cat-leg cat-leg-a" x1="41" y1="32" x2="41" y2="41"/>
		<path class="cat-fill" d="M42.5 16L43.5 7.5L48.5 12.5M49.5 12.5L54 7.5L55 16"/>
		<circle class="cat-fill" cx="48.5" cy="20" r="8"/>
		<ellipse class="cat-eye" cx="51.5" cy="19" rx="1.3" ry="1.6"/>
		<path class="cat-whiskers" d="M56 22.5L62.5 21.5M56 24.5L62.5 25.5"/>
		<text class="cat-z" x="54" y="6">z</text>
	</svg>
	"""

	enum Styles: StyleSet {
		case root
		case bubble

		var style: Style {
			switch self {
			case .root:
				// `cat.js` moves it with a transform, so walking never lays out the page.
				Style()
					.position(.fixed)
					.declaration(.bottom, "0")
					.leading(0)
					.zIndex(20)
					.padding(0)
					.declaration(.border, "0")
					.background(.transparent)
					.color(.semantic(.primaryText))
					.declaration(.fontFamily, "inherit")
					.cursor(.pointer)
					.declaration(.transform, "translateX(calc(100vw - 88px))")
					.declaration(.webkitTapHighlightColor, "transparent")
					.nested("svg") {
						$0.display(.block)
							.transition(.transform, animation: .easeOut(duration: .milliseconds(200)))
					}
					.nested("&[data-facing=left] svg") { $0.declaration(.transform, "scaleX(-1)") }
					.nested(".cat-fill") { $0.declaration(.fill, "var(--page-background)") }
					.nested(".cat-eye") {
						$0.declaration(.fill, "var(--accent)")
							.declaration(.stroke, "none")
							.declaration(.transformBox, "fill-box")
							.declaration(.transformOrigin, "center")
							.animation(Animations.blink, .linear(duration: .seconds(5)).repeatForever(autoreverses: false))
					}
					.nested(".cat-whiskers") { $0.opacity(0.55).declaration(.strokeWidth, "1") }
					.nested(".cat-tail") {
						$0.declaration(.transformBox, "fill-box")
							.declaration(.transformOrigin, "100% 100%")
							.animation(Animations.sway, .easeInOut(duration: .milliseconds(2400)).repeatForever(autoreverses: true))
					}
					.nested(".cat-leg") {
						$0.declaration(.transformBox, "fill-box")
							.declaration(.transformOrigin, "top")
					}
					.nested(".cat-z") {
						$0.declaration(.fill, "var(--accent)")
							.declaration(.stroke, "none")
							.font(size: .pixels(9))
							.opacity(0)
					}
					// Walking: the legs swing in pairs, and the tail stands up.
					.nested("&[data-state=walk] .cat-leg") {
						$0.animation(Animations.step, .easeInOut(duration: .milliseconds(320)).repeatForever(autoreverses: true))
					}
					.nested("&[data-state=walk] .cat-leg-b") { $0.declaration(.animationDelay, "-320ms") }
					// Sleeping: the eyes close, and a z drifts up.
					.nested("&[data-state=sleep] .cat-eye") { $0.declaration(.animation, .none).declaration(.transform, "scaleY(0.15)") }
					.nested("&[data-state=sleep] .cat-z") {
						$0.animation(Animations.drift, .easeOut(duration: .milliseconds(2600)).repeatForever(autoreverses: false))
					}
					.hover { $0.nested(".cat-tail") { $0.declaration(.animationDuration, "600ms") } }
					.focusVisible {
						$0.declaration(.outline, "2px solid var(--accent)")
							.declaration(.outlineOffset, "2px")
					}
					.reducedMotion { $0.nested("*") { $0.declaration(.animation, .none) } }
					.media(.print) { $0.display(.none) }
			case .bubble:
				// The meow, above the cat's head, shown while `cat.js` sets `data-meow`.
				Style()
					.position(.absolute)
					.declaration(.bottom, "100%")
					.leading(.percent(50))
					.padding(vertical: .rootEm(0.2), horizontal: .rootEm(0.55))
					.squircle(.rootEm(0.6))
					.border(.semantic(.separator))
					.background(.semantic(.matte))
					.color(.semantic(.accent))
					.font(size: .rootEm(0.75))
					.declaration(.whiteSpace, "nowrap")
					.opacity(0)
					.declaration(.transform, "translate(-50%, 0.25rem)")
					.allowsHitTesting(false)
					.transition(.opacity, .transform, animation: .easeOut(duration: .milliseconds(200)))
					.nested("[data-meow] > &") { $0.opacity(1).declaration(.transform, "translate(-50%, -0.25rem)") }
			}
		}
	}

	enum Animations: KeyframeSet {
		case blink
		case sway
		case step
		case drift

		var keyframes: [Keyframe] {
			switch self {
			case .blink:
				[.at(94, Style().declaration(.transform, "scaleY(1)")), .at(96, Style().declaration(.transform, "scaleY(0.1)")), .at(98, Style().declaration(.transform, "scaleY(1)"))]
			case .sway:
				[.from(Style().declaration(.transform, "rotate(-6deg)")), .to(Style().declaration(.transform, "rotate(8deg)"))]
			case .step:
				[.from(Style().declaration(.transform, "rotate(-22deg)")), .to(Style().declaration(.transform, "rotate(22deg)"))]
			case .drift:
				[.from(Style().opacity(0).offset(y: 4)), .at(30, Style().opacity(1)), .to(Style().opacity(0).offset(x: 4, y: -6))]
			}
		}
	}
}
