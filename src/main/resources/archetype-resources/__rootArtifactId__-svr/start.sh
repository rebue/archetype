#!/bin/sh
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
java -Xbootclasspath/a:"$SHELL_FOLDER"/src/main/resources/ -jar "$SHELL_FOLDER"/target/${projectName}-svr-${version}.jar