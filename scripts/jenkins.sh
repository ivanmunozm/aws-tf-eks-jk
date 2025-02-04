# Usa la imagen oficial de Jenkins como base
FROM jenkins/jenkins:latest

# Cambia a usuario root para instalar dependencias
USER root

# Define versiones como variables de entorno
ENV MAVEN_RELASE=3 \
    MAVEN_VERSION=3.9.9 \
    MAVEN_HOME=/opt/maven

# Capa 1: Actualiza el sistema y herramientas básicas
RUN yum update -y && \
    yum install -y ca-certificates curl wget unzip tar shadow-utils

# Capa 2: Instala Docker CLI
RUN amazon-linux-extras enable docker && \
    yum install -y docker && \
    yum clean all

# Capa 3: Agrega el grupo docker y agrega Jenkins al grupo
RUN groupadd -g 999 docker || true && usermod -aG docker jenkins

# Capa 4: Descarga e instala Maven
RUN wget --no-verbose https://downloads.apache.org/maven/maven-${MAVEN_RELASE}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -P /tmp/ && \
    tar xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn && \
    rm /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Capa 5: Ajusta permisos y limpia
RUN chown -R jenkins:jenkins /opt/maven

# Cambia de nuevo al usuario jenkins para ejecutar Jenkins
USER jenkins

# Configura la variable de entorno para Maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"
