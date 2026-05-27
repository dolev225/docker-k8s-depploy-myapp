def appname = "test-2"
def repo = "dolev1234" 
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

def kubernetesurl = "https://kubernetes.default.svc"

podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'helm', 
        image: 'alpine/helm:3.14.0',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'bandit',
        image: 'pyupio/bandit:latest',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'trivy',
        image: 'aquasec/trivy:latest',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', 
        privileged: true,      
        args: '--storage-driver=vfs' 
    )], 
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
  ]) {
    
    node(POD_LABEL) {
        
        stage('check SCM') {
            container('jnlp') {
                echo "Checking out code from Git..."
                checkout scm 
            }
        } 
        
        stage('Linting') {
            // הרצה מקבילית של שלבי הצינור (Pipeline Scripted Parallel)
            parallel(
                'flake8 check': {
                    echo "Running flake8 command..."
                    // כאן תבוא הפקודה האמיתית, למשל: sh 'flake8 .'
                },
                'Shell check': {
                    echo "Running Shell check..."
                },
                'Hadolint Check': {
                    echo "Running Hadolint command..."
                }
            )
        }
        
        stage('Build Docker Image') {
            container('docker') { 
                echo "--------------------------------------------------------------"
                echo "Building docker image..."
                echo "--------------------------------------------------------------"
                sh "docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
            }
        }
        
        stage('Security Scanning') {
            parallel(
                'Trivy Check': {
                    container('trivy') {
                        // שים לב: שיניתי ל-fs (File System) כי אימג' ה-Docker נמצא בקונטיינר אחר
                        sh "trivy fs ." 
                    }
                },
                'Bandit Check': {
                    container('bandit') {
                        sh "bandit -r ."
                    }
                }
            )
        }   

        stage('Push Image') {
            container('docker') {  
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh """
                        echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${appimage}:${apptag}
                    """
                }
            }
        }
            
        stage('Helm Install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                sh "helm template ${appname} ./chart"
            }
        }
        
    } // end of node
} // end of podTemplate
