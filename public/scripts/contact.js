// The contact section: a button that copies the email address, and the local time in Gurugram.
// Both are extras. Without scripts, the button stays hidden and the time shows the time zone.

const copyButton = document.querySelector('[data-copy]');

if (copyButton && navigator.clipboard) {
	const label = copyButton.textContent;
	let reset;

	copyButton.hidden = false;
	copyButton.addEventListener('click', async () => {
		try {
			await navigator.clipboard.writeText(copyButton.dataset.copy);
			copyButton.textContent = 'Copied';
		} catch {
			copyButton.textContent = 'Press ⌘C';
		}

		clearTimeout(reset);
		reset = setTimeout(() => {
			copyButton.textContent = label;
		}, 1800);
	});
}

const clock = document.querySelector('[data-clock]');

if (clock) {
	const format = new Intl.DateTimeFormat('en-GB', {
		timeZone: clock.dataset.clock,
		hour: '2-digit',
		minute: '2-digit',
	});

	const tick = () => {
		clock.textContent = `${format.format(new Date())} IST`;
	};

	tick();
	setInterval(tick, 15_000);
}
