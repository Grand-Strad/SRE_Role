How to run the file to provision the resources

In order to provision the resources described in the .tf file please follow these steps:

Step 1. Download the file

Download the file and store it in a folder.

Step 2. Login to Azure and select the subscription to use

#In case you are not logged into an Azure account, please use the Azure CLI and terminal to login and set the desired subscription as default, using the following commands:
# follow instructions to login to portal
$ az login 
# list all available subscriptions
$ az account list -o table 
# change default subscription
$ az account set --subscription "<subscription>"


Step 3. Initialize and run the script

While you are at the directory where the .tf file is stored, the init command  terraform init needs to be run first to initialize the working directory containing the Terraform configuration files:

G:\GitHub\SRE_Role> terraform init
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/random...
- Finding hashicorp/azurerm versions matching "2.46.0"...
- Installing hashicorp/azurerm v2.46.0...
- Installed hashicorp/azurerm v2.46.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

G:\GitHub\SRE_Role>

Then, the plan command  terraform plan to create an execution plan:

G:\GitHub\SRE_Role> terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create
Terraform will perform the following actions:
  # azurerm_app_service.webapp will be created
...


Plan: 7 to add, 0 to change, 0 to destroy.

And, finally, the apply command terraform apply to execute the actions proposed in the Terraform plan:

G:\GitHub\SRE_Role>terraform apply

# or if you want to use custom values

G:\GitHub\SRE_Role>terraform apply -var="name=<your_name>" -var="region=northeurope"

After a few seconds, you will be asked if you want to continue executing the plan described in the previous step.

Once you answer yes to the prompt command, all the resources will start being created in the Azure account you have previously logged in.


Step 4. Clean Up

To delete all the resources that have been created and go back to previous state, just run the destroy command terraform destroy and, in a few minutes, all previous changes will be cleared. After that you can start all over again.

G:\GitHub\SRE_Role>terraform destroy