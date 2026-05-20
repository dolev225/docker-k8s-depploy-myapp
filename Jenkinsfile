def appname = "mydolev"
def repo = "dolev1234"  
def appimage = "docker.io/${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

podTemplate(
    cloud: 'kubernetes', // הגדרת הענן (חובה בג'נקינס לוקלי)
    serviceAccount: 'jenkins-helm-agent', 
    containers: [ // תיקון: שימוש במפתח containers במקום נקודתיים
        containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest'),
        containerTemplate(name: 'docker', image: 'docker:26-dind', privileged: true, args: '--storage-driver=vfs'),
        containerTemplate(name: 'helm', image: 'alpine/helm:3.12.0', ttyEnabled: true, command: 'cat')
    ], 
    volumes: [
        emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
    ]
) {
    
    node(POD_LABEL) {
        
        stage('Checkout') {
            container('jnlp') {
                sh 'git config --global http.sslVerify false'
                checkout scm
            }
        } 

        stage('Docker Build') {
            container('docker') {
                // מומלץ להמתין ששירות ה-Docker הפנימי יעלה לחלוטין בלוקל
                sh 'sleep 5' 
                sh "docker build -t ${appimage}:${apptag} ."
            } 
        }

        stage('Docker Push') {
            container('docker') {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh """
                    echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${appimage}:${apptag}
                    """
                } 
            }
        }

        stage('Helm Install') {
            // תיקון: הסרת בלוק ה-steps ששייך ל-Declarative Pipeline בלבד
            container('helm') {
                // שימוש ב-upgrade --install ובאימג' הדינמי החדש שבנינו
                sh """
                helm upgrade --install ${appname} ./chart \
                  --set image.repository=${appimage} \
                  --set image.tag=${apptag}
                """
            }
        }
    } 
}
