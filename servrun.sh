#!/bin/sh

set -e

while getopts c:e: option
do
  case "${option}"
  in
    c) COMMAND=${OPTARG};;
    e) ENVIRONMENT=${OPTARG};;
  esac
done

if [ -z $ENVIRONMENT ]; then
  ENVIRONMENT="development"
fi

run_task() {

    CMD="perl api.pl daemon -m ${ENVIRONMENT} --listen http://127.0.0.1:8088 >/dev/null 2>&1 &"

    run () {
        eval $1
    }

    case "$COMMAND" in
    start)
      run "$CMD"
      return 0
      ;;
    stop)
      kill -TERM $(ps aux | grep '[p]erl api.pl' | awk '{print $2}')
      return 0
      ;;
    restart)
      kill -TERM $(ps aux | grep '[p]erl api.pl' | awk '{print $2}')
      run "$CMD"
      return 0
      ;;
    *)
      echo >&2 "Usage: $(basename "$0") -c <start|stop|restart>"
      exit 1
      ;;
    esac
}

run_task
exit 0
