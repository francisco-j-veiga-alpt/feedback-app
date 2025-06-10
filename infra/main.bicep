targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param apiServiceName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param appServicePlanName string = ''
param cosmosAccountName string = ''
param keyVaultName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''
param webServiceName string = ''


@description('Id of the user or app to assign application roles')
param principalId string = ''

param cosmosDatabaseName string = ''
var defaultDatabaseName = 'feedback-app-db'
var actualDatabaseName = !empty(cosmosDatabaseName) ? cosmosDatabaseName : defaultDatabaseName
param connectionStringKey string = 'AZURE-COSMOS-CONNECTION-STRING'
param cosmosMongoCollections array = [
  {
    name: 'TodoList'
    id: 'TodoList'
    shardKey: {
      keys: [
        'Hash'
      ]
    }
    indexes: [
      {
        key: {
          keys: [
            '_id'
          ]
        }
      }
    ]
  }
  {
    name: 'TodoItem'
    id: 'TodoItem'
    shardKey: {
      keys: [
        'Hash'
      ]
    }
    indexes: [
      {
        key: {
          keys: [
            '_id'
          ]
        }
      }
    ]
  }
]

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'env-name': environmentName }

var appName = 'feedback-app-'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${appName}${environmentName}'
  location: location
  tags: tags
}

/// Monitor application with Azure Monitor
module monitoring 'br/public:avm/ptn/azd/monitoring:0.1.1' = {
  name: 'monitoring'
  scope: rg
  params: {
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${appName}${environmentName}-${resourceToken}'
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${appName}${environmentName}-${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${appName}${environmentName}-${resourceToken}'
    location: location
    tags: union(tags, { 'monitoring-app': '${abbrs.keyVaultVaults}${appName}${environmentName}-${resourceToken}' })
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${appName}${environmentName}-${resourceToken}'
    skuName: 'B1'
    skuCapacity: 1
    location: location
    tags: union(tags, { 'app-service-plan': '${abbrs.webServerFarms}${appName}${environmentName}-${resourceToken}' })
    reserved: true
    kind: 'linux'
  }
}

// The application frontend
module web './modules/web-appservice-avm.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: !empty(webServiceName) ? webServiceName : '${abbrs.webSitesAppService}web-platform-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.resourceId
    appInsightResourceId: monitoring.outputs.applicationInsightsResourceId
    linuxFxVersion: 'node|20-lts'
  }
}

// The application database
module cosmos 'br/public:avm/res/document-db/database-account:0.15.0' = {
  name: 'cosmos-mongo'
  scope: rg
  params: {
    failoverLocations: [
      {
        failoverPriority: 0
        isZoneRedundant: true
        locationName: location
      }
    ]
    name: !empty(cosmosAccountName) ? cosmosAccountName : '${abbrs.documentDBDatabaseAccounts}${appName}${environmentName}-${resourceToken}'
    location: location
    mongodbDatabases: [
      {
        name: actualDatabaseName
        tags: union(tags, { 'cosmosdb-name': actualDatabaseName })
        collections: cosmosMongoCollections
      }
    ]
    enableFreeTier: true
    capabilitiesToAdd: [
      'EnableMongo'
      'EnableServerless'
    ]
    serverVersion: '4.2'
    zoneRedundant: false
    totalThroughputLimit: 1000
  }
}

// Create a keyvault to store secrets
module keyVault 'br/public:avm/res/key-vault/vault:0.12.1' = {
  name: 'keyvault'
  scope: rg
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${appName}${environmentName}-${substring(resourceToken, 0, 4)}'
    location: location
    tags: union(tags, { 'keyvault-name': '${abbrs.keyVaultVaults}${appName}${environmentName}-${substring(resourceToken, 0, 4)}' })
    enableRbacAuthorization: false
    enableVaultForDeployment: false
    enableVaultForTemplateDeployment: false
    enablePurgeProtection: false
    sku: 'standard'
    secrets: [
      {
        name: connectionStringKey
        value: cosmos.outputs.primaryReadWriteConnectionString
      }
    ]
  }
}

// The application backend
module api './modules/api-appservice-avm.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: !empty(apiServiceName) ? apiServiceName : '${abbrs.webSitesAppService}feedback-api-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    kind: 'app'
    appServicePlanId: appServicePlan.outputs.resourceId
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'python|3.12'
      appCommandLine: 'gunicorn --timeout 60 --access-logfile "-" --error-logfile "-" --bind=0.0.0.0:8000 -k uvicorn.workers.UvicornWorker app.main:app'
    }
    appSettings: {
      AZURE_KEY_VAULT_ENDPOINT: keyVault.outputs.uri
      AZURE_COSMOS_CONNECTION_STRING_KEY: connectionStringKey
      AZURE_COSMOS_DATABASE_NAME: actualDatabaseName
      AZURE_COSMOS_ENDPOINT: 'https://${actualDatabaseName}.documents.azure.com:443/'
      API_ALLOW_ORIGINS: web.outputs.SERVICE_WEB_URI
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
    }
    appInsightResourceId: monitoring.outputs.applicationInsightsResourceId
    allowedOrigins: [ web.outputs.SERVICE_WEB_URI ]
  }
}

module accessKeyVault 'br/public:avm/res/key-vault/vault:0.3.5' = {
  name: 'accesskeyvault'
  scope: rg
  params: {
    name: keyVault.outputs.name
    enableRbacAuthorization: false
    enableVaultForDeployment: false
    enableVaultForTemplateDeployment: false
    enablePurgeProtection: false
    sku: 'standard'
    accessPolicies: [
      {
        objectId: principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        objectId: api.outputs.SERVICE_API_IDENTITY_PRINCIPAL_ID
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
}

// Data outputs
output AZURE_COSMOS_CONNECTION_STRING_KEY string = connectionStringKey
output AZURE_COSMOS_DATABASE_NAME string = actualDatabaseName

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.uri
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output API_BASE_URL string = api.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI


// check
output connectionStringKey string = connectionStringKey
output databaseName string = actualDatabaseName
output endpoint string = cosmos.outputs.endpoint

