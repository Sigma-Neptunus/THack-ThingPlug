#!/bin/sh

MODEL=poky
if [ -z $BASE_DIR ]; then
  BASE_DIR=`readlink -f $(dirname "$0")`
fi

TASK="node"

OPTIONS=
APP_DIR="$BASE_DIR/thingplus-driver"
LOG_DIR="$BASE_DIR/log"

PID_FILE="$BASE_DIR/.driver.pid"
#if [ -d /tmp ]; then
#  LOCK_FILE="/tmp/driver.lock"
#else
#  LOCK_FILE="$BASE_DIR/driver.lock"
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
if [ ! -d $LOG_DIR ] ; then
  mkdir -p $LOG_DIR
fi

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
  if check_running ; then
    echo "already running"
  else
    cd $APP_DIR
    $CMD 2>&1 >> $LOG_DIR/driver.log &
    echo $! > $PID_FILE;
  fi
}

startup() {
  #recover rsync if needed
  if check_running ; then
    echo "already running"
  else
    cd $APP_DIR
    $CMD 2>&1 >> $LOG_DIR/driver.log
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

  setup)
    #setup only
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|setup|startup}"
    #rm -f $LOCK_FILE
    exit 1
esac

#rm -f $LOCK_FILE
