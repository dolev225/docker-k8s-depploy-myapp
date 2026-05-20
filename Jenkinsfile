def appname = "mydolev"
def repo = "dolev1234"  
def appimage = "docker.io/${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

// הוספנו כאן את ה-serviceAccount כדי ש-Helm יוכל לנהל סיקרטים ודיפלוימנטס בקלאסטר
podTemplate(cloud: 'kubernetes', serviceAccount: 'jenkins-helm-agent', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', 
        privileged: true,      
        args: '--storage-driver=vfs' 
    ), // <-- כאן היה חסר פסיק!
    containerTemplate(
        name: 'helm',
        image: 'alpine/helm:3.14.0',
        ttyEnabled: true,
        command: 'cat'
    )
], 
volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
]) {
    
    node(POD_LABEL) {
        
        stage('Checkout') {
            container('jnlp') {
                sh 'git config --global http.sslVerify false'
                checkout scm
            }
        } 

        stage('Docker Build') {
            container('docker') {
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
            container('helm') {
                // עכשיו זה ירוץ בתוך הקונטיינר המובנה של Helm בצורה מהירה ויציבה
                sh "helm upgrade --install ${appname} ./chart"
            }
        }
    } // end node
} // end podTemplate
