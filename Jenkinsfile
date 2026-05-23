def branch = env.BRANCH_NAME
def build = env.BUILD_NUMBER
def DEBUG = true
def DEPLOY = false

// משתנים קריטיים - ודא שהגדרת אותם אצלך (או שנה את השמות כאן בהתאם)
def appname = "my-app"
def appimage = "your-dockerhub-username/my-image"
def apptag = "build-${build}"

def kubernetesurl = "https://kubernetes.default.svc"

podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'helm', 
        image: 'alpine/helm:3.14.0' // האימג' כבר מגיע עם helm 
        args:99d
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
        
        stage('checkout') {
            container('jnlp') {
                echo "checkout"
                checkout scm // משיכת הקוד האמיתי מהגיט
            }
        } 
        
        // עוטפים את שלבי הדוקר בקונטיינר של docker
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
            
            // תיקון: הוספת גרשיים לשם השלב וסגירה נכונה של ה-withCredentials
            stage('push') {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    
                    echo "--------------------------------------------------------------"
                    echo "Docker login" 
                    echo "--------------------------------------------------------------"
                    // תיקון: הוספת \ לפני ה-DOCKER_TOKEN כדי להגן על הסיסמה בלוגים של ג'נקינס
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
                } // סוף withCredentials
            } // סוף stage push
            
        } // סוף container docker

        stage('helm install') {
            container('helm') {
                // תיקון: ניקוי ה-curl וההורדות. ה-Helm כבר מותקן באימג', מריצים ישירות!
                sh "helm template ${appname} helm-charts/"
            }
        } // סוף stage helm install
        
    } // סוף node
} // סוף podTemplate
