## Azure App Service: Set App settings ##

This simple task allows you to set your App Settings on an Azure App Service like a Web App or API App in one simple task.

It is perfect in a setup where you have multiple webapps with the same settingsname and different values. 

### Get started ###
Add the task to you VSTS by clicking install. Next add the task to a deployment pipeline.   

![image](https://raw.githubusercontent.com/hnky/VSTS-Deploy-AppSettings/master/AzureAppServiceSetAppSettings/images/screen1.JPG)   

In the task:
1) Select your subscription
2) Select the Azure App Service
3) Select the resource group of your App Service
4) Add a your App Settings in a simple key value interface.

The format is:  
key1='value1'   
key2='value2'

### Support ###
Need any support or it is not working, please create a Issue on Github.   

Happy deploying   

Henk Boelman

Read the [blogpost](https://www.henkboelman.com/2017/04/vsts-task-to-set-app-settings-during-deploy)