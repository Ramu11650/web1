#!/usr/bin/env groovy

milestone 1
  // Setup variables
  // application name will be used in a few places so create a variable and use string interpolation to use it where needed
  String applicationName = "docker_web01"
  // a basic build number so that when we build and push to Artifactory we will not overwrite our previous builds
  String buildNumber = "0.1.${env.BUILD_NUMBER}"
  // global var for branch name
  String branchName = ""
node {
  // Checkout the code from Github, stages allow Jenkins to visualize the different sections of your build steps in the UI
  stage('Checkout from GitHub') {
    def scmVars = checkout scm
    branchName = "${scmVars.GIT_BRANCH}"
  }
  
  milestone 2
  // here keep a version of every build just in case
  stage("Build Docker Image") {
    docker.withRegistry('https://visiontravel.azurecr.io', 'azureRegistry') {
      def customImage = docker.build("visiontravel.azurecr.io/${applicationName.toLowerCase()}:${branchName}-${buildNumber}")
      customImage.push()
      def latestImage = docker.build("visiontravel.azurecr.io/${applicationName.toLowerCase()}:${branchName}")
      latestImage.push()
    }
  }
  milestone 3
  
  stage("cleanup") {
    // Archive the binary files in Jenkins so we can retrieve them later should we need to audit them
    sh "rm -Rvf ./*"
  }
}
