pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/irfanvox/my-robot-project-nov/'
            }
        }
       
        stage('Run Tests') {
            steps {
                sh 'docker build -t robot-saucedemo .'
                sh 'mkdir -p results'
                sh 'docker run --rm -v ${WORKSPACE}/results:/app/results robot-saucedemo'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'results/**', allowEmptyArchive: true
            robot outputPath: 'results'
        }
    }
}
