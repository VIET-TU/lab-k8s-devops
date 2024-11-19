## build stage ##
FROM maven:3.8.3-openjdk-17 as build

WORKDIR ./src
COPY . .

RUN mvn install -DskipTests=true

## run stage ##
FROM openjdk:17-alpine

RUN unlink /etc/localtime;ln -s  /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
COPY --from=build src/target/spring-boot-ecommerce-0.0.1-SNAPSHOT.jar /run/spring-boot-ecommerce-0.0.1-SNAPSHOT.jar

EXPOSE 8080                                                                                                                                      
ENTRYPOINT java -jar /run/spring-boot-ecommerce-0.0.1-SNAPSHOT.jar