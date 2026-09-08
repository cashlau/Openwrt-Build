'use strict';
'require baseclass';
'require rpc';

var tempLang = String(document.documentElement.lang || L.env.lang || 'en').toLowerCase();
function tempText(en, zh, tw) {
	return /^zh/.test(tempLang) ? (/tw|hk|hant/.test(tempLang) ? (tw || zh) : zh) : en;
}
function tempModel(kind, value) {
	var text = String(value || '');
	if (kind === 'cpu')
		return text.replace(/\(R\)|\(TM\)/gi, '').replace(/\s+CPU\b/g, '').replace(/\s+@\s+.*$/, '').replace(/\s+/g, ' ').trim();
	if (kind === 'pch') {
		var names = { cometlake: 'Comet Lake', skylake: 'Skylake', cannonlake: 'Cannon Lake', tigerlake: 'Tiger Lake', alderlake: 'Alder Lake' };
		return text.replace(/pch_([a-z0-9]+)/gi, function(full, family) {
			return names[family.toLowerCase()] ? 'Intel ' + names[family.toLowerCase()] + ' PCH' : full;
		});
	}
	return text;
}

/* Compact temperature cards for the LuCI status overview (Argon friendly). */
document.head.append(E('style', { 'type': 'text/css' }, `
.temp-argon-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
	gap: 10px;
	padding: 12px 16px;
	margin: 0;
	width: 100%;
	box-sizing: border-box;
}

.temp-argon-card {
	--temp-accent: #238636;
	--temp-stripe: #90ee90;
	--temp-fill: rgba(144, 238, 144, .25);
	isolation: isolate;
	box-sizing: border-box;
	min-width: 0;
	position: relative;
	display: flex;
	align-items: center;
	justify-content: space-between;
	height: 48px;
	min-height: 48px;
	padding: 6px 12px 6px 14px;
	overflow: hidden;
	border: 1px solid var(--border-color-medium, rgba(120, 120, 120, .18));
	border-radius: 6px;
	background: var(--background-color-high, rgba(255, 255, 255, .82));
	box-shadow: none;
}

.temp-argon-card::before {
	z-index: 1;
	position: absolute;
	top: 0;
	bottom: 0;
	left: 0;
	width: 4px;
	background: var(--temp-stripe);
	content: '';
}

/* Background scale: 0–100 °C, clamped at either end. */
.temp-argon-card::after {
	content: '';
	position: absolute;
	inset: 0 auto 0 0;
	width: var(--temp-level, 0%);
	background: var(--temp-fill);
	z-index: -1;
	pointer-events: none;
}

.temp-argon-card.warm {
	--temp-accent: #b86808;
	--temp-stripe: #f0ad4e;
	--temp-fill: rgba(240, 173, 78, .20);
}

.temp-argon-card.hot {
	--temp-accent: #dc2626;
	--temp-stripe: #e65353;
	--temp-fill: rgba(230, 83, 83, .18);
}

.temp-argon-card.unavailable {
	--temp-accent: #8a9099;
	--temp-stripe: #8a9099;
	--temp-fill: transparent;
}

.temp-argon-meta {
	min-width: 0;
}

.temp-argon-name {
	display: block;
	font-size: 13px;
	font-weight: 600;
	line-height: 1.35;
}

.temp-argon-desc {
	display: block;
	margin-top: 2px;
	opacity: 1;
	color: #586174;
	font-size: 11px;
	line-height: 1.2;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.temp-argon-value {
	flex: 0 0 auto;
	margin-left: 10px;
	color: var(--temp-accent);
	font-size: 20px;
	line-height: 1.2;
	font-weight: 700;
	font-variant-numeric: tabular-nums;
	letter-spacing: -.5px;
}

.temp-argon-grid.temp-dark .temp-argon-card {
	background: #252525;
	border-color: #404040;
	box-shadow: none;
}

.temp-argon-grid.temp-dark .temp-argon-card:not(.warm):not(.hot):not(.unavailable) {
	--temp-accent: #90ee90;
	--temp-fill: rgba(144, 238, 144, .12);
}
.temp-argon-grid.temp-dark .temp-argon-card.warm { --temp-accent: #ffd080; --temp-fill: rgba(240, 173, 78, .12); }
.temp-argon-grid.temp-dark .temp-argon-card.hot { --temp-accent: #ff9c9c; --temp-fill: rgba(230, 83, 83, .12); }
.temp-argon-grid.temp-dark .temp-argon-card.unavailable { --temp-accent: #c3ccd8; }
.temp-argon-grid.temp-dark .temp-argon-name { color: #f1f5f9; }
.temp-argon-grid.temp-dark .temp-argon-desc { color: #c3ccd8; }

@media (max-width: 600px) {
	.temp-argon-grid {
		grid-template-columns: 1fr;
	}
}
`));

function syncTempTheme() {
	document.querySelectorAll('.temp-argon-grid').forEach(grid => {
		let dark = false;
		let explicit = document.documentElement.getAttribute('data-darkmode');
		if (explicit !== 'true' && explicit !== 'false')
			explicit = document.body && document.body.getAttribute('data-darkmode');
		if (explicit === 'true' || explicit === 'false') {
			dark = explicit === 'true';
		} else {
			for (let parent = grid.parentElement; parent; parent = parent.parentElement) {
				let rgb = getComputedStyle(parent).backgroundColor.match(/[\d.]+/g);
				if (!rgb || rgb.length < 3 || (rgb.length > 3 && Number(rgb[3]) < .9)) continue;
				dark = (Number(rgb[0]) * .2126 + Number(rgb[1]) * .7152 + Number(rgb[2]) * .0722) < 128;
				break;
			}
		}
		if (grid.classList.contains('temp-dark') !== dark)
			grid.classList.toggle('temp-dark', dark);
	});
}

