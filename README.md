# kubernetes_docker
 HelloWorld.java - Aplicación Java simple que
   imprime "Hola Mundo desde Java en Docker!"

  Dockerfile - Configuración Docker que:
  - Usa OpenJDK 17 como imagen base
  - Copia el archivo Java
  - Compila el código
  - Ejecuta la aplicación

  Para usar:
  # Construir la imagen
  docker build -t java-hello .

  # Ejecutar el contenedor
  docker run java-hello