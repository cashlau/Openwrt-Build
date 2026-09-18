'use strict';
'require baseclass';
'require rpc';

var tempLang=String(document.documentElement.lang||L.env.lang||'en').toLowerCase();

function tempText(en,zh,tw){
	return /^zh/.test(tempLang)?(/tw|hk|hant/.test(tempLang)?(tw||zh):zh):en;
}

function tempModel(kind,value){
	var s=String(value||'');
	if(kind==='cpu') return s.replace(/\(R\)|\(TM\)/gi,'').replace(/\s+CPU\b/g,'').replace(/\s+@\s+.*$/,'').replace(/\s+/g,' ').trim();

	if(kind==='pch'){
		var n={cometlake:'Comet Lake',skylake:'Skylake',cannonlake:'Cannon Lake',tigerlake:'Tiger Lake',alderlake:'Alder Lake'};
		return s.replace(/pch_([a-z0-9]+)/gi,(m,f)=>n[f.toLowerCase()]?'Intel '+n[f.toLowerCase()]+' PCH':m);
	}

	if(kind.indexOf('wifi_')===0) return s.replace(/[\s_.·-]*phy\d+\s*$/i,'').trim();
	return s;
}

document.head.append(E('style',{type:'text/css'},`
.temp-argon-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:8px 24px;width:100%;padding:7px 14px 10px;margin:0;box-sizing:border-box}
.temp-argon-card{--temp-accent:#78dc91;--temp-track:#e5e9ed;display:grid;grid-template-columns:max-content minmax(0,1fr);align-items:center;column-gap:6px;width:100%;min-width:0;height:30px;padding:0;margin:0;box-sizing:border-box;background:transparent;border:0;box-shadow:none}
.temp-argon-grid.temp-wrapped .temp-argon-card{grid-template-columns:64px minmax(0,1fr)}
.temp-argon-meta{display:flex;align-items:center;min-width:0}
.temp-argon-name{font-size:13px;font-weight:600;line-height:1;color:#27334b;white-space:nowrap}
.temp-argon-progress{position:relative;width:100%;height:18px;min-width:0;overflow:hidden;background:var(--temp-track);border-radius:9px}
.temp-argon-fill{position:absolute;z-index:1;inset:0;width:100%;background:var(--temp-accent);border-radius:9px 2px 2px 9px;transform:scaleX(var(--temp-scale,0));transform-origin:left center;transition:transform .45s cubic-bezier(.4,0,.2,1),background-color .25s ease;will-change:transform}
.temp-argon-progress-text{position:absolute;z-index:2;inset:0;display:flex;align-items:center;justify-content:space-between;gap:8px;padding:0 8px;box-sizing:border-box;color:#26334a;font-size:10.5px;line-height:18px;pointer-events:none}
.temp-argon-model{flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.temp-argon-value{flex:0 0 auto;margin-left:6px;font-size:11px;font-weight:600;font-variant-numeric:tabular-nums;white-space:nowrap}

.temp-argon-card.warm{--temp-accent:#efb95e}
.temp-argon-card.hot{--temp-accent:#e87878}
.temp-argon-card.unavailable{--temp-accent:#aeb6c0}
.temp-argon-grid.temp-dark .temp-argon-card{--temp-track:#3b3f45}
.temp-argon-grid.temp-dark .temp-argon-name{color:#eef2f7}
.temp-argon-grid.temp-dark .temp-argon-progress-text{color:#e6edf3}
.temp-argon-grid.temp-dark .temp-argon-card:not(.warm):not(.hot):not(.unavailable){--temp-accent:#508b5e}
.temp-argon-grid.temp-dark .temp-argon-card.warm{--temp-accent:#8c6b35}
.temp-argon-grid.temp-dark .temp-argon-card.hot{--temp-accent:#934a4a}
.temp-argon-grid.temp-dark .temp-argon-card.unavailable{--temp-accent:#676e77}

.temp-title-wrap{display:inline-flex;align-items:center;gap:8px}
.temp-unit-switch{display:inline-flex;align-items:center;height:20px;border:1px solid #d9dee5;border-radius:5px;overflow:hidden;vertical-align:middle;font-weight:400}
.temp-unit-btn{height:20px;padding:0 6px;border:0;background:transparent;color:#8993a3;font-size:11px;line-height:20px;cursor:pointer;font-weight:500}
.temp-unit-btn+.temp-unit-btn{border-left:1px solid #d9dee5}
.temp-unit-btn.active{background:#eef2f5;color:#27334b;font-weight:700}
[data-darkmode="true"] .temp-unit-switch{border-color:#515761}
[data-darkmode="true"] .temp-unit-btn{color:#aeb7c4}
[data-darkmode="true"] .temp-unit-btn+.temp-unit-btn{border-left-color:#515761}
[data-darkmode="true"] .temp-unit-btn.active{background:#3b3f45;color:#eef2f7}

@media(max-width:600px){
	.temp-argon-grid{grid-template-columns:1fr;gap:6px;padding:7px 10px 9px}
	.temp-argon-grid.temp-wrapped .temp-argon-card{grid-template-columns:58px minmax(0,1fr)}
	.temp-argon-card{height:28px}
	.temp-argon-name{font-size:12px}
	.temp-argon-progress{height:17px}
	.temp-argon-progress-text{padding:0 7px;font-size:10px;line-height:17px}
	.temp-argon-value{margin-left:5px;font-size:10.5px}
}
`));