// Keep theme changes independent of the temperature polling interval.
var tempThemeFrame = null;
function scheduleTempTheme() {
	if (tempThemeFrame !== null) return;
	tempThemeFrame = requestAnimationFrame(() => {
		tempThemeFrame = null;
		syncTempTheme();
	});
}
var tempThemeObserver = new MutationObserver(records => {
	if (records.some(record => !(record.target instanceof Element) || !record.target.closest('.temp-argon-grid')))
		scheduleTempTheme();
});
tempThemeObserver.observe(document.documentElement, {
	subtree: true, attributes: true, childList: true,
	attributeFilter: [ 'class', 'style', 'data-darkmode', 'data-theme', 'href', 'media', 'disabled' ]
});
var tempColorScheme = window.matchMedia('(prefers-color-scheme: dark)');
if (tempColorScheme.addEventListener)
	tempColorScheme.addEventListener('change', scheduleTempTheme);
else
	tempColorScheme.addListener(scheduleTempTheme);
document.addEventListener('transitionend', scheduleTempTheme, true);
document.addEventListener('load', event => {
	if (event.target instanceof HTMLLinkElement) scheduleTempTheme();
}, true);

return baseclass.extend({
	title: tempText('Hardware temperature', '硬件温度', '硬體溫度'),

	sensorsData: null,

	tempData: null,

	sensorsPath: [],

	cpuModel: tempText('Unknown processor', '处理器型号未知', '處理器型號未知'),


	callSensors: rpc.declare({
		object: 'luci.temp-status',
		method: 'getSensors',
		expect: { '': {} }
	}),

	callTempData: rpc.declare({
		object: 'luci.temp-status',
		method: 'getTempData',
		params: [ 'tpaths' ],
		expect: { '': {} }
	}),

	formatTemp(mc) {
		return Number((mc / 1000).toFixed(1));
	},

	load() {
		if (!this.sensorsData)
			return L.resolveDefault(this.callSensors(), null);

		return this.sensorsPath.length
			? L.resolveDefault(this.callTempData(this.sensorsPath), null)
			: Promise.resolve(null);
	},

	collectCards() {
		let selected = {};

		for (let group of Object.values(this.sensorsData || {})) {
			for (let sensorInfo of Object.values(group || [])) {
				let sensor = String(sensorInfo.title || sensorInfo.item || '');
				let sensorLower = sensor.toLowerCase();

				for (let source of Object.values(sensorInfo.sources || [])) {
					let label = String(source.label || source.item || '').replace(/_input$/, '');
					let labelLower = label.toLowerCase();
					let card = null;

					if (sensorLower === 'coretemp' && labelLower.indexOf('package id') !== -1) {
						card = {
							key: 'cpu',
							name: 'CPU',
							desc: sensorInfo.model || this.cpuModel,
							path: source.path,
							warm: 75,
							hot: 90
						};
					}
					else if (sensorLower === 'nvme' && (labelLower === 'composite' || !selected.nvme)) {
						card = {
							key: 'nvme',
							name: 'NVMe',
							desc: sensorInfo.model || sensor,
							path: source.path,
							warm: 65,
							hot: 80
						};
					}
					else if (sensorLower.indexOf('pch') === 0 && !selected.pch) {
						card = {
							key: 'pch',
							name: tempText('Chipset', '芯片组', '晶片組'),
							desc: sensorInfo.model || sensor,
							path: source.path,
							warm: 75,
							hot: 90
						};
					}

					if (card)
						selected[card.key] = card;
				}
			}
		}

		return [ 'cpu', 'nvme', 'pch' ]
			.map(key => selected[key])
			.filter(Boolean);
	},

	render(data) {
		if (data) {
			if (!this.sensorsData) {
				this.sensorsData = data.sensors || {};
				this.sensorsPath = data.temp ? Object.keys(data.temp) : [];
			}

			this.tempData = data.temp || {};
		}

		if (!this.sensorsData || !this.tempData)
			return;

		let cards = this.collectCards();

		if (!cards.length)
			return E('em', {}, tempText('No temperature sensors available', '未找到温度传感器', '未找到溫度感測器'));

		let grid = E('div', { 'class': 'temp-argon-grid' }, cards.map(card => {
			let raw = this.tempData[card.path];
			let temp = (raw === undefined || raw === null || String(raw).trim() === '' || !Number.isFinite(Number(raw))) ? null : this.formatTemp(raw);
			let state = temp === null ? ' unavailable' : (temp >= card.hot ? ' hot' : (temp >= card.warm ? ' warm' : ''));
			let level = temp === null ? 0 : Math.max(0, Math.min(100, temp));

			return E('div', {
				'class': 'temp-argon-card' + state,
				'style': '--temp-level: ' + level + '%;'
			}, [
				E('div', { 'class': 'temp-argon-meta' }, [
					E('span', { 'class': 'temp-argon-name' }, card.name),
					E('span', { 'class': 'temp-argon-desc', 'title': card.desc }, tempModel(card.key, card.desc))
				]),
				E('span', { 'class': 'temp-argon-value' }, temp === null ? '--' : temp + ' °C')
			]);
		}));
		scheduleTempTheme();
		return grid;
	}
});
