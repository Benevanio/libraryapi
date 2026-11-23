# ==============================================================================
#                      ESTÁGIO 1: BUILD DA APLICAÇÃO (BUILDER)
# ==============================================================================
FROM maven:3.9.9-eclipse-temurin-17-alpine AS builder

WORKDIR /build

# Copia a definição de dependências para aproveitar o cache de camadas
COPY pom.xml .

# Baixa as dependências do projeto
RUN mvn dependency:resolve -B

# Copia o código-fonte da aplicação
COPY src ./src

# Empacota a aplicação gerando o jar executável
RUN mvn clean package -DskipTests -B

# ==============================================================================
#                      ESTÁGIO 2: IMAGEM FINAL (RUNTIME OTIMIZADO)
# ==============================================================================
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="bene.santos"
LABEL description="Library API - Container Docker Otimizado"

WORKDIR /app

# Criação de grupo e usuário sem privilégios de root para conformidade de segurança
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copia o JAR executável gerado no estágio de build
COPY --from=builder /build/target/*.jar app.jar

# Atribui permissões adequadas
RUN chown -R appuser:appgroup /app

# Execução como usuário não-root
USER appuser

# Parâmetros de JVM otimizados para contêineres
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Porta padrão de escuta
EXPOSE 8080

# Checagem de saúde utilizando o endpoint do Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Comando de inicialização
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
