pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/irfanvox/my-robot-project-nov/'  
            }
        }

        stage('Run Robot Tests') {
            steps {
                sh '''
                docker build -t robot-test .
                docker run --rm -v ${WORKSPACE}/results:/app/results robot-test
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results/*.xml, results/*.html', allowEmptyArchive: true
            robot results
        }
    }
}
