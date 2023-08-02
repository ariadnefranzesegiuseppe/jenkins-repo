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
      steps {
        script {
          kubernetesDeploy(configs: "deployment.yml")
        }
      }
    }

  }

}
