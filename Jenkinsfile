pipeline{
    agent any 
    stages{
        stage("sonar quality check"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarapp') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube \
                                -Dsonar.projectKey=sonarapp \
                                -Dsonar.host.url=http://65.0.197.61:9000 \
                                -Dsonar.login=3a56bb5263914f5f26e56838e3ca509398aa7c5e'
                    }

                    timeout(activity: true, time: 2) {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }  
            }
        }
    }
}