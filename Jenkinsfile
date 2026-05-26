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
    
    // כל הצינור רץ בתוך ה-node
    node(POD_LABEL) {
        
        stage('check SCM') {
            container('jnlp') {
                echo "Checking out code from Git..."
                checkout scm 
            }
        } 
        
        stage('Linting') {
            container('jnlp') { // מריצים בתוך ה-agent הבסיסי
                parallel(
                    'flake8 check': {
                        echo "Running flake8 command..."
                        // פקודה עתידית: sh "flake8 ."
                    },
                    'Shell check': {
                        echo "Running Shell check command..."
                    },
                    'Hadolint Check': {
                        echo "Running Hadolint command..."
                    }
                )
            }
        }

        container('docker') {  
            stage('build') {
                echo "--------------------------------------------------------------"
                echo "Building docker image..."
                echo "--------------------------------------------------------------"
                sh "docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
            }
            
            stage('push') {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    // מירכאות בודדות למניעת חשיפת סיסמה ובעיות שרשור
                    sh '''
                        echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin
                        docker push \$appimage:\$apptag
                    '''
                }
            }
        } // סיום container docker
            
        stage('helm install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                sh "helm template ${appname} ./chart --set image.tag=${apptag}"
            }
        }

        stage('Security Scanning') {
            parallel(
                'Trivy Check': {
                    container('trivy') {
                        echo "Running Trivy Scan..."
                        // סריקת האימג' המקומי שנבנה בשלבים הקודמים
                        sh "trivy image ${appimage}:${apptag}"
                    }
                },
                'Bandit Check': {
                    container('bandit') {
                        echo "Running Bandit Scan..."
                        sh "bandit -r ."
                    }
                }
            )
        } // סיום Security Scanning
        
    } // סיום node (עבר לסוף כדי לעטוף את הכל!)
} // סיום podTemplate
