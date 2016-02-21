#!/bin/sh

MODEL=poky

if [ -z $BASE_DIR ]; then
  LINK_DIR=$(readlink -f $0)
  if [ -n $LINK_DIR ]; then
    BASE_DIR=`readlink -f $(dirname $LINK_DIR)`
  else
    CUR_DIR=`dirname "$0"`
    BASE_DIR=`readlink -f $CUR_DIR`
  fi
fi

TASK="node"

OPTIONS=
APP_DIR="$BASE_DIR/thingplus-gateway/device"
LOG_DIR="$BASE_DIR/log"
STORE_DIR="$BASE_DIR/store"
#RSYNC_FILE="$APP_DIR/update/$MODEL/sync.sh"
BIN_PATH="$APP_DIR/update/$MODEL/bin"
#export NODE_CONFIG_DIR="$BASE_DIR/config"

PID_FILE="$BASE_DIR/.thingplus.pid"
#if [ -d /tmp ]; then
#  LOCK_FILE="/tmp/thingplus.lock"
#else
#  LOCK_FILE="$BASE_DIR/thingplus.lock"
#fi

#if [ ! -e $LOCK_FILE ]; then
#  trap "rm -f $LOCK_FILE; exit" INT TERM EXIT
#  touch $LOCK_FILE
#else
#  echo $0 is already running, remove "$LOCK_FILE" to exceute.
#  exit 1;
#fi

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

if [ -d $BIN_PATH ]; then
  pathadd $BIN_PATH
fi
if [ ! -f "$BASE_DIR/tp.sh" ]; then
  ln -s "$APP_DIR/update/$MODEL/files/tp.sh" "$BASE_DIR/tp.sh"
fi
if [ ! -d $LOG_DIR ] ; then
  mkdir -p $LOG_DIR
fi
if [ ! -d $STORE_DIR ] ; then
  mkdir -p $STORE_DIR
fi
if [ -n "$NODE_CONFIG_DIR" ]; then
  if [ ! -d "$NODE_CONFIG_DIR" ] ; then
    mkdir -p $NODE_CONFIG_DIR
  fi

  if [ ! -f "$NODE_CONFIG_DIR/default.js" ] ; then
    ln -s $APP_DIR/config/default.js $NODE_CONFIG_DIR/default.js
  fi

  if [ -f "$APP_DIR/update/$MODEL/files/node-config_local.json" ] ; then
    if [ ! -h "$NODE_CONFIG_DIR/local.json" ] ; then
      ln -s "$APP_DIR/update/$MODEL/files/node-config_local.json" "$NODE_CONFIG_DIR/local.json"
    fi
  fi
  if [ -f "$APP_DIR/update/$MODEL/files/node-config_local.js" ] ; then
    if [ ! -h "$NODE_CONFIG_DIR/local.js" ] ; then
      ln -s "$APP_DIR/update/$MODEL/files/node-config_local.js" "$NODE_CONFIG_DIR/local.js"
    fi
  fi
fi # -n "$NODE_CONFIG_DIR"

if [ -x $APP_DIR/app ] ;  then
  CMD="./app"
elif [ -x $APP_DIR/app.min ] ;  then
  CMD="./app.min"
elif [ -f $APP_DIR/app.js ] ;  then
  CMD="$TASK $OPTIONS app.js"
else
  CMD="$TASK $OPTIONS app.min.js"
fi

check_running() {
  if [ -f $PID_FILE ] ; then
    PID=`cat $PID_FILE`
    CHECK_PS=`ps | sed -n "/^ *${PID}/p"`
    if [ -n "$CHECK_PS" ]; then
      return 0;
    fi
    #return $? 
  fi

  return 1;
}

start() {
  #recover rsync if needed
  [ -n "$RSYNC_FILE" ] && $RSYNC_FILE -r

  if check_running ; then
    echo "already running"
  else
    cd $APP_DIR
    $CMD 2>&1 >> $LOG_DIR/thingplus.log &
    echo $! > $PID_FILE;
  fi
}

startup() {
  #recover rsync if needed
  [ -n "$RSYNC_FILE" ] && $RSYNC_FILE -r

  if check_running ; then
    echo "already running"
  else
    cd $APP_DIR
    $CMD 2>&1 >> $LOG_DIR/thingplus.log
    echo $! > $PID_FILE;
  fi
}

stop() {
  sync
  #pkill -F $PID_FILE 2> /dev/null;
  kill $(cat $PID_FILE) 2> /dev/null;
  rm -f $PID_FILE;
}

case "$1" in
  status)
    if check_running; then
      echo "running"
    else
      echo "stopped"
    fi
    ;;

  start)
    start
    ;;

  startup)
    startup
    ;;

  stop)
    stop
    ;;

  restart)
    stop
    sleep 5;
    start
    ;;

  update)
    [ -n "$RSYNC_FILE" ] && $RSYNC_FILE
    stop
    sleep 5;
    start
    ;;

  setup)
    #setup only
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|update|setup|startup}"
    #rm -f $LOCK_FILE
    exit 1
esac

#rm -f $LOCK_FILE
