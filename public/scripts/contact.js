// The contact section: a button that copies the email address, and the local time in Gurugram.
// Every email link on the page also copies the address, because without an email app, a browser does nothing with it.
// All extras. Without scripts, the button stays hidden, the time shows the time zone, and email links only open the email app.

const toast = document.querySelector('[data-toast]');
let toastTimer;

function showToast(message) {
	toast.textContent = message;
	toast.dataset.shown = '';
	clearTimeout(toastTimer);
	toastTimer = setTimeout(() => delete toast.dataset.shown, 2600);
}

if (toast && navigator.clipboard) {
	for (const link of document.querySelectorAll('a[href^="mailto:"]')) {
		// The link still opens the email app, where there is one.
		link.addEventListener('click', () => {
			const address = decodeURIComponent(link.href.slice('mailto:'.length).split('?')[0]);
			navigator.clipboard.writeText(address).then(() => showToast(`Email copied: ${address}`), () => {});
		});
	}
}

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
