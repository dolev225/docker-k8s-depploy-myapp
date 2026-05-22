def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}" 

pipeline {
    agent {
        kubernetes {
            cloud 'kubernetes-local'
            defaultContainer 'jnlp'
            
            // תוספת קריטית 1: אומר לפוד בתוך קוברנטיס איך להגיע לג'נקינס שבחוץ
            jenkinsUrl 'http://host.docker.internal:8080'
            
            containerTemplates ([
                containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest'),
                containerTemplate(
                    name: 'docker', 
                    image: 'docker:26-dind', 
                    privileged: true, 
                    // תוספת קריטית 2: vfs לפעמים דורש הגדרת סירוס אבטחה ב-dind מקומי
                    args: '--storage-driver=vfs'
                ),
                containerTemplate(
                    name: 'helm', 
                    image: 'alpine/helm:3.14.0', 
                    ttyEnabled: true, 
                    command: 'cat'
                )
            ])
            workspaceVolume emptyDirWorkspaceVolume()
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push') {
            steps {
                container('docker') {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image..."
                    echo "--------------------------------------------------------------"
                    sh "docker build -f dockerfile -t ${appimage}:${apptag} ."
                    sleep 5

                    withCredentials([usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        sh """
                            echo "\$DOCKER_TOKEN" | docker login -u "\$DOCKER_USER" --password-stdin
                            docker push ${appimage}:${apptag}
                        """
                    }
                }
            }
        }

        stage('Run Helm Template') {
            steps {
                container('helm') {
                    echo "--------------------------------------------------------------"
                    echo "Running Helm Template..."
                    echo "--------------------------------------------------------------"
                    sh "helm template ${appname} helm-charts/"
                }
            } 
        }
    }
}
