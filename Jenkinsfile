pipeline {

  environment {
    dockerimagename = "ariadne/httpd"
    dockerImage = ""
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
        az login --identity --username 1a53ccb7-bb8f-442b-a668-72bb178781fe
        az acr login --name testgiuseppeecr
        docker tag "${dockerimagename}:latest" testgiuseppeecr.azurecr.io/${dockerimagename}:latest
        docker push testgiuseppeecr.azurecr.io/${dockerimagename}:latest  
        '''
      }
    }


    /*stage('Deploying container to Kubernetes') {
      steps{
       script {
          withKubeConfig(credentialsId: 'docker-desktop', serverUrl: 'https://kubernetes.docker.internal:6443')

        }   
        
      }
    }*/

  }
}
