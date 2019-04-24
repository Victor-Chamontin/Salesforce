#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER="153"
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG="victor.chamontin@curious-bear-qblr92.com"
    def SFDC_HOST ="https://login.salesforce.com"
    def JWT_KEY_CRED_ID = "3a501f10-c5be-4d7f-b02f-bc8aab9cc37c"
    def CONNECTED_APP_CONSUMER_KEY= "3MVG9T46ZAw5GTfUKCVM0gXH_ufDXkZgqqiM81SOsuVGH8HGEOjkMTOHvdGYrEs6Vhs.MkPmf16Ie2hPZilCE"

    def toolbelt = tool 'sfdx'

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Create Scratch Org') {

            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            if (rc != 0) { error 'hub org authorization failed' }

            // need to pull out assigned username
            rmsg = sh returnStdout: true, script: "${toolbelt}/sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername"
            println rmsg
            /*
            // jsonSlurper wich pases text or reader content into a data structure of lists and maps
            // It's from this place that I'm trying to get the Scratch Org id back.
            // Without this piece of code, everything that is later commented on does not work.
            
            def jsonSlurper = new JsonSlurperClassic()
            def robj = jsonSlurper.parseText(rmsg)
            if (robj.status != 0) { error 'org creation failed: ' + robj.message }
            SFDC_USERNAME=robj.result.username
            robj = null
            */
        }

        stage('Push To Test Org') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:deploy -p force-app/main/default/. --targetusername ${HUB_ORG}"
            if (rc != 0) {
                error 'push failed'
            }
            // assign permset
            /*rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:user:permset:assign --targetusername ${HUB_ORG} --permsetname DreamHouse"
            if (rc != 0) {
                error 'permset:assign failed'
            }*/
        }

        /*stage('Run Apex Test') {
            sh "mkdir -p ${RUN_ARTIFACT_DIR}"
            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${SFDC_USERNAME}"
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }*/

        //stage('collect results') {
        //    junit keepLongStdio: true, testResults: 
        //}

    }
}