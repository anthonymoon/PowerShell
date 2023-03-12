$VM = Get-VMHost -Name {$NAME} |Get-VM -Name "{$NAME}"
$vGPUDevice = $VM.ExtensionData.Config.hardware.Device | Where { $_.backing.vgpu } | Select-Object -First 1
$vGPUDevice | Select Key, ControllerKey, Unitnumber, @{Name="Device";Expression={$_.DeviceInfo.Label}}, @{Name="Summary";Expression={$_.DeviceInfo.Summary}}
$ControllerKey = $vGPUDevice.controllerKey
$Key = $vGPUDevice.Key
$UnitNumber = $vGPUDevice.UnitNumber
$Device = $vGPUDevice.Device
$Summary = $vGPUDevice.Summary

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$spec.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$spec.deviceChange[0].operation = 'remove'
$spec.deviceChange[0].device = New-Object VMware.Vim.VirtualPCIPassthrough
$spec.deviceChange[0].device.controllerKey = $ControllerKey
$spec.deviceChange[0].device.unitNumber = $UnitNumber
$spec.deviceChange[0].device.deviceInfo = New-Object VMware.Vim.Description
$spec.deviceChange[0].device.deviceInfo.summary = $Summary
$spec.deviceChange[0].device.deviceInfo.label = $Device
$spec.deviceChange[0].device.key = $Key
Write-Host "Removing the GPU Devices in $VM"
$VM.ExtensionData.ReconfigVM_Task($spec)