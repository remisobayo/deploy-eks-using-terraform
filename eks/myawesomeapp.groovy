pipeline {
   tools {
       maven 'maven3'
   }
   agent any
   environment {
    registry = "492811607193.dkr.ecr.us-east-2.amazonaws.com/mavenapp:latest"
   }
   stages {
       stage('Cloning Git') {
           steps {
               checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/remisobayo/springboot-app.git']]])
           }
       }
       stage('Build and Scan Jar File') {
           steps {
               // withSonarQubeEnv(installationName: 'sonar-app', credentialsId: '0456b3e2-9d33-4001-8cd2-ac753f128fc9') {
               withSonarQubeEnv(installationName: 'sonar-test', credentialsId: 'b37691e4-fa97-481e-b5b1-a5996bf9c314') {
               sh 'mvn clean install sonar:sonar'
               }
           }
       }
       stage('Docker Image Build') {
           steps {
               sh 'docker build -t mavenapp .'
           }
       }

       // scan docker image with trivy
        stage('Trivy Scan') {
                steps {
                    script {
                        // sh """trivy image --format template --template \"@/home/ubuntu/contrib/html.tpl\" --output trivy_report.html 492811607193.dkr.ecr.us-east-2.amazonaws.com/mavenapp:latest """
                    sh """trivy image mavenapp:latest --format template --template \"@/home/ubuntu/contrib/html.tpl\" --timeout 5m --no-progress --scanners vuln --output trivy_report.html """    
                    // sh """trivy image mavenapp --timeout 5m --scanners vuln --no-progress"""
                    // sh 'curl -sL https://get.aquasec.com/trivy | sh -'
                    // sh 'trivy image --severity=CRITICAL --exit-code=1 --no-progress --format=table my-image'
                    // publishHTML (target: [
                    //     allowMissing: false,
                    //     alwaysLinkToLastBuild: false,
                    //     keepAll: true,
                    //     reportDir: '.',
                    //     reportFiles: 'trivy_report.html',
                    //     reportName: 'Trivy Scan',
                    //     ])
                    }
                    
                }
            }
       stage('Push Docker Image to ECR') {
           steps {
               withAWS(credentials: 'a5492e8d-7a07-413d-9347-c0634a851f36', region: 'us-east-2') {
                   sh 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 492811607193.dkr.ecr.us-east-2.amazonaws.com'
                   sh 'docker tag mavenapp:latest 492811607193.dkr.ecr.us-east-2.amazonaws.com/mavenapp:latest'
                   sh 'docker push 492811607193.dkr.ecr.us-east-2.amazonaws.com/mavenapp:latest'
               }
           }
       }
     stage('Integrate Jenkins with EKS Cluster and Deploy App') {
           steps {
               withAWS(credentials: 'a5492e8d-7a07-413d-9347-c0634a851f36', region: 'us-east-2') {
                 script {
                   sh ('aws eks update-kubeconfig --name maven-cluster --region us-east-2')
                   sh ('kubectl get nodes')
                   sh ('kubectl get svc')
                //    sh ('kubectl apply -f eks-deploy-k8s.yaml')
               }
               }
       }
   }
   }
}
