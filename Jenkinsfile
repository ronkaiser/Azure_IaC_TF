pipeline {
  agent any
  stages{
    stage('TerraForm initialization') {
      steps {
        sh 'terraform init'
      }
    }
    stage('TerraForm Deploy Infrastructure') {
      steps {
        sh 'terraform apply'
      }
    }
  }
}
