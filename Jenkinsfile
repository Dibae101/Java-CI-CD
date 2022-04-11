pipeline{
    agent any 
    stages{
        stage("sonar quality check"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarapp') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube' 
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