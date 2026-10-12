// The cat at the bottom of the screen. Once the pointer rests, it walks over below it and sits.
// After a while with nothing happening, it falls asleep. Clicking it makes it meow.
// With reduced motion, or without a mouse, it stays in its corner, and still meows.

const cat = document.querySelector('[data-cat]');
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
const finePointer = matchMedia('(pointer: fine)');

const size = 72;
const margin = 16;
const speed = 2.4;
const restDelay = 450;
const sleepDelay = 9000;
const sounds = ['meow', 'mrrp?', 'purr…', 'mew'];

let x = 0;
let target = 0;
let frame = 0;
let restTimer;
let sleepTimer;
let meowTimer;
let soundIndex = 0;

const clamp = value => Math.min(Math.max(value, margin), innerWidth - size - margin);
const follows = () => finePointer.matches && !reducedMotion.matches;

function place() {
	cat.style.transform = `translateX(${x}px)`;
}

function setState(state) {
	cat.dataset.state = state;
	clearTimeout(sleepTimer);

	if (state === 'sit') {
		sleepTimer = setTimeout(() => setState('sleep'), sleepDelay);
	}
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

if (cat) {
	x = target = clamp(innerWidth);
	place();
	setState('sit');

	addEventListener('resize', () => {
		x = target = clamp(x);
		place();
	});

	addEventListener('pointermove', event => {
		if (!follows() || event.pointerType !== 'mouse') {
			return;
		}

		if (cat.dataset.state === 'sleep') {
			setState('sit');
		}

		clearTimeout(restTimer);
		restTimer = setTimeout(() => walkTo(event.clientX), restDelay);
	}, {passive: true});

	cat.addEventListener('click', () => {
		cat.querySelector('[data-cat-bubble]').textContent = sounds[soundIndex++ % sounds.length];
		cat.dataset.meow = '';

		if (cat.dataset.state !== 'walk') {
			setState('sit');
		}

		clearTimeout(meowTimer);
		meowTimer = setTimeout(() => delete cat.dataset.meow, 1400);
	});
}
