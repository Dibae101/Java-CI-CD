"pipeline"{
   "agent any
    stages"{
      "stage(""Sonar Quality Check"")"{
         "steps"{
            "script"{
               "withSonarQubeEnv(credentialsId":"sonarapp"")"{
                  "sh""chmod +x gradlew""sh""./gradlew sonarqube \\
                                -Dsonar.projectKey=sonarapp \\
                                -Dsonar.host.url=http://65.0.197.61:9000 \\
                                -Dsonar.login=545bf3352cace5bce9c03c6b8b7124f96d49b2f8"
               }"timeout(time":1,
               "unit":"HOURS"")"{
                  "def qg = waitForQualityGate()
                        if (qg.status !=""OK"")"{
                     "error""Pipeline aborted due to quality gate failure: ${qg.status}"
                  }
               }
            }
         }
      }
   }
}