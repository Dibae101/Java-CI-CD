pipeline{
    agent any
    environment {
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("sonar quality check"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarapp', variable: 'sonartoken') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube \
                                -Dsonar.projectKey=sonarapp \
                                -Dsonar.host.url=http://65.0.197.61:9000 \
                                -Dsonar.login=$sonartoken'
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
        stage ("Docker Build and Docker Push"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexuspass')]) {
                        sh '''
                            docker build -t 13.234.139.97:8083/javaapp:${VERSION} .
                            docker login -u admin -p $nexuspass 13.234.139.97:8083
                            docker push 13.234.139.97:8083/javaapp:${VERSION}
                            docker rmi 13.234.139.97:8083/javaapp:${VERSION}
                        '''
                    }
                }
            } 
        }
        stage ("Identifying Misconfiguration using datree in Helm charts"){
            steps{
                script{
                    dir('kubernetes/') {
                        withEnv(['DATREE_TOKEN=d500f3130c9836773fbb9af7f2254ab9f48436b30d1ca35210b626f0acd0245b']) {
                            sh 'helm datree test myapp/'
                        }
                    }
                }
            }
        }
        stage ("Pushing Helm Charts to Nexus"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexuspass')]) {
                        dir('kubernetes/') {
                            sh '''
                                helmversion=$( helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                                tar -czvf  myapp-${helmversion}.tgz myapp/
                                curl -u admin:$nexuspass http://13.234.139.97:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                                '''
                            }
                        }
                    }    
                }
            }
            stage('Deploying Application to K8s Cluster') {
                steps {
                    script{
                        withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
                            dir('kubernetes/') {
                                sh 'helm upgrade --install --set image.repository="13.234.139.97:8083/javaapp" --set image.tag="${VERSION}" myjavaapp myapp/ '
                            }
                        }
                    }
                }
            }
        }

    post {
	    always {
		    mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "devdjango101@gmail.com";  
		}
	}
}