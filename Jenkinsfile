#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER="153"
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    /* Variable to be modified according to the project */
    def HUB_ORG="victor.chamontin@curious-bear-qblr92.com"
    def SFDC_HOST ="https://login.salesforce.com"
    def JWT_KEY_CRED_ID = "3a501f10-c5be-4d7f-b02f-bc8aab9cc37c"
    def CONNECTED_APP_CONSUMER_KEY= "3MVG9T46ZAw5GTfUKCVM0gXH_ufDXkZgqqiM81SOsuVGH8HGEOjkMTOHvdGYrEs6Vhs.MkPmf16Ie2hPZilCE"

    // Variable that allows you to link to Salesforce DX
    def toolbelt = tool 'sfdx'

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {

        // Pipeline for push to SandBox
        stage('Push to SandBox') {

            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:deploy -x ./manifest/package.xml --targetusername ${HUB_ORG}"
            
            // Script with a nonzero status code wull cause the step to fail with an exception
            if(rc != 0) {
                error 'Push failed'
            }

        }

        // Pipeline for run Apex Test on SandBox
        stage('Run Apex Code') {
            sh "mkdir -p ${RUN_ARTIFACT_DIR}"
            timeout(time: 120, unit: 'SECONDS') {
                /*
                 * Script to run Apex tests
                 * --testlevel RunLocalTests : All tests in your org are run, except the ones that originate from installed managed packages
                 * --resultformat tap : Fromat to use when displaying results. If you also specify the --json flag, --json overrides this parameter
                 * Permissible values are : human, tap, junit, json
                 */
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${HUB_ORG}"

                // Script with a nonzero status code wull cause the step to fail with an exception
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }

        /* -------------------------------------------------------------- Test on Scratch Org ------------------------------------------- */

        /*
        // Pipeline for create a Scratch Org and retrieve the id of it
        stage('Create Scratch Org') {

            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            // Script with a nonzero status code wull cause the step to fail with an exception
            if (rc != 0) { error 'hub org authorization failed' }

            // need to pull out assigned username
            rmsg = sh returnStdout: true, script: "${toolbelt}/sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername"
            println rmsg
            
            // jsonSlurper wich pases text or reader content into a data structure of lists and maps
            // It's from this place that I'm trying to get the Scratch Org id back.            
            def jsonSlurper = new JsonSlurperClassic()
            def robj = jsonSlurper.parseText(rmsg)
            if (robj.status != 0) { error 'org creation failed: ' + robj.message }
            SFDC_USERNAME=robj.result.username
            robj = null
            
        }

        // Pipeline for push to the Scratch Org
        stage('Push To Test Org') {
            //rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:deploy -p force-app/main/default/. --targetusername ${HUB_ORG}"
			rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:push --targetusername ${SFDC_USERNAME}"

            // Script with a nonzero status code wull cause the step to fail with an exception
            if (rc != 0) {
                error 'push failed'
            }
            // assign permset
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
            if (rc != 0) {
                error 'permset:assign failed'
            }
        }

        // Pipeline for run Apex Test on the Scratch Org
        stage('Run Apex Test') {
            sh "mkdir -p ${RUN_ARTIFACT_DIR}"
            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${SFDC_USERNAME}"
                
                // Script with a nonzero status code wull cause the step to fail with an exception
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }*/

        // Piepline for collect results of the previous tests
        // stage('collect results') {
        //    junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
        //}

        /*
        // Pipeline for delete the Scratch Org
        stage('Delete Test Org') {
	        timeout(time: 120, unit: 'SECONDS') {
	            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:org:delete --targetusername ${SFDC_USERNAME} --noprompt"

                // Script with a nonzero status code wull cause the step to fail with an exception
	            if (rc != 0) {
	                error 'org deletion request failed'
	            }
	        }
	    } */

        /* -------------------------------------------------------------- End of test on Sratch Org ------------------------------------------------ */

    }
}