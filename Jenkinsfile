pipeline {
  agent any
  stages {
    stage('PeptideCode') {
      steps {
        sh 'peptide'
      }
    }
    stage('BuildVMImage') {
      steps {
        sh 'shellscript'
      }
    }
    stage('overwrite-azure-deployment-parameters') {
      steps {
        sh 'overwrite-azure-deployment-parameters.sh'
      }
    }
    stage('deploy-vm-image') {
      steps {
        sh 'deploy-vm-image.sh'
      }
    }
  }
}