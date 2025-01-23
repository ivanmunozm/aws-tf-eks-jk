#!/bin/bash

set -e  # Salir si ocurre un error
set -o pipefail  # Capturar errores en pipes

# Función para mostrar mensajes
log() {
  echo "[INFO] $1"
}

log "Actualizando la lista de paquetes..."
sudo dnf update -y

log "Instalando Amazon Corretto 17..."
sudo dnf install -y java-17-amazon-corretto

log "Descargando y configurando la clave de Jenkins..."
JENKINS_REPO_URL="https://pkg.jenkins.io/redhat-stable/jenkins.repo"
JENKINS_KEY_URL="https://pkg.jenkins.io/redhat-stable/jenkins.io.key"

# Descargar el repositorio y la clave
sudo curl -o /etc/yum.repos.d/jenkins.repo "$JENKINS_REPO_URL" || {
  echo "[ERROR] No se pudo descargar el repositorio de Jenkins"
  exit 1
}

sudo rpm --import "$JENKINS_KEY_URL" || {
  echo "[ERROR] No se pudo importar la clave GPG de Jenkins"
  exit 1
}

log "Limpiando paquetes en caché..."
sudo dnf clean packages
sudo dnf clean all

log "Instalando Jenkins..."
if ! sudo dnf install -y jenkins; then
  log "[ERROR] La instalación de Jenkins falló. Intentando con --nogpgcheck..."
  sudo dnf install -y --nogpgcheck jenkins || {
    echo "[ERROR] La instalación de Jenkins falló incluso con --nogpgcheck"
    exit 1
  }
fi

log "Habilitando y arrancando el servicio Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

log "Esperando 10 segundos para asegurarse de que Jenkins esté ejecutándose correctamente..."
sleep 10

log "Descargando Terraform versión 1.6.5..."
TERRAFORM_ZIP="terraform_1.6.5_linux_amd64.zip"
wget -q "https://releases.hashicorp.com/terraform/1.6.5/$TERRAFORM_ZIP" || {
  echo "[ERROR] No se pudo descargar Terraform"
  exit 1
}

log "Instalando herramientas necesarias para descomprimir..."
sudo dnf install -y unzip

log "Descomprimiendo el archivo de Terraform..."
unzip -q "$TERRAFORM_ZIP" || {
  echo "[ERROR] No se pudo descomprimir Terraform"
  exit 1
}

log "Moviendo el binario de Terraform al directorio /usr/local/bin/..."
sudo mv terraform /usr/local/bin/ || {
  echo "[ERROR] No se pudo mover el binario de Terraform"
  exit 1
}

log "Limpiando archivos temporales..."
rm -f "$TERRAFORM_ZIP"

log "Verificando la instalación de Terraform..."
terraform version || {
  echo "[ERROR] Terraform no se instaló correctamente"
  exit 1
}

log "Instalando Docker..."
sudo dnf install -y docker

log "Habilitando y arrancando el servicio Docker..."
sudo systemctl enable docker
sudo systemctl start docker

log "Agregando el usuario actual al grupo docker..."
sudo usermod -aG docker $USER || {
  echo "[ERROR] No se pudo agregar el usuario al grupo Docker"
  exit 1
}

log "Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION="2.21.0"
sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || {
  echo "[ERROR] No se pudo descargar Docker Compose"
  exit 1
}

sudo chmod +x /usr/local/bin/docker-compose

log "Verificando la instalación de Docker Compose..."
docker-compose --version || {
  echo "[ERROR] Docker Compose no se instaló correctamente"
  exit 1
}

log "El script se ejecutó correctamente. Jenkins, Terraform, Docker y Docker Compose están instalados y configurados."
