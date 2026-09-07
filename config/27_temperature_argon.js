'use strict';
'require baseclass';
'require rpc';

/* Compact temperature cards for the LuCI status overview (Argon friendly). */
document.head.append(E('style', { 'type': 'text/css' }, `
.temp-argon-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
	gap: 12px;
	padding: 2px 0 14px;
}

.temp-argon-card {
	--temp-accent: #20b78a;
	position: relative;
	display: flex;
	align-items: center;
	justify-content: space-between;
	min-height: 72px;
	padding: 12px 16px 12px 19px;
	overflow: hidden;
	border: 1px solid var(--border-color-medium, rgba(120, 120, 120, .18));
	border-radius: 12px;
	background: var(--background-color-high, rgba(255, 255, 255, .82));
	box-shadow: 0 4px 15px rgba(0, 0, 0, .055);
}

.temp-argon-card::before {
	position: absolute;
	top: 0;
	bottom: 0;
	left: 0;
	width: 4px;
	background: var(--temp-accent);
	content: '';
}

.temp-argon-card.warm {
	--temp-accent: #f0ad4e;
}

.temp-argon-card.hot {
	--temp-accent: #e65353;
}

.temp-argon-meta {
	min-width: 0;
}

.temp-argon-name {
	display: block;
	font-size: 15px;
	font-weight: 600;
	line-height: 1.35;
}

.temp-argon-desc {
	display: block;
	margin-top: 3px;
	opacity: .56;
	font-size: 11px;
	line-height: 1.2;
}

.temp-argon-value {
	flex: 0 0 auto;
	margin-left: 16px;
	color: var(--temp-accent);
	font-size: 25px;
	font-weight: 700;
	font-variant-numeric: tabular-nums;
	letter-spacing: -.5px;
}

:root[data-darkmode="true"] .temp-argon-card {
	background: var(--background-color-high, rgba(34, 39, 46, .88));
	box-shadow: 0 4px 16px rgba(0, 0, 0, .2);
}

@media (max-width: 600px) {
	.temp-argon-grid {
		grid-template-columns: 1fr;
	}
}
`));

return baseclass.extend({
	title: '硬件温度',

	sensorsData: null,

	tempData: null,

	sensorsPath: [],

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
							desc: 'Intel Core i3-10300T',
							path: source.path,
							warm: 75,
							hot: 90
						};
					}
					else if (sensorLower === 'nvme' && (labelLower === 'composite' || !selected.nvme)) {
						card = {
							key: 'nvme',
							name: 'NVMe',
							desc: '固态硬盘',
							path: source.path,
							warm: 65,
							hot: 80
						};
					}
					else if (sensorLower.indexOf('pch') === 0 && !selected.pch) {
						card = {
							key: 'pch',
							name: '芯片组',
							desc: 'Intel PCH',
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
			return E('em', {}, '未找到可显示的温度传感器');

		return E('div', { 'class': 'temp-argon-grid' }, cards.map(card => {
			let raw = this.tempData[card.path];
			let temp = (raw === undefined || raw === null) ? null : this.formatTemp(raw);
			let state = temp === null ? '' : (temp >= card.hot ? ' hot' : (temp >= card.warm ? ' warm' : ''));

			return E('div', { 'class': 'temp-argon-card' + state }, [
				E('div', { 'class': 'temp-argon-meta' }, [
					E('span', { 'class': 'temp-argon-name' }, card.name),
					E('span', { 'class': 'temp-argon-desc' }, card.desc)
				]),
				E('span', { 'class': 'temp-argon-value' }, temp === null ? '--' : temp + ' °C')
			]);
		}));
	}
});
