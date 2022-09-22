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
                            sh './gradlew build'
                            sh './gradlew sonarqube \
                                -Dsonar.projectKey=sonarapp \
                                -Dsonar.host.url=http://SonarHostIP:9000 \
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
                            docker build -t ServerIP:8083/javaapp:${VERSION} .
                            docker login -u admin -p $nexuspass ServerIP:8083
                            docker push ServerIP:8083/javaapp:${VERSION}
                            docker rmi ServerIP:8083/javaapp:${VERSION}
                        '''
                    }
                }
            } 
        }
        stage ("Identifying Misconfiguration using datree in Helm charts"){
            steps{
                script{
                    dir('kubernetes/') {
                        withEnv(['DATREE_TOKEN=Datree-Token']) {
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
                                curl -u admin:$nexuspass http://ServerIP:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                                '''
                            }
                        }
                    }    
                }
            }
            
            stage('Manual Approval'){
                steps{
                    script{
                        timeout(8) {
                            mail bcc: '', body: "<br>JavaApp: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Go to build URL and Approve the deployment request <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "devdjango101@gmail.com";
                            input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')        
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
            stage('verifying app deployment'){
                steps{
                    script{
                        withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
                            sh 'kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl myjavaapp-myapp:8080'
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
