def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}" 

pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            containers ([
                containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest'),
                containerTemplate(
                    name: 'docker', 
                    image: 'docker:26-dind', 
                    privileged: true, 
                    args: '--storage-driver=vfs'
                ),
                containerTemplate(
                    name: 'helm', 
                    image: 'alpine/helm:3.14.0', 
                    ttyEnabled: true, 
                    command: 'cat'
                )
            ])
            volumes ([
                emptyDirVolume(mountPath: '/var/lib/docker', memory: false)
            ])
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build ') {
            steps {
                container('docker') {
                echo "--------------------------------------------------------------"
                echo "Building docker image..."
                echo "--------------------------------------------------------------"
                sh " docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
                        }
                    }
                }
                stage('Docker push ') {
            steps {
                container('docker') {
                echo "--------------------------------------------------------------"
                echo "Pushing to docker hub"
                echo "--------------------------------------------------------------"
                sh " docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "PUSH successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
                        }
                    }
                }
            } 
        }

        stage('Run Helm Template') {
            steps {
                container('helm') {
                    echo "--------------------------------------------------------------"
                    echo "Running Helm Template inside specialized container..."
                    echo "--------------------------------------------------------------"
                    sh "helm template ${appname} helm-charts/"
                }
            } 
        }
