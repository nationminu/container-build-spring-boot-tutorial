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