pipeline{
    agent any
    stages{
        stage("Sonar Quality Check"){
            steps{
                    sh 'chmod +x gradlew'
                    sh './gradlew sonarqube \
                    -Dsonar.projectKey=sonartest \
                    -Dsonar.host.url=http://65.0.197.61:9000 \
                    -Dsonar.login=e252d2f6dfd2779c1b814f9fcf7f5384cce94bef'
            }
        }
    }
}