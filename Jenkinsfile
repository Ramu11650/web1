stage('Configure') {
    abort = false
    inputConfig = input id: 'InputConfig', message: 'Docker registry and Anchore Engine configuration', parameters: [string(defaultValue: 'https://registry.hub.docker.com', description: 'URL of the docker registry for staging images before analysis', name: 'dockerRegistryUrl', trim: true), string(defaultValue: 'registry.hub.docker.com', description: 'Hostname of the docker registry', name: 'dockerRegistryHostname', trim: true), string(defaultValue: '', description: 'Name of the docker repository', name: 'dockerRepository', trim: true), credentials(credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl', defaultValue: '', description: 'Credentials for connecting to the docker registry', name: 'dockerCredentials', required: true), string(defaultValue: '', description: 'Anchore Engine API endpoint', name: 'anchoreEngineUrl', trim: true), credentials(credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl', defaultValue: '', description: 'Credentials for interacting with Anchore Engine', name: 'anchoreEngineCredentials', required: true), string(defaultValue: '', description: 'Force=True for re-analysis', name: 're-analysis', trim: true) ]

    for (config in inputConfig) {
        if (null == config.value || config.value.length() <= 0) {
          echo "${config.key} cannot be left blank"
          abort = true
        }
    }

    if (abort) {
        currentBuild.result = 'ABORTED'
        error('Aborting build due to invalid input')
    }
}
  String buildNumber = "0.1.${env.BUILD_NUMBER}"
  //String pbuildNumber = "0.1."+"${previousBuild.getNumber()}"
  applicationname = inputConfig['dockerRepository']
  String branchName = ""
  dockerregistory = inputConfig['dockerRegistryHostname']

node {
  def app
  def dockerfile
  def anchorefile
  def repotag

  try {
    stage('Checkout') {
      // Clone the git repository
      checkout scm
      def scmVars = checkout scm
      branchName = "${scmVars.GIT_BRANCH}"
      def path = sh returnStdout: true, script: "pwd"
      path = path.trim()
      dockerfile = path + "/Dockerfile"
      anchorefile = path + "/anchore_images"
    }

    stage('Build') {
      // Build the image and push it to a staging repository
      repotag = inputConfig['dockerRepository'] + ":${buildNumber}"
      docker.withRegistry(inputConfig['dockerRegistryUrl'], inputConfig['dockerCredentials']) {
        app = docker.build(repotag)
        app.push()
      }
    }

    stage('Parallel') {
      parallel Test: {
        app.inside {
            sh 'echo "Dummy - tests passed"'
        }
      },
      Analyze: {
         writeFile file: anchorefile, text: inputConfig['dockerRegistryHostname'] + "/" + repotag + " " + dockerfile
        anchore name: anchorefile, engineurl: inputConfig['anchoreEngineUrl'], engineCredentialsId: inputConfig['anchoreEngineCredentials'], forceAnalyze: inputConfig['re-analysis'], annotations: [[key: 'added-by', value: 'jenkins']] 

      }
    }

      stage("Build Docker Image") {
      repotag = inputConfig['dockerRepository'] + ":${buildNumber}"
      docker.withRegistry(inputConfig['dockerRegistryUrl'], inputConfig['dockerCredentials']) {
        latestImage = docker.build("${applicationname.toLowerCase()}")
        latestImage.push()
      }
    }


  } finally {
    stage('Cleanup') {
      // Delete the docker image and clean up any allotted resources
      sh script: "docker rmi " + repotag
      sh script: "docker rmi "+ dockerregistory + "/" + repotag
      //sh script: "docker rmi "+ dockerregistory + "/" + applicationname + ":" + "latest"			
    }
  }

}


