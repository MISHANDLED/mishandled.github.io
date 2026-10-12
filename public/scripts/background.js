// The background of every page: a quiet grid of dots that light up and part around the pointer.
// It draws only while the glow moves, so an idle page costs nothing. With reduced motion, the grid stays still.

const canvas = document.querySelector('[data-background]');
const context = canvas?.getContext('2d');
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
const darkMode = matchMedia('(prefers-color-scheme: dark)');

const spacing = 28;
const radius = 180;
const push = 7;

const pointer = {x: 0, y: 0, active: false};
const glow = {x: 0, y: 0, strength: 0};
let width = 0;
let height = 0;
let frame = 0;

// The theme button in the bar sets the scheme on the root. Otherwise, the system's applies.
function isDark() {
	const chosen = document.documentElement.style.colorScheme;
	return chosen ? chosen === 'dark' : darkMode.matches;
}

function colors() {
	return isDark()
		? {dot: 'rgba(255, 255, 255, 0.11)', accent: [74, 222, 128]}
		: {dot: 'rgba(0, 0, 0, 0.13)', accent: [22, 163, 74]};
}

function resize() {
	const ratio = Math.min(devicePixelRatio, 2);
	width = innerWidth;
	height = innerHeight;
	canvas.width = width * ratio;
	canvas.height = height * ratio;
	context.setTransform(ratio, 0, 0, ratio, 0, 0);
	draw();
}

function draw() {
	const {dot, accent} = colors();
	const [red, green, blue] = accent;
	context.clearRect(0, 0, width, height);

	// The grid is centered, so the margins are even at every width.
	const startX = (width % spacing) / 2;
	const startY = (height % spacing) / 2;

	for (let x = startX; x <= width; x += spacing) {
		for (let y = startY; y <= height; y += spacing) {
			const dx = x - glow.x;
			const dy = y - glow.y;
			const distance = Math.hypot(dx, dy);
			const amount = glow.strength * Math.max(0, 1 - distance / radius) ** 2;

			if (amount < 0.01) {
				context.fillStyle = dot;
				context.fillRect(x - 0.75, y - 0.75, 1.5, 1.5);
				continue;
			}

			const offset = distance > 0 ? (push * amount) / distance : 0;
			const size = 1.5 + amount * 1.5;
			context.fillStyle = `rgba(${red}, ${green}, ${blue}, ${0.15 + amount * 0.85})`;
			context.fillRect(x + dx * offset - size / 2, y + dy * offset - size / 2, size, size);
		}
	}
}

function step() {
	// The glow eases toward the pointer, and fades in and out instead of jumping.
	glow.x += (pointer.x - glow.x) * 0.18;
	glow.y += (pointer.y - glow.y) * 0.18;
	glow.strength += ((pointer.active ? 1 : 0) - glow.strength) * 0.12;
	draw();

	const settled = Math.abs(pointer.x - glow.x) < 0.5
		&& Math.abs(pointer.y - glow.y) < 0.5
		&& Math.abs((pointer.active ? 1 : 0) - glow.strength) < 0.01;
	frame = settled ? 0 : requestAnimationFrame(step);
}

function wake() {
	if (!frame && !reducedMotion.matches) {
		frame = requestAnimationFrame(step);
	}
}

if (context) {
	addEventListener('resize', resize);
	darkMode.addEventListener('change', draw);
	addEventListener('themechange', draw);

	addEventListener('pointermove', event => {
		if (event.pointerType !== 'mouse') {
			return;
		}

		if (!pointer.active) {
			// Start the glow where the pointer enters, not where it left.
			glow.x = event.clientX;
			glow.y = event.clientY;
		}

		pointer.x = event.clientX;
		pointer.y = event.clientY;
		pointer.active = true;
		wake();
	}, {passive: true});

	document.documentElement.addEventListener('pointerleave', () => {
		pointer.active = false;
		wake();
	});

	resize();
}
