# JENKINS-REPO #

Passi seguiti per creare una Pipeline per la build di un'immagine Docker e il deploy su AKS.
Ho utilizzato GitHub perchè ho meno problemi di permessi ma per GitLab dovrebbe essere molto simile.

### INSTALLAZIONE JENKINS AZURE VM###
- Oracle Linux 8.6 (RHEL based, dovrebbero darci una vm simile)
- Problemi Firewall -> firewall-cmd --add-port=80/tcp --permanent && firewall-cmd --reload
- user: azureuser

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
Durante la prima configurazione da browser scegliere di installare i plugin suggeriti, 
poi installare: Azure Commons Plugin, Azure CLI Plugin, Azure Container Registry Tasks Plugin, Azure Credentials, Azure SDK API Plugin, Docker API Plugin, Docker Commons Plugin, Docker Pipeline, Docker plugin, Git/GitHub vari, Kubernetes :: Pipeline :: DevOps Steps, Kubernetes CLI Plugin, Kubernetes Client API Plugin, Kubernetes Credentials Provider, Kubernetes plugin.
Alcuni di questi vengono installati come dipendenze di altri, per la maggior parte installa da solo le dipendenze tra i plugin ma non è sempre così.

Nel Jenkinsfile sono stati utilizzadi dei comandi bash, ma attraverso il corretto uso dei Plugin è possibile utilizzare anche una sintassi dedicata (possibilità da esplorare).

# POLICY AZURE#
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
Da browser raggiungere la macchina sulla porta 8080, nella parte a sinistra scegliere Gestisci Jenkins,
in basso scegliere Credenziali > System > Credenziali globali (non limitate) e aggiungere le credenziali quali utente e password (non è la cosa più sicura, bisognerebbe generare un token da GIT e creare una coppia di chiavi da salvare il Jenkins come secret come spiegato qui: https://www.youtube.com/watch?v=jSm0YZ-NQAc ).
Nel menù principale (Dashboard) scegliere Nuovo Elemento > Multibranch Pipeline e inserire il nome.
Scegliere un Display Name, aggiungere in Branch Sources una sorgente di tipo Git/GutHub e inserire URL e credenziali, scegliere il path del Jenkinsfile e lasciare le altre configurazioni di default.

Nell'interfaccia di Git, in Settings > Webhooks inserire la URL (tipo http://ip:8080/github-webhook/), Content Type (application/x-www-form-urlencoded) e selezionare Pushes e Pull requests come eventi e creare il webhook.
N.B. bisogna aprire i NetworkSecurityGroup a tutti sulla porta 8080 per permettere al Git di raggiungere la macchina.

### PASSI DA SEGUIRE ###
1. Build docker image
2. ACR login
3. ACR push (remove image locally)
4. Replace image in k8s manifest
5. AKS login
6. AKS apply (in teoria, con imagePullPolicy: always, basta aggiornare solo il manifest (YAML) del Deployment)

# TODO #
Login AKS cluster (az aks get-credentials --resource-group myResourceGroup --name myAKSCluster)
Sed docker image manifest
Apply manifest