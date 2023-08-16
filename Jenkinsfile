pipeline {

  triggers {
    pollSCM('') // Enabling being build on Push
  }

  environment {
    dockerimagename = "ariadne/httpd"
    dockerImage = ""
    identityid = "1a53ccb7-bb8f-442b-a668-72bb178781fe"
    acrname = "testgiuseppeecr" 
  }

  agent any

  stages {

    stage('Checkout Source') {
      steps {
        git 'https://github.com/ariadnefranzesegiuseppe/jenkins-repo.git'
      }
    }

    stage('Build image') {
      steps{
        script {
          dockerImage = docker.build dockerimagename
        }
      }
    }

    stage('Login to ACR'){
      steps{
        sh '''
        az login --identity --username "${identityid}"
        az acr login --name "${acrname}" 
        '''
      }
    }

    stage('Push to ACR'){
      steps{
        sh '''
        docker tag "${dockerimagename}:latest" ${acrname}.azurecr.io/${dockerimagename}:latest
        docker push ${acrname}.azurecr.io/${dockerimagename}:latest
        docker image rm -f "${dockerimagename}:latest" ${acrname}.azurecr.io/${dockerimagename}:latest
        '''
      }
    }

    /*stage('Connect to AKS'){
      steps{
        sh '''
        az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
        '''
      }
    }*/




    /*stage('Deploying container to Kubernetes') {
      steps{
       script {
          withKubeConfig(credentialsId: 'docker-desktop', serverUrl: 'https://kubernetes.docker.internal:6443')

        }   
        
      }
    }*/

  }
}