function syncTempTheme(){
	document.querySelectorAll('.temp-argon-grid').forEach(grid=>{
		let dark=false,e=document.documentElement.getAttribute('data-darkmode');
		if(e!=='true'&&e!=='false') e=document.body&&document.body.getAttribute('data-darkmode');

		if(e==='true'||e==='false') dark=e==='true';
		else for(let p=grid.parentElement;p;p=p.parentElement){
			let rgb=getComputedStyle(p).backgroundColor.match(/[\d.]+/g);
			if(!rgb||rgb.length<3||(rgb.length>3&&+rgb[3]<.9)) continue;
			dark=(+rgb[0]*.2126 + +rgb[1]*.7152 + +rgb[2]*.0722)<128;
			break;
		}
		grid.classList.toggle('temp-dark',dark);
	});
}

function syncTempLayout(grid){
	if(!grid) return;
	let cards=Array.from(grid.children);
	if(cards.length<2) return grid.classList.add('temp-wrapped');

	let top=cards[0].offsetTop;
	grid.classList.toggle('temp-wrapped',!cards.every(card=>Math.abs(card.offsetTop-top)<2));
}

var tempThemeFrame=null;

function scheduleTempTheme(){
	if(tempThemeFrame!==null) return;
	tempThemeFrame=requestAnimationFrame(()=>{
		tempThemeFrame=null;
		syncTempTheme();
	});
}

new MutationObserver(scheduleTempTheme).observe(document.documentElement,{
	subtree:true,attributes:true,attributeFilter:['class','style','data-darkmode','data-theme']
});

var tempColorScheme=window.matchMedia('(prefers-color-scheme:dark)');
if(tempColorScheme.addEventListener) tempColorScheme.addEventListener('change',scheduleTempTheme);
else tempColorScheme.addListener(scheduleTempTheme);

