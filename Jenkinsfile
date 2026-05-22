def appname = "test-app"
def repo = "kfire312"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

pipeline {
    agent {
        node {
            label 'agent2' // ה-Pipeline מתחיל על ה-slave שלך
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
                checkout scm
            }
        }
        
        stage('Run Inside Container') {
            agent {
                docker {
                    // האימג' שה-slave ימשוך ויריץ כקונטיינר זמני
                    image 'docker:26-dind'
                    // הגדרות הרצה (כמו מצב פריבילגי ומיפוי ווליום כפי שרצית)
                    args '--privileged -v /var/lib/docker:/var/lib/docker'
                }
            }
            steps {
                echo "------------------------ Running Inside the Container ------------------------"
                // כל פקודה פה רצה *בתוך* הקונטיינר של ה-dind שזה עתה עלה
                sh 'docker --version' 
                
                // כאן תוכל להריץ את פקודות הבנייה שלך:
                // sh "docker build -t ${appimage}:${apptag} ."
            }
        }
    }
}
