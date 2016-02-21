'use strict';
var path = require('path');

// curernt directory is {base_dir}/config
var baseDir = path.join(__dirname, '../../..');
//console.log('config __dirname', __dirname, baseDir);
module.exports = {
  'Init': {
    disableUI: true,
  },
  'Gateway': {
    'port': 8088,
    'CERT_FILE_PATH': path.join(baseDir, 'config/cert.p12'),
    'logBaseDir': path.join(baseDir, 'log/')
  },
  'Server': {
    'mqtt': {
      'host': 'mqtt.sp1.sktiot.com'
    },
    'service': {
      'host': 'www.sp1.sktiot.com'
    }
  },
  'Store': {
    'baseDir': path.join(baseDir, 'store/')
  },
  'Sync': {
    id: 'edison',
    password: 'r7UKI^.7~k014-u',
    host: 'rsync.thingplus.net'
  },
  DM: {
    poweroff: {
      shellCmd: 'sync; ../../tp.sh stop &',
      support: true,
    },
    reboot: {
      shellCmd: 'sync; ../../tp.sh restart &',
      support: true,
    },
    restart: {
      shellCmd: 'sync; ../../tp.sh restart &',
      support: true,
    },
    swUpdate: {
      internal: true,
      support: true,
    },
    swInfo: {
      internal: true,
      support: true,
    }
  },
};
