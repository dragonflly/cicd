folder('Build-Project-A') {
  displayName('Build Project A')
  description('Folder for build project A')
}

MicroServices = [
    ["name": "microservice-1", "repo": "https://github.com/dragonflly/microservice-1.git", "owner": ""],
    ["name": "microservice-2", "repo": "https://github.com/dragonflly/microservice-2.git", "owner": ""],
    ["name": "microservice-3", "repo": "https://github.com/dragonflly/microservice-3.git", "owner": ""],
]

for (job in MicroServices) {
  jobName = job["name"]
  jobRepo = job["repo"]
  
  //Create or updates a pipeline job
  pipelineJob("Build-Project-A/${jobName}") {
    //how long to keep records of the builds (daysToKeep, numToKeep, artifactDaysToKeep, artifactNumToKeep)
    logRotator(30, 50, 1, -1)

    //parameterize the pipeline
    parameters {
      gitParameter {
                    name('BRANCH')
                    type('PT_BRANCH')
                    defaultValue('main')
                    description('')
                    branch('')
                    branchFilter('origin/(.*)')
                    tagFilter('*')
                    sortMode('ASCENDING_SMART')
                    selectedValue('DEFAULT')
                    useRepository(jobRepo)
                    quickFilterEnabled(false) }
      booleanParam('sonarqube_scan', true, 'Code quality check by SonarQube')
    }

    //environment variables for pipeline
    environmentVariables {
      env('application', "${jobName}")
      env('repo', "${jobRepo}")
    }

    //pipeline definition
    definition {
      //Loads a pipeline script from SCM
      cpsScm {
        scm {
          git {
            remote {
              url(jobRepo)
              credentials("github")
              extensions {
                submoduleOptions {
                  disable(false)
                  parentCredentials(true)
                  recursive(true)
                  tracking(true)
                }
              }
            }
            branch("main")
          }
        }
        scriptPath('jenkinsPipeline/pipeline_build.groovy')
      }
    }
  }
}