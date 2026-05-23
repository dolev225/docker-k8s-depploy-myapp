def appname = "test-2"
def repo = "dolev1234" 
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"


def kubernetesurl = "https://kubernetes.default.svc"

// 2. הגדרת הפוד בקובורנטיס
podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    // התיקון הקריטי: הוספת command ו-args כדי למנוע מהקונטיינר למות מיד כשהוא עולה
    containerTemplate(
        name: 'helm', 
        image: 'alpine/helm:3.14.0',
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
    // ווליום חיוני עבור פעילות תקינה ומהירה של Docker in Docker
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
  ]) {
    
    // 3. שלבי הריצה (Pipeline Stages)
    node(POD_LABEL) {
        
        stage('checkout') {
            container('jnlp') {
                echo "Checking out code from Git..."
                checkout scm // משיכת הקוד האמיתי מהריפוזיטורי שלך
            }
        } 

        // שלבי ה-Build וה-Push מורצים יחד בתוך קונטיינר ה-Docker
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

                sh """
                    echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin
                    docker push $appimage:$apptag
                """
                    
                }
            }
               }
            
        } // סיום container docker

        // שלב ה-Helm מורץ בתוך קונטיינר ה-Helm שביקשנו ממנו להישאר דלוק
        stage('helm install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                // אין צורך בהורדות או התקנות - מריצים ישירות את הפקודה!
                sh "helm template ${appname} helm-charts/"
            }
        } // סיום stage helm install
        
    } // סיום node
} // סיום podTemplate
