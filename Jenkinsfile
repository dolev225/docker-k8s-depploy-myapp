properties([
    parameters([
        choice(
            name: 'TARGET_ENV',
            choices: ['dev', 'qa', 'prod'],
            description: 'בחר את סביבת היעד לפריסה ב-ArgoCD'
        )
    ])
])

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
    // קונטיינר המכיל Git ומאפשר התקנה דינמית של Helm
    containerTemplate(
        name: 'helm-git', 
        image: 'alpine/git:latest',
        command: 'sleep',
        args: '99d'
    ),
    // קונטיינר ייעודי להרצת כלי הלינטינג בהמשך
    containerTemplate(
        name: 'lint-tools',
        image: 'python:3.11-alpine',
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
            parallel(
                'flake8 check': {
                    container('lint-tools') {
                        echo "Running flake8 command..."
                        sh """
                            pip install --no-cache-dir flake8 hadolint-py
                            flake8 . --exclude=.venv
                        """
                    }
                },
                'Shell check': {
                    container('lint-tools') {
                        echo "Running Shell check..."
                        sh """
                            apk add --no-cache shellcheck
                            find . -name "*.sh" | xargs -r shellcheck
                        """
                    }
                },
                'Hadolint Check': {
                    container('lint-tools') {
                        echo "Running Hadolint command..."
                        sh "find . -name 'Dockerfile' | xargs -r hadolint"
                    }
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
                        sh "trivy fs --cache-dir /tmp/trivy-cache . --exit-code 0"
                    }
                },
                'Bandit Scan': {
                    container('bandit') {
                        echo "Running Bandit Scan..."
                        sh "bandit -r . -s B311,B104"
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
            container('helm-git') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template Test..."
                echo "--------------------------------------------------------------"
                sh """
                    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                    helm template ${appname} ./chart
                """
            }
        }// end of helm install
        
        stage("Push to ArgoCD") {
            container('helm-git') {
                // שליפת הסביבה שנבחרה על ידי המשתמש (dev/qa/prod)
                def selectedEnv = params.TARGET_ENV
                echo "Deploying to environment: ${selectedEnv}"
                
                withCredentials([usernamePassword(
                    credentialsId: 'github-argoCD',
                    usernameVariable: 'git_USER',
                    passwordVariable: 'git_TOKEN'
                )]) {
                    sh """
                        curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        
                        # יצירת המניפסט האחיד ושמירתו מחוץ לתיקייה של הגיט שיורד מיד
                        helm template ${appname} ./chart --set image.repository=${repo}/${appname} --set image.tag=${env.BUILD_NUMBER} > temp-template.yaml
                        
                        git clone https://github.com/dolev225/argoCD.git
                    """
                    
                    dir('argoCD') {
                        sh """
                            # יצירת תיקיית הסביבה (למשל dev/) אם היא לא קיימת
                            mkdir -p ${selectedEnv}
                            
                            # העברת המניפסט החדש לתוך תיקיית הסביבה המתאימה
                            mv ../temp-template.yaml ${selectedEnv}/devops-template.yaml
                            
                            # הגדרות Git חיוניות לעבודה בתוך ה-Agent
                            git config --global user.name 'Jenkins Bot'
                            git config --global user.email 'jenkins-bot@example.com'
                            git config --global --add safe.directory \$(pwd)
                            
                            # דחיפת השינוי ל-Main branch
                            git add ${selectedEnv}/devops-template.yaml
                            git commit -m 'Deploy version ${env.BUILD_NUMBER} to ${selectedEnv}' || echo 'No changes to commit'
                            git push https://x-access-token:${git_TOKEN}@github.com/dolev225/argoCD.git HEAD:main
                        """
                    }
                }
            }
        } // end of push to argoCD
    } // end of node
} // end of podTemplate
