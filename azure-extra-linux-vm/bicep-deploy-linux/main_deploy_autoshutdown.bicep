@description('Location for the deployment')
param location string = resourceGroup().location

@description('Name of the VM to setup')
param vmName string

@description('Time of the shutdown')
param shutdownTime string = '23:45'

@description('Email recipient')
param emailRecipient string

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}

resource autoShutdownConfig 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 15
      notificationLocale: 'en'
      emailRecipient: emailRecipient
    }
    dailyRecurrence: {
       time: shutdownTime
    }
     timeZoneId: 'UTC'
     taskType: 'ComputeVmShutdownTask'
     targetResourceId: vm.id
  }
}
