pipeline {

  environment {
    dockerimagename = "ariadne/httpd"
    dockerImage = ""
    KUBECONFIG = '/home/giuseppe/.kube/config'
    NAMESPACE = 'default'

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
          withCredentials([usernamePassword(credentialsId: 'kubeconfig-credentials', usernameVariable: 'KUBE_USER', passwordVariable: 'KUBE_PASS')]) {
            sh "echo $KUBE_USER > /tmp/kubeconfig"
            sh "echo $KUBE_PASS >> /tmp/kubeconfig"
            sh "kubectl config set-credentials jenkins --username=$KUBE_USER --password=$KUBE_PASS --kubeconfig=${env.KUBECONFIG}"
          }
          sh "kubectl config set-context jenkins --cluster=kubernetes --user=jenkins --kubeconfig=${env.KUBECONFIG}"
          sh "kubectl config use-context jenkins --kubeconfig=${env.KUBECONFIG}"

          // Set the namespace for deployment
          sh "kubectl config set-context --current --namespace=${env.NAMESPACE}"
         // Deploy the manifest using kubectl
          sh "kubectl apply -f deployment.yml"

        }  
      }

    }

}

}
