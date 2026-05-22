def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = '${appimage}:${env.BUILD_NUMBER}'

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
        
        stage('Build & Push Image') {
            steps {
                script {
              echo "--------------------------------------------------------------"
              echo "Building docker image..."
              echo "--------------------------------------------------------------"
              sh " docker build -t ${apptag} ."
              sleep 5
              echo "--------------------------------------------------------------"
              echo "Docker image built successfully:${apptag}"
              echo "--------------------------------------------------------------"


         stage('Login and Push') {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {

                sh """
                    echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin
                    docker push $appimage:$apptag
                """
                    
                }
            }
                        
                    }
                }
            }
        }
    }
