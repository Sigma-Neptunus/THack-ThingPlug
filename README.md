# ThinkPlug for T HackAThon 2nd

## Customizing Sensor List on Edison
To edit sensor list, edit **app.js** and **edisonSensors.js**

1. Declare sensor list in **app.js**
```javascript
DEVICE = [{
	deviceAddress: device0Id,
	sensors: [
		...
		{
			id: [device0Id, 'string'].join('-'),
			type: 'string',
			name: 'platform',
			notification: false
		},
		{
			id: [device0Id, 'number'].join('-'),
			type: 'number',
			name: 'RAMtotal',
			notification: false
		},
		{
			id: [device0Id, 'led'].join('-'),
			type: 'powerSwitch',
			name: 'led',
			notification: false
		}
	]
}];
```

2. Control sensors in **edisonSensors.js**
```javascript
board.on('ready', function() {
	...
	
	sef.actions = {
		led: {
			on: function(options) {
				var led = sensors.led.instance;
				led.on();
				var dur = Number(options && options.duration);
				if (dur) {
					if (sensors.led.timer) {
						clearTimeout(sensors.led.timer);
					}
					sensors.led.timer = setTimeout(function () {
						led.off();
					}, dur);
				}
			},
			off: _.bind(sensors.led.instance.off, sensors.led.instance)
		}
	};
	
	...
});
```

```javascript
...
_.each(['button', 'touch'], function (sname) {
	sensors[sname].instance.on('press', function() {
		logger.info('[event] press', sname, 1);
		self.emit('event', sname, 1);
	});
	sensors[sname].instance.on('release', function() {
		logger.info('[event] release', sname, 0);
		self.emit('event', sname, 0);
	});
});
...
```

3. Reboot or restart **tp.sh** and **driver.sh**
```
cd <path-to-tp-directory>(Usually /opt/tp/)
ps | grep app
Kill <process id>
./tp.sh restart; ./driver.sh restart
```
