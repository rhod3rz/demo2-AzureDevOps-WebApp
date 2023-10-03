## An Azure DevOps and Azure App Service demo pipeline.

### Summary
This repo demonstrates a web app deployment to Azure App Service. The project is broken down into four pipelines:

- An infrastructure build pipeline (using Terraform)
- An application code build pipeline
- An application code release pipeline
- An infrastructure destroy pipeline

The core application components are:

- A .NET 'Todolist' web app
- An Azure SQL database

In addition it demonstrates the use of several other technologies and concepts:

- Azure SQL failover group for high availability
- Azure Front Door for high availability load balancing
- Git and git branching strategy ( prd | dev | stg )
- ADO yaml templates
- Docker application build with an Azure Container Registry repo
- Terraform provision of 'prd/stg' and 'dev' environments based on branch name
- Authorisation gate to control and review terraform code changes
- Custom domains and SSL binding
- Autoscaling
- Canary deployment can be easily facilitated using % traffic allocation
- Blue/Green deployment can be easily facilitated utilising staging slots with emergency rollback available using swaps

### Overview
![Overview](https://raw.githubusercontent.com/rhod3rz/demo2-AzureDevOps-WebApp/prd/screenshots/overview.png "Overview")

### Pre-Requisites
The pipeline relies on the following components:

- Azure DevOps Service Connection  
An ADO service connection to Azure called 'payg2106'.  

- Azure DevOps Service Connection - Azure Container Registry (aka Docker Registry)  
An ADO service connection to Docker / Azure Container Registry called 'acrdlnteudemoapps210713'.

&nbsp;
### 1. The 'Infrastructure' Pipeline Workflow

The infrastructure pipeline focusses on building the Azure components. As changes are infrequently made to the infrastructure the pipeline 'trigger' is a manual process.

---
#### 1.1 Setup ADO Project.
---
a. In ADO create a project, then pipelines > new pipeline > github/yaml > select the correct repo > then create pipelines for the following files and rename as below:  

| YAML File | Rename Pipeline To |
| ------ | ----------- |
| 1-infrastructure.yml | 1-infrastructure |
| 2-build.yml | 2-build |
| 3-release.yml | 3-release |
| 9-destroy.yml | 9-destroy |

#### 1.2 Build the 'prd' Branch.
---
a. Manually run the '1-infrastructure' pipeline. Review the plan at the 'Wait for Validation' stage, and if happy authorise to proceed.  

Pipeline Actions:
- Evaluates the branch name and Terraform provisions the 'prd' environment (inc. manual approval gate).

Output:
- You now have the 'prd' and 'stg' environments deployed.  
Test using the following urls https://prd.rhod3rz.com and https://stg.rhod3rz.com.  
As no code is deployed at this point you'll just get a default landing page.

---
#### 1.2 Build the 'dev' Branch.
---
a. Create a new branch 'dev', and switch to it.  
`git checkout -b dev`  
b. Push the 'dev' branch to github.  
`git push -u origin dev`  
c. Manually run the pipeline. Review the plan at the 'Wait for Validation' stage, and if happy authorise to proceed.  

Pipeline Actions:
- Evaluates the branch name and Terraform provisions the 'dev' environment

Output:
- You now have three environments, 'prd', 'dev' and 'stg'.  
Test using the domain URL from the Azure portal e.g. https://app-dev-spark-231001.azurewebsites.net.  
As no code is deployed at this point you'll just get a default landing page.

---
#### 1.3 Future Changes.
---
Future changes are implemented by creating feature branches and pull requests. 'dev' can be updated directly, but 'prd' must be updated via a PR.

&nbsp;
### 2. The 'Build' Pipeline Workflow
The build pipeline focusses on building and testing the code and creating a docker image ready for deployment. As changes are frequently made, the pipeline 'trigger' is automatic.

---
#### 2.1 Build the 'prd' Branch.
---
a. Update line 24 in src\DotNetCoreSqlDb\Views\Shared\_Layout.cshtml with a new timestamp.  
b. Push the 'prd' branch to github.  
`git add .`  
`git commit -m "prd build deployment 221001-1817"`  
`git push -u origin prd`  
c. The pipeline '2-build' should automatically trigger.

Pipeline Actions:
- Compiles and tests the code, creates a zip artifact, creates a docker image and pushes to ACR.

Output:
- You now have a zip artifact and docker image ready for testing or deployment.

---
#### 2.2 Build the other branches.
---
The steps above can be repeated to build 'dev' and 'stg'. They're covered in the release steps below.

&nbsp;
### 3. The 'Release' Pipeline Workflow

The release pipeline focusses on deploying tested docker images to Azure App Service. For control, this is a manual step where you specify the image tag you want to deploy.

---
#### 3.1 Release the 'prd' Branch.
---
a. Manually run '3-release' against the 'prd' branch. Enter the 'Docker Tag' you want to deploy; this is a required field e.g. 20231002.4-prd.

Pipeline Actions:
- Evaluates the branch name and if 'prd' swaps 'prd' with 'stg' to give an easy rollback position.
- Evaluates the branch name and deploys the app to Azure App Service (prd environment).

Output:
- You now have the 'prd' environment deployed.  
Test using the following url https://prd.rhod3rz.com.

---
#### 3.2 Release the 'dev' Branch.
---
It's time to simulate a change ...  

a. Create a new branch 'dev', and switch to it.  
`git checkout dev`  
b. Update line 24 in src\DotNetCoreSqlDb\Views\Shared\_Layout.cshtml with a new timestamp.  
c. Push the 'dev' branch to github.  
`git add .`  
`git commit -m "dev build deployment 221003-0834"`  
`git push -u origin dev`  
d. The pipeline '2-build' should automatically trigger; wait for this to finish.  
e. Manually run '3-release' against the 'dev' branch. Enter the 'Docker Tag' you want to deploy; this is a required field e.g. 20231003.1-dev.

Pipeline Actions:
- Compiles and tests the code, creates a zip artifact, creates a docker image and pushes to ACR.
- Evaluates the branch name and deploys the app to Azure App Service (dev environment).

Output:
- You now have the 'dev' environment deployed.  
Test using the domain URL from the Azure portal e.g. https://app-dev-spark-231001.azurewebsites.net.  
When running the app, notice the timestamp in the 'dev' environment is now the updated one you set in step 3.2b.

---
#### 3.3 Release the 'stg' Branch.
---
It's time to merge the 'dev' changes into the 'stg' branch ...

a. Create a new branch 'stg', and switch to it. This is now a copy of 'dev'.  
`git checkout -b stg`  
b. Push the changes.  
`git push -u origin stg`  
c. The pipeline '2-build' should automatically trigger; wait for this to finish.  
d. Manually run '3-release' against the 'stg' branch. Enter the 'Docker Tag' you want to deploy; this is a required field e.g. 20231003.2-stg.

Pipeline Actions:
- Compiles and tests the code, creates a zip artifact, creates a docker image and pushes to ACR.
- Evaluates the branch name and deploys the app to Azure App Service (stg environment).

Output:
- You now have the 'stg' environment deployed.  
Test using the following url https://stg.rhod3rz.com.  
When running the app, notice the timestamp in the 'stg' environment is now the updated one carried over from 'dev'.

---
#### 3.4. Merge the 'stg' Branch to 'prd' Branch.
---
Assuming there were no issues with the 'stg' deployment it's time to merge those changes into 'prd' ...

a. Create a 'Pull Request' to merge 'stg' into 'prd' and delete the 'stg' branch from GitHub.  
b. Delete the 'dev' branch from GitHub.  
c. Delete the 'dev' and 'stg' branch from local Git e.g.  
`git checkout prd`  
`git branch -d dev`  
`git branch -d stg`  
`git remote prune origin`  
`git pull origin prd`  
d. The pipeline '2-build' should automatically trigger; wait for this to finish.  
e. Manually run '3-release' against the 'prd' branch. Enter the 'Docker Tag' you want to deploy; this is a required field e.g. 20231003.3-prd.

Pipeline Actions:
- Compiles and tests the code, creates a zip artifact, creates a docker image and pushes to ACR.
- Evaluates the branch name and if 'prd' swaps 'prd' with 'stg' to give an easy rollback position.
- Evaluates the branch name and deploys the app to Azure App Service (prd environment).

Output:
- You've just updated 'prd'.  
Test as before e.g. https://prd.rhod3rz.com.  
When running the app, notice the version number in the 'prd' environment is now the updated one you pushed through 'dev' and 'stg'.

---
#### 3.5. Emergency Rollback.
---
Instructions:

Oh dear, 🤦‍♂️ something has been missed in testing! You need to rollback to the previous version asap ...

Before pushing new code to 'prd' the pipeline swapped the prd and stg slots. This enables a quick rollback to the last known good configuration.

To roll back it's a simple step of swapping the 'prd' and 'stg' slots via the portal 🦸‍♂️😀
