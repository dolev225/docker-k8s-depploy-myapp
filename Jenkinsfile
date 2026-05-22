def appname = "test-app"
def repo = "kfire312"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

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
              echo " docker build -t ${appimage}:${apptag} ."
              sleep 5
              echo "--------------------------------------------------------------"
              echo "Docker image built successfully: ${appimage}:${apptag}"
              echo "--------------------------------------------------------------"
 
                        
                    }
                }
            }
        }
    }
