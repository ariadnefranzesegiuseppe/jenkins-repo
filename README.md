# JENKINS-REPO #

Passi seguiti per creare una Pipeline per la build di un'immagine Docker e il deploy su AKS.

### INSTALLAZIONE JENKINS AZURE VM###
- Oracle Linux 8.6 (RHEL based, dovrebbe essere questa)
- Problemi Firewall -> firewall-cmd --add-port=80/tcp --permanent , firewall-cmd --reload

# JENKINS 2.401.3#
- sudo -i
- wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
- yum clean packages
- rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
- yum install git fontconfig java-11-openjdk -y
- yum install jenkins -y

# DOCKER (istruzioni Oracle Linux)#
- dnf install -y dnf-utils zip unzip
- dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
- dnf remove -y runc
- dnf install -y docker-ce --nobest
- systemctl start docker.service
- systemctl enable docker.service
- groupadd docker
- usermod -aG docker azureuser
- usermod -aG docker jenkins
- newgrp docker
- systemctl restart jenkins
OPZIONALI MA POTREBBERO SERVIRE
- chown azureuser:azureuser /home/azureuser/.docker -R
- chmod g+rwx "$HOME/.docker" -R


# AZURE CLI #
- rpm --import https://packages.microsoft.com/keys/microsoft.asc
- dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
- dnf install azure-cli -y



# JENKINS PLUGINS #


IAM Role?
Non sono riuscito a capire come replicare gli IAM Role su Azure, ma a quanto pare è possibile creare delle Managed Identity.

#creo l'identity (Managed Identities)
- az identity create --resource-group myResourceGroup --name myidentity
- userID=$(az identity show --resource-group myResourceGroup --name myidentity --query id --output tsv)
- spID=$(az identity show --resource-group myResourceGroup --name myidentity --query principalId --output tsv)
#attacco l'identity alla vm
- az vm identity assign --resource-group myResourceGroup --name testvm --identities $userID
#ruolo per acrpull già esistente (in alternativa crearne uno custom e assegnarlo)
- resourceID=$(az acr show --resource-group myResourceGroup --name myContainerRegistry --query id --output tsv)
- az role assignment create --assignee $spID --scope $resourceID --role acrpull
#dalla VM
- az login --identity --username $userid
- az acr login --name myContainerRegistry
#installare kubectl
- az aks install-cli

#CONFIGURARE PIPELINE DA INTERFACCIA#
Raggiungere da browser la macchina sulla porta 8080,

### PASSI DA SEGUIRE ###
1. Build docker image
2. ACR login
3. ACR push (remove image locally)
4. Replace image in k8s manifest
5. AKS login
6. AKS apply (in teoria, con imagePullPolicy: always, basta aggiornare solo il manifest (YAML) del Deployment)