return baseclass.extend({
	title:tempText('Hardware temperature','硬件温度','硬體溫度'),

	sensorsData:null,tempData:null,sensorsPath:[],
	tempGrid:null,tempNodes:null,tempSignature:null,tempResizeObserver:null,

	tempUnit:'C',
	tempUnitSwitch:null,tempUnitC:null,tempUnitF:null,

	cpuModel:tempText('Unknown processor','处理器型号未知','處理器型號未知'),

	callSensors:rpc.declare({
		object:'luci.temp-status',method:'getSensors',expect:{'':{}}
	}),

	callTempData:rpc.declare({
		object:'luci.temp-status',method:'getTempData',params:['tpaths'],expect:{'':{}}
	}),

	callGetUnit:rpc.declare({
		object:'luci.temp-status',method:'getUnit',expect:{'':{}}
	}),

	callSetUnit:rpc.declare({
		object:'luci.temp-status',method:'setUnit',params:['unit'],expect:{'':{}}
	}),

	formatTemp(mc){
		return Number((mc/1000).toFixed(1));
	},

	displayTemp(temp){
		if(temp==null) return '--';
		return this.tempUnit==='F'
			? Number((temp*9/5+32).toFixed(1))+' °F'
			: temp+' °C';
	},

	setTempUnit(unit){
		unit=unit==='F'?'F':'C';
		this.tempUnit=unit;

		if(this.tempUnitC) this.tempUnitC.classList.toggle('active',unit==='C');
		if(this.tempUnitF) this.tempUnitF.classList.toggle('active',unit==='F');
		if(this.tempData) this.updateCards(this.collectCards());

		L.resolveDefault(this.callSetUnit(unit),null);
	},

	attachUnitSwitch(){
		if(!this.tempUnitSwitch){
			this.tempUnitC=E('button',{
				'class':'temp-unit-btn'+(this.tempUnit==='C'?' active':''),
				'type':'button'
			},'℃');

			this.tempUnitF=E('button',{
				'class':'temp-unit-btn'+(this.tempUnit==='F'?' active':''),
				'type':'button'
			},'℉');

			this.tempUnitSwitch=E('span',{'class':'temp-unit-switch'},[
				this.tempUnitC,this.tempUnitF
			]);

			this.tempUnitC.addEventListener('click',e=>{
				e.preventDefault();e.stopPropagation();
				this.setTempUnit('C');
			});

			this.tempUnitF.addEventListener('click',e=>{
				e.preventDefault();e.stopPropagation();
				this.setTempUnit('F');
			});
		}

		if(this.tempUnitSwitch.isConnected||!document.body) return;

		let walker=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT),node;

		while((node=walker.nextNode())){
			if(String(node.nodeValue||'').trim()!==this.title) continue;

			let parent=node.parentNode;
			if(!parent) break;

			let wrap=E('span',{'class':'temp-title-wrap'});
			parent.insertBefore(wrap,node);
			wrap.appendChild(node);
			wrap.appendChild(this.tempUnitSwitch);
			break;
		}
	},

	load(){
		if(!this.sensorsData){
			return Promise.all([
				L.resolveDefault(this.callSensors(),null),
				L.resolveDefault(this.callGetUnit(),{unit:'C'})
			]).then(result=>{
				let data=result[0]||{};
				data.unit=result[1]&&result[1].unit==='F'?'F':'C';
				return data;
			});
		}

		return this.sensorsPath.length
			? L.resolveDefault(this.callTempData(this.sensorsPath),null)
			: Promise.resolve(null);
	},

	collectCards(){
		let selected={};

		for(let group of Object.values(this.sensorsData||{}))
			for(let info of Object.values(group||[])){
				let sensor=String(info.title||info.item||''),sl=sensor.toLowerCase();
				let wifi=sl.match(/^(.+)_phy([0-9]+)$/);

				for(let source of Object.values(info.sources||[])){
					let label=String(source.label||source.item||'').replace(/_input$/,'').toLowerCase();
					let card=null;

					if(sl==='coretemp'&&label.includes('package id'))
						card={key:'cpu',name:'CPU',desc:info.model||this.cpuModel,path:source.path,warm:75,hot:90};

					else if(sl==='nvme'&&(label==='composite'||!selected.nvme))
						card={key:'nvme',name:'NVMe',desc:info.model||sensor,path:source.path,warm:65,hot:80};

					else if(sl.startsWith('pch')&&!selected.pch)
						card={key:'pch',name:tempText('Chipset','芯片组','晶片組'),desc:info.model||sensor,path:source.path,warm:75,hot:90};

					if(wifi&&!selected['wifi_'+wifi[2]])
						card={
							key:'wifi_'+wifi[2],
							name:tempText('Wi-Fi','无线网卡','無線網卡'),
							desc:info.model||wifi[1].toUpperCase(),
							path:source.path,warm:75,hot:90
						};

					if(card) selected[card.key]=card;
				}
			}

		return ['cpu','nvme','pch']
			.concat(Object.keys(selected).filter(k=>k.startsWith('wifi_')))
			.map(k=>selected[k]).filter(Boolean);
	},

	updateCards(cards){
		for(let card of cards){
			let raw=this.tempData[card.path];
			let temp=raw==null||String(raw).trim()===''||!Number.isFinite(Number(raw))
				? null:this.formatTemp(raw);

			let state=temp==null?' unavailable':temp>=card.hot?' hot':temp>=card.warm?' warm':'';
			let level=temp==null?0:Math.max(0,Math.min(100,temp));
			let n=this.tempNodes&&this.tempNodes[card.key];

			if(!n) continue;

			let modelText=tempModel(card.key,card.desc);
			if(card.key.indexOf('wifi_')===0) modelText=modelText.toUpperCase();

			let valueText=this.displayTemp(temp);

			n.row.className='temp-argon-card'+state;
			n.fill.style.setProperty('--temp-scale',level/100);
			n.model.textContent=modelText;
			n.model.title=card.desc;
			n.value.textContent=valueText;
			n.progress.title=card.desc+' / '+valueText;
		}
	},

	createGrid(cards){
		this.tempNodes={};

		this.tempGrid=E('div',{'class':'temp-argon-grid'},cards.map(card=>{
			let fill=E('div',{'class':'temp-argon-fill','style':'--temp-scale:0;transition:none;'});
			let modelText=tempModel(card.key,card.desc);

			if(card.key.indexOf('wifi_')===0) modelText=modelText.toUpperCase();

			let model=E('span',{'class':'temp-argon-model','title':card.desc},modelText);
			let value=E('span',{'class':'temp-argon-value'},'--');

			let progress=E('div',{'class':'temp-argon-progress'},[
				fill,E('div',{'class':'temp-argon-progress-text'},[model,value])
			]);

			let row=E('div',{'class':'temp-argon-card'},[
				E('div',{'class':'temp-argon-meta'},[
					E('span',{'class':'temp-argon-name'},card.name)
				]),
				progress
			]);

			this.tempNodes[card.key]={row,fill,model,value,progress};
			return row;
		}));

		this.updateCards(cards);

		if(this.tempResizeObserver) this.tempResizeObserver.disconnect();
		this.tempResizeObserver=new ResizeObserver(()=>syncTempLayout(this.tempGrid));
		this.tempResizeObserver.observe(this.tempGrid);

		requestAnimationFrame(()=>requestAnimationFrame(()=>{
			syncTempLayout(this.tempGrid);
			this.attachUnitSwitch();
			for(let n of Object.values(this.tempNodes||{})) n.fill.style.transition='';
		}));

		return this.tempGrid;
	},

	render(data){
		if(data){
			if(!this.sensorsData){
				this.sensorsData=data.sensors||{};
				this.sensorsPath=data.temp?Object.keys(data.temp):[];
				this.tempUnit=data.unit==='F'?'F':'C';
			}

			this.tempData=data.temp||{};
		}

		if(!this.sensorsData||!this.tempData) return;

		let cards=this.collectCards();

		if(!cards.length)
			return E('em',{},tempText(
				'No temperature sensors available',
				'未找到温度传感器',
				'未找到溫度感測器'
			));

		let signature=cards.map(c=>c.key+':'+c.path).join('|');

		if(!this.tempGrid||this.tempSignature!==signature){
			this.tempSignature=signature;
			this.createGrid(cards);
		}else{
			this.updateCards(cards);
		}

		scheduleTempTheme();

		requestAnimationFrame(()=>{
			syncTempLayout(this.tempGrid);
			this.attachUnitSwitch();
		});

		return this.tempGrid;
	}
});
