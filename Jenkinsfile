pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID='57f61366-b99f-4f48-8086-e8ad016e0a38'
        AZURE_TENANT_ID='9a53eaff-13c8-4a09-8ad6-4fa94ed5d56f'
    }

    stages {
        stage('Example') {
            steps {
                   withCredentials([usernamePassword(credentialsId: 'myAzureCredential', passwordVariable: 'AZURE_CLIENT_SECRET', usernameVariable: 'AZURE_CLIENT_ID')]) {
                            sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                            sh 'az account set -s $AZURE_SUBSCRIPTION_ID'
                            sh 'az ...'
                        }
            }
        }
    }
}
