def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}" 

pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            // תיקון סינטקס: שימוש ב-containerTemplates (ברבים) עבור הרשימה
            containerTemplates ([
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
            // תיקון סינטקס: הגדרת ה-volume במבנה שהתוסף מקבל
            workspaceVolume emptyDirWorkspaceVolume()
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        } // סוף שלב Checkout (תוקן - היה חסר בקוד שלך)
        
        stage('Build') {
            steps {
                container('docker') {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image..."
                    echo "--------------------------------------------------------------"
                    sh "docker build -f dockerfile -t ${appimage}:${apptag} ."
                    sleep 5
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"

                    withCredentials([usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        echo "--------------------------------------------------------------"
                        echo "Docker login" 
                        echo "--------------------------------------------------------------"
                        sh "echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin"
                        echo "--------------------------------------------------------------"
                        echo "Docker login successfully"
                        echo "--------------------------------------------------------------"
                        echo "--------------------------------------------------------------"
                        echo "Docker push to docker hub "
                        echo "--------------------------------------------------------------"
                        sh "docker push ${appimage}:${apptag}"
                        echo "--------------------------------------------------------------"
                        echo "Docker image pushed successfully: ${appimage}:${apptag}"
                        echo "--------------------------------------------------------------"
                    }
                }
            }
        } // סוף שלב Build (תוקן)

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
    } // סוף stages
} // סוף pipeline
