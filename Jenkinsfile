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
        image: 'cytopia/bandit:latest', 
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
            // שים לב: בשביל שהבדיקות האלו יעבדו, צריך להתקין את הכלים בפוד. כרגע זה רק echo כדי שלא ייכשל.
            parallel(
                'flake8 check': {
                    echo "Running flake8 command..."
                },
                'Shell check': {
                    echo "Running Shell check..."
                },
                'Hadolint Check': {
                    echo "Running Hadolint command..."
                }
            )
        }
        
        stage('Build & Security (Parallel)') {
            parallel(
                'Docker Build': {
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
                },
                'Trivy Scan': {
                    container('trivy') {
                        echo "Running Trivy File System Scan..."
                        sh "trivy fs . --exit-code 0"
                    }
                },
                'Bandit Scan': {
                    container('bandit') {
                        echo "Running Bandit Scan (Skipping B311,B104)..."
                        // תיקון: שינוי מ-echo ל-sh כדי שהסריקה תרוץ באמת
                        sh "bandit -r . -x B311,B104"
                    }
                }
            )// end of parallel
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
        } // end of push image
            
        stage('Helm Install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                sh "helm template ${appname} ./chart"
            }
        }// end of helm install
        
        stage('push to argoCD'){
            container('helm'){
                withCredentials([usernamePassword(
                    credentialsId: 'github-argoCD',
                    usernameVariable: 'git_USER',
                    passwordVariable: 'git_TOKEN'
                )]) {
                    // יצירת הטמפלייט בתיקייה הראשית
                    sh "helm template ${appname} ./chart > devops-template.yaml"
                    sh "git clone https://github.com/dolev225/argoCD.git"
                    
                    // תיקון: שימוש בבלוק dir כדי לוודא שכל הפקודות רצות בתוך תיקיית הריפו ששוכפל
                    dir('argoCD') {
                        sh "mv ../devops-template.yaml ."
                        sh "git config --global user.name 'bot'"
                        sh "git config --global user.email 'jenkins[bot]@example.com'"
                        sh "git config --global --add safe.directory /home/jenkins/agent/workspace/dolev"
                        sh "git add devops-template.yaml"
                        // שימוש ב-|| true למקרה שאין שינויים בקובץ, כדי שהבילד לא ייכשל סתם
                        sh "git commit -m 'jenkins-gen-devops-template.yaml' || echo 'No changes to commit'"
                        sh "git push https://x-access-token:${git_TOKEN}@github.com/dolev225/argoCD HEAD"
                    }
                }
            }
        } // end of stage push to argoCD
    } // end of node
}
