def appname = "test-app"
def repo = "dolev1234"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
// שימוש ב-env.BUILD_NUMBER פועל רק בתוך סקופ ה-node/stage, הגדרת משתנה סטטי פה עשויה להיכשל, עדיף להגדיר בפנים או להשתמש בזה ישירות.

podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', 
        privileged: true,      
        args: '--storage-driver=vfs',
        command: 'dockerd-entrypoint.sh' // גורם לשרת ה-Docker לעלות ולרוץ ברקע בצורה תקינה בתוך ה-Pod
    )], 
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
  ]) {
    node(POD_LABEL) {
        def apptag = "${appname}:${env.BUILD_NUMBER}"
        
        stage('checkout') {
            container('jnlp') {
                sh '/usr/bin/git config --global http.sslVerify false'
                checkout scm
            }
        } // end checkout
        
        // כאן אנחנו מגדירים ל-Pipeline להשתמש בקונטיינר של ה-Docker
        container('docker') {
            stage("build docker image") {
                // הגדרת משתנה הסביבה שמפנה את פקודות ה-docker לשרת ה-dind שרץ ב-localhost
                withEnv(['DOCKER_HOST=tcp://localhost:2375', 'DOCKER_TLS_CERTDIR=']) {
                    
                    echo "--------------------------------------------------------------"
                    echo "Building docker image..."
                    echo "--------------------------------------------------------------"
                    
                    // תיקון הגרשיים השבורים
                    sh "docker build -t ${apptag} ."
                    
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully: ${apptag}"
                    echo "--------------------------------------------------------------"
                }
            }
        }
    }
}
