folder('Deploy-Project-A') {
  displayName('Deploy Project A')
  description('Folder for deploy project A')
}

MicroServices = [
    ["name": "microservice-1", "repo": "https://github.com/dragonflly/ms-1.git", "owner": ""],
    ["name": "microservice-2", "repo": "https://github.com/dragonflly/ms-2.git", "owner": ""],
    ["name": "microservice-3", "repo": "https://github.com/dragonflly/ms-3.git", "owner": ""],
]

for (envkey in ['dev', 'stage', 'prod'] ) {
  folder("Deploy-Project-A/${envkey}") {
    displayName("Deploy to ${envkey}")
    description("Deploy Project A ${envkey}")
  }

  for (ms in MicroServices) {
    appName = ms['name']
    jobRepo = ms['repo']
    
    pipelineJob("Deploy-Project-A/${envkey}/${appName}") {
      //logRotator(daysToKeep, numToKeep, artifactDaysToKeep, artifactNumToKeep)
      logRotator(30, 50, 1, -1)

      //input parameters for jenkins pipeline
      parameters {
        activeChoiceParam('version') {
            description('Tag : Branch : Username : Timestamp')
            filterable()
            choiceType('SINGLE_SELECT')
            groovyScript {
                script("""
import hudson.model.User
import com.amazonaws.regions.Regions
import com.amazonaws.services.dynamodbv2.*
import com.amazonaws.services.dynamodbv2.document.DynamoDB
import com.amazonaws.services.dynamodbv2.document.utils.NameMap
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec

def client = AmazonDynamoDBClientBuilder.standard().withRegion(Regions.US_EAST_1).build()
def dynamoDB = new DynamoDB(client)
def table = dynamoDB.getTable("jenkins-build-info");
def spec = new QuerySpec().withKeyConditionExpression("application = :v_app")
    .withValueMap(new ValueMap().withString(":v_app", "${appName}"))
    .withScanIndexForward(false)

def items = table.query(spec)
def iterator = items.iterator()
result = []
def count = 0
while (iterator.hasNext()) {
    item = iterator.next()
    result.add(item.get("tag") + " : " + item.get("branch") + " : " + item.get("username") + " : " + item.get("timestamp"))
    if (++count == 100) {
      break
    }
}
return result
                      """)
                fallbackScript('"latest"')
            }
        }
      }

      //environment variables for jenkins pipeline
      environmentVariables {
        env('environment', envkey)
        env('application', appName)
      }

      definition {
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
          scriptPath('jenkinsPipeline/pipeline_deploy.groovy')
        }
      }
    }
  }
}