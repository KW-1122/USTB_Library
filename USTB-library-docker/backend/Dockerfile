# 阶段 1: 构建
# 使用 eclipse-temurin 版本的 maven，下载成功率更高
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
# 同样跳过测试加速
RUN mvn clean package -DskipTests

# 阶段 2: 运行
# 使用 eclipse-temurin 作为运行环境，替代老的 openjdk
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]