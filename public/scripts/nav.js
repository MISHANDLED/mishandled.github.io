// The bar at the top of every page.
// - The link of the section on screen turns green, like the current directory.
// - The theme button switches between light and dark, and remembers the choice.
// - Choosing a link in the drawer closes it.

const root = document.documentElement;
const links = [...document.querySelectorAll('[data-section]')];
const sections = [...new Set(links.map(link => link.dataset.section))]
	.map(id => document.getElementById(id))
	.filter(Boolean);

function markCurrent(id) {
	for (const link of links) {
		link.toggleAttribute('aria-current', link.dataset.section === id);
	}
}

// Only the home page has the sections. A post, or the about page, keeps the link it was given.
if (sections.length > 0) {
	// A section is current while it crosses a thin band a third of the way down the screen.
	const observer = new IntersectionObserver(entries => {
		for (const entry of entries) {
			if (entry.isIntersecting) {
				markCurrent(entry.target.id);
			}
		}
	}, {rootMargin: '-33% 0px -66% 0px'});

	for (const section of sections) {
		observer.observe(section);
	}
}

const darkMode = matchMedia('(prefers-color-scheme: dark)');

document.querySelector('[data-theme-toggle]')?.addEventListener('click', () => {
	const current = root.style.colorScheme || (darkMode.matches ? 'dark' : 'light');
	const next = current === 'dark' ? 'light' : 'dark';
	root.style.colorScheme = next;

	try {
		localStorage.setItem('theme', next);
	} catch {}

	dispatchEvent(new Event('themechange'));
});

const menu = document.getElementById('site-menu');

for (const link of menu?.querySelectorAll('a') ?? []) {
	link.addEventListener('click', () => menu.hidePopover());
}
