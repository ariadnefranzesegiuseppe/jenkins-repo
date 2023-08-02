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


    stage('Deploying container to Kubernetes') {
     withKubeConfig([credentialsId: 'docker-desktop', serverUrl: 'https://kubernetes.docker.internal:6443']) {
      sh 'kubectl apply -f deployment.yml'
     }
    }

  }

}
