// The cat. On the home page, it starts on a ledge at the side of the hero. Once the page scrolls, it jumps
// down to the bottom of the screen, and jumps back up when the page is back at the top.
// At the bottom, once the pointer rests, it walks over below it and sits. After a while with nothing
// happening, it falls asleep. Clicking it makes it meow.
// With reduced motion, it moves without jumping or walking. Without a mouse, it stays in its corner. It always meows.

const cat = document.querySelector('[data-cat]');
const perch = document.querySelector('[data-cat-perch]');
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
const finePointer = matchMedia('(pointer: fine)');

const size = 72;
const margin = 16;
const speed = 3.6;
const restDelay = 450;
const sleepDelay = 9000;
const perchScale = 1.5;
const jumpDuration = 700;
const jumpHeight = 70;
const scrollThreshold = 24;
const sounds = ['meow', 'mrrp?', 'purr…', 'mew'];

// Where the cat is: x from the left, y up from the bottom of the screen (negative is higher), and its scale.
let x = 0;
let y = 0;
let scale = 1;
let target = 0;
let frame = 0;
let isPerched = false;
let isJumping = false;
let restTimer;
let sleepTimer;
let meowTimer;
let soundIndex = 0;

// Where the mouse was last, so the cat can walk over after it lands, even if the mouse has not moved since.
let pointerX;

const clamp = value => Math.min(Math.max(value, margin), innerWidth - size - margin);
const follows = () => finePointer.matches && !reducedMotion.matches && !isPerched && !isJumping;
const floor = () => ({x: clamp(innerWidth), y: 0, scale: 1});
const transform = position => `translate(${position.x}px, ${position.y}px) scale(${position.scale})`;

// The ledge is only shown on wide screens.
const hasPerch = () => perch?.checkVisibility?.() ?? false;

// Standing on the ledge, centered on it. The cat scales from its feet, so its feet stay on the ledge.
function perchPosition() {
	const ledge = perch.getBoundingClientRect();
	return {x: ledge.left + ledge.width / 2 - size / 2, y: ledge.top - innerHeight, scale: perchScale};
}

function place() {
	cat.style.transform = transform({x, y, scale});
}

function moveTo(position) {
	({x, y, scale} = position);
	target = x;
	place();
}

function setState(state) {
	cat.dataset.state = state;
	clearTimeout(sleepTimer);

	if (state === 'sit') {
		sleepTimer = setTimeout(() => setState('sleep'), sleepDelay);
	}
}

/**
Jumps in an arc, rising a little before it falls, and lands sitting.
*/
function jumpTo(position, onLand) {
	cancelAnimationFrame(frame);
	frame = 0;

	if (reducedMotion.matches) {
		moveTo(position);
		setState('sit');
		onLand?.();
		return;
	}

	const from = {x, y, scale};
	const frames = [];

	for (let index = 0; index <= 20; index++) {
		const progress = index / 20;
		const eased = progress * progress * (3 - 2 * progress);
		frames.push({
			transform: transform({
				x: from.x + (position.x - from.x) * eased,
				y: from.y + (position.y - from.y) * progress - jumpHeight * Math.sin(Math.PI * progress),
				scale: from.scale + (position.scale - from.scale) * eased,
			}),
		});
	}

	isJumping = true;
	cat.dataset.facing = position.x < from.x ? 'left' : 'right';
	setState('jump');
	moveTo(position);

	cat.animate(frames, {duration: jumpDuration, easing: 'linear'}).finished.then(() => {
		isJumping = false;
		setState('sit');
		onLand?.();
	});
}

function step() {
	const distance = target - x;

	if (Math.abs(distance) <= speed) {
		x = target;
		place();
		frame = 0;
		setState('sit');
		return;
	}

	x += Math.sign(distance) * speed;
	place();
	frame = requestAnimationFrame(step);
}

function walkTo(pointerX) {
	target = clamp(pointerX - size / 2);

	// Small moves are not worth getting up for.
	if (!frame && Math.abs(target - x) < size / 2) {
		return;
	}

	cat.dataset.facing = target < x ? 'left' : 'right';
	setState('walk');
	frame ||= requestAnimationFrame(step);
}

// Down when the page scrolls, back up at the top. On the ledge, it moves with the page until it jumps.
function followScroll() {
	if (isJumping) {
		return;
	}

	const atTop = scrollY <= scrollThreshold && hasPerch();

	if (isPerched && !atTop) {
		isPerched = false;
		jumpTo(floor(), () => {
			if (pointerX !== undefined && follows()) {
				walkTo(pointerX);
			}
		});
	} else if (!isPerched && atTop && !frame) {
		isPerched = true;
		jumpTo(perchPosition());
	} else if (isPerched) {
		moveTo(perchPosition());
	}
}

if (cat) {
	if (scrollY <= scrollThreshold && hasPerch()) {
		isPerched = true;
		moveTo(perchPosition());
		cat.dataset.facing = 'left';
	} else {
		moveTo(floor());
	}

	setState('sit');

	addEventListener('scroll', followScroll, {passive: true});

	addEventListener('resize', () => {
		if (isJumping) {
			return;
		}

		if (isPerched && hasPerch()) {
			moveTo(perchPosition());
		} else {
			isPerched = false;
			moveTo({x: clamp(x), y: 0, scale: 1});
		}
	});

	addEventListener('pointermove', event => {
		if (event.pointerType !== 'mouse') {
			return;
		}

		pointerX = event.clientX;

		if (cat.dataset.state === 'sleep') {
			setState('sit');
		}

		if (!follows()) {
			return;
		}

		clearTimeout(restTimer);
		restTimer = setTimeout(() => follows() && walkTo(pointerX), restDelay);
	}, {passive: true});

	cat.addEventListener('click', () => {
		cat.querySelector('[data-cat-bubble]').textContent = sounds[soundIndex++ % sounds.length];
		cat.dataset.meow = '';

		if (cat.dataset.state !== 'walk' && !isJumping) {
			setState('sit');
		}

		clearTimeout(meowTimer);
		meowTimer = setTimeout(() => delete cat.dataset.meow, 1400);
	});
}
