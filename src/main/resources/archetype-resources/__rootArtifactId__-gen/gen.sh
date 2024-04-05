#!/bin/sh
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
java -jar "$SHELL_FOLDER"/target/${projectName}-gen-${version}.jar