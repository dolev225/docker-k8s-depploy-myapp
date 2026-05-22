def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}" // dolev1234/test-app
def apptag = "${env.BUILD_NUMBER}"  // רק מספר הבילד (למשל: 24)

pipeline {
    agent {
        node {
            label 'agent2' 
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push Docker Image') {
            agent {
                docker {
                    image 'docker:26'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"                    
                    sh "docker build -t ${appimage}:${apptag} ."
                    sleep 5
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"
                    echo "Connecting to Docker Hub..."

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub1',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        sh """
                            echo "\$DOCKER_TOKEN" | docker login -u "\$DOCKER_USER" --password-stdin
                            echo "--------------------------------------------------------------"
                            echo "Connection successful"
                            echo "--------------------------------------------------------------"
                            echo "Pushing image ${appimage}:${apptag} to the hub..."
                            echo "--------------------------------------------------------------"
                            echo "Push to the docker hub "
                            echo "--------------------------------------------------------------"
                            docker push ${appimage}:${apptag}
                            echo "--------------------------------------------------------------"
                            echo "Push to docker hub successful"
                            echo "--------------------------------------------------------------"
                        """
                    }
                }
            } 
        }

        stage('Deploy with Helm') {
            agent {
                docker {
                    image 'alpine/helm:3.14.0'
                }
            }
            steps {
                echo "------------------------ Running inside HELM container ------------------------"
                sh 'helm version'
                // פקודת ה-deploy העתידית שלך:
                // sh "helm upgrade --install ${appname} ./charts --set image.tag=${apptag}"
            } 
        }
    }
}
