# Usar imagen base de OpenJDK
FROM openjdk:17-jdk-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivo Java al contenedor
COPY HelloWorld.java .

# Compilar el programa Java
RUN javac HelloWorld.java

# Ejecutar la aplicación Java
CMD ["java", "HelloWorld"]