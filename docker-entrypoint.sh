#!/usr/bin/env sh

## JAVA_OPTS
if [ "e${JAVA_OPTS}" == "e" ]; then

    JAVA_OPTIONS="-D[SERVER_NAME=${RUNTIME_NAME}]"
    JAVA_OPTIONS="${JAVA_OPTIONS} -Dspring.profiles.active=${RUNTIME_PROFILE} -Dserver.port=${RUNTIME_PORT}"
    JAVA_OPTIONS="${JAVA_OPTIONS} -Djava.security.egd=file:/dev/./urandom"
else
    JAVA_OPTIONS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"
fi

printf "========================================================================= \n\n"
printf "Bootstrap Environment \n\n"
printf "JAVA_OPTS: %s \n" ${JAVA_OPTIONS}
printf "\n"
printf "========================================================================= \n\n"

java ${JAVA_OPTIONS} -jar /app-runner/app.jar