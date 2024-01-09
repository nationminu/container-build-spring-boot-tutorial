# Getting Started

## Dockerfile build
> application-local.properties
```
## 컨테이너 이미지 생성 Dockerfile

###############################
## 빌드 이미지 / gradle:8-jdk17
###############################

# 런타임 커맨드 :
# docker build -t local/demo .

FROM docker.io/library/gradle:8-jdk17 AS BUILDER

# 컨테이너 기본 디렉터리 설정
WORKDIR /app-builder/

# 로컬에서 빌드 이미지로 소스 복사
COPY . /app-builder/

## 빌드 실행
RUN gradle clean && gradle build -x test


#############################
## 런타임 이미지 / openjdk:17 ##
#############################

# 런타임 커맨드 :
# docker run --rm -p 8080:8080 local/demo

FROM docker.io/library/openjdk:17 as RUNNER

ENV RUNTIME_NAME=demo
ENV RUNTIME_PROFILE=local
ENV RUNTIME_PORT=8080

# 컨테이너 기본 디렉터리 설정
WORKDIR /app-runner/

# 빌드 이미지에서 런타임 파일만 런타임 이미지로 복사.
COPY --from=BUILDER /app-builder/build/libs/app.jar /app-runner/app.jar

# 컨테이너 실행 파일 복사 / ENTRYPOINT 설정
COPY ./docker-entrypoint.sh /app-runner/docker-entrypoint.sh

# 서비스 포트
EXPOSE ${RUNTIME_PORT}

CMD [ "/app-runner/docker-entrypoint.sh" ]
```
| docker-entrypoint.sh
```
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
```
| docker build
```
docker build -t local/demo:latest .
```

## spring boot properties
> application-local.properties
```
spring.config.activate.on-profile=local

spring.datasource.url=jdbc:mysql://${MYSQL_HOST:localhost}:3306/demo
spring.datasource.username=demo
spring.datasource.password=demo
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

docker run local/demo:latest
```

> application-docker.properties
```
spring.config.activate.on-profile=docker

spring.datasource.url=jdbc:mysql://${MYSQL_HOST:db}:3306/demo
spring.datasource.username=demo
spring.datasource.password=demo
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

docker run -e RUNTIME_PROFILE=docker local/demo:latest
```



## docker compose
| compose.yaml
```
---
version: '3.9'

services:
  # Docker build
  build:
    build: .
    image: local/demo:latest
    profiles: ["build"]

  # Demo Container
  demo:
    image: local/demo:latest
    profiles: ["demo"]
    ports:
      - "8080:8080"
    environment:
      TZ: "Asia/Seoul"
      RUNTIME_PROFILE: docker

  # Database Container
  db:
    image: mysql:latest
    profiles: ["", "demo", "db"]
    ports:
      - "3306:3306"
    command: --lower_case_table_names=1
    environment:
      TZ: "Asia/Seoul"
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: demo
      MYSQL_USER: demo
      MYSQL_PASSWORD: demo
```
| docker-compose up
```
# build
docekr-compose --profile build build

# run
docekr-compose --profile demo up -d

# stop
docekr-compose --profile demo down
```