pipeline{
    agent any
    stages{
        stage("Sonar Quality Check"){
            agent {
                docker {
                    image 'openjdk:11'
                }
            }
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube \
                                -Dsonar.projectKey=sonartest \
                                -Dsonar.host.url=http://65.0.197.61:9000 \
                                -Dsonar.login=be9693a1e60e319cbabb27ae3a64449bb5d8656b'
                    }  
                }
            }
        }
    }
}