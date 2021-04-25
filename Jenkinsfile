pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    environment {
        AZURE_SUBSCRIPTION_ID='57f61366-b99f-4f48-8086-e8ad016e0a38'
        AZURE_TENANT_ID='9a53eaff-13c8-4a09-8ad6-4fa94ed5d56f'
    }

    stages {
        stage('TerraForm initialization') {
          steps {
            sh 'terraform init'
          }
        }
        stage('TerraForm Deploy Infrastructure') {
          steps {
            script {
            def userInput = input(
              id: 'userInput', message: 'Enter username and password for application servers:',
              parameters: [
                string(defaultValue: 'None', description: 'password', name: 'Password'),
                string(defaultValue: 'None', description: 'username', name: 'Username'),
              ])
            // Save variables
            admin_password = userInput.Password?:''
            admin_username = userInput.Username?:''

            //echo to console
            echo ("Your password to Azure servers: ${admin_password}")
            echo ("Your username to Azure Servers: ${admin_username}")
            sh "terraform plan -input=false -var 'admin_password=${admin_password}' -var 'admin_username=${admin_username}'"
            }
          }
        }
    }
}
