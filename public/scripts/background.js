// The animated background of every page: a slow aurora drawn by a WebGL fragment shader.
// It renders at half resolution and about 30 frames per second, as it is soft anyway.
// With reduced motion, it draws one still frame. Without WebGL, the page keeps its plain background.

const vertexShader = `#version 300 es
void main() {
	// One triangle that covers the whole canvas.
	vec2 point = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
	gl_Position = vec4(point * 2.0 - 1.0, 0.0, 1.0);
}`;

const fragmentShader = `#version 300 es
precision highp float;

uniform float time;
uniform vec2 resolution;
uniform float dark;

out vec4 outputColor;

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 offset = fract(point);
	vec2 curve = offset * offset * (3.0 - 2.0 * offset);
	return mix(
		mix(hash(cell), hash(cell + vec2(1.0, 0.0)), curve.x),
		mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), curve.x),
		curve.y
	);
}

// Layers of noise, for soft, cloud-like shapes.
float fbm(vec2 point) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int octave = 0; octave < 5; octave++) {
		value += amplitude * noise(point);
		point = point * 2.02 + vec2(1.7, 9.2);
		amplitude *= 0.5;
	}
	return value;
}

void main() {
	vec2 uv = gl_FragCoord.xy / resolution;
	vec2 point = (gl_FragCoord.xy - 0.5 * resolution) / resolution.y;
	float t = time * 0.04;

	// Noise that bends noise, so the shapes flow instead of sliding.
	vec2 warp = vec2(fbm(point * 1.4 + t), fbm(point * 1.4 - t + 3.1));
	float field = fbm(point * 1.8 + 2.0 * warp + vec2(t * 2.0, -t));

	vec3 orange = vec3(0.94, 0.32, 0.22);
	vec3 pink = vec3(0.93, 0.33, 0.60);
	vec3 violet = vec3(0.42, 0.32, 0.95);
	vec3 amber = vec3(1.0, 0.62, 0.20);

	vec3 color = mix(orange, pink, smoothstep(0.3, 0.7, warp.x));
	color = mix(color, violet, smoothstep(0.45, 0.8, warp.y) * 0.8);
	color = mix(color, amber, smoothstep(0.6, 0.9, field) * 0.6);

	// Stronger at the top of the screen, calmer behind the text below.
	float intensity = smoothstep(0.25, 0.85, field) * mix(0.45, 1.0, uv.y);

	// The page background of the theme, with the aurora over it.
	vec3 background = dark > 0.5 ? vec3(0.04, 0.045, 0.07) : vec3(1.0);
	float amount = dark > 0.5 ? 0.55 : 0.4;
	outputColor = vec4(mix(background, color, intensity * amount), 1.0);
}`;

const canvas = document.querySelector('[data-background]');
const gl = canvas?.getContext('webgl2', {alpha: false, antialias: false});
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
const darkMode = matchMedia('(prefers-color-scheme: dark)');

function compile(type, source) {
	const shader = gl.createShader(type);
	gl.shaderSource(shader, source);
	gl.compileShader(shader);
	return shader;
}

function start() {
	const program = gl.createProgram();
	gl.attachShader(program, compile(gl.VERTEX_SHADER, vertexShader));
	gl.attachShader(program, compile(gl.FRAGMENT_SHADER, fragmentShader));
	gl.linkProgram(program);

	if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
		console.error(gl.getProgramInfoLog(program));
		canvas.remove();
		return;
	}

	gl.useProgram(program);
	const timeLocation = gl.getUniformLocation(program, 'time');
	const resolutionLocation = gl.getUniformLocation(program, 'resolution');
	const darkLocation = gl.getUniformLocation(program, 'dark');

	const resize = () => {
		const scale = Math.min(devicePixelRatio, 2) * 0.5;
		canvas.width = Math.max(1, Math.round(innerWidth * scale));
		canvas.height = Math.max(1, Math.round(innerHeight * scale));
		gl.viewport(0, 0, canvas.width, canvas.height);
	};

	const startTime = performance.now();
	let lastFrame = 0;
	let frameRequest = 0;

	const render = now => {
		gl.uniform1f(timeLocation, reducedMotion.matches ? 0 : (now - startTime) / 1000);
		gl.uniform2f(resolutionLocation, canvas.width, canvas.height);
		gl.uniform1f(darkLocation, darkMode.matches ? 1 : 0);
		gl.drawArrays(gl.TRIANGLES, 0, 3);
	};

	const tick = now => {
		frameRequest = 0;

		if (now - lastFrame >= 33) {
			lastFrame = now;
			render(now);
		}

		if (!document.hidden && !reducedMotion.matches) {
			frameRequest = requestAnimationFrame(tick);
		}
	};

	const redraw = () => {
		render(performance.now());

		if (!frameRequest && !document.hidden && !reducedMotion.matches) {
			frameRequest = requestAnimationFrame(tick);
		}
	};

	addEventListener('resize', () => {
		resize();
		redraw();
	});
	document.addEventListener('visibilitychange', redraw);
	reducedMotion.addEventListener('change', redraw);
	darkMode.addEventListener('change', redraw);

	resize();
	redraw();
}

if (gl) {
	start();
}
