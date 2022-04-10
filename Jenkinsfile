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
                    withSonarQubeEnv(credentialsId: 'sonar-tc') {
                            sh 'chmod +x gradlew'
                            -Dsonar.projectKey=b0f92ed26037e398b0f1122c06d6a4c2693e15af \
                            -Dsonar.projectName=Java-sample \
                            sh './gradlew sonarqube'
                    }  
                }
            }
        }
    }
}