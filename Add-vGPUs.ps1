param (
    [string]$VMHost,
    [string]$Name,
    [string]$VGPUProfile
)

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.memoryReservationLockedToMax = $true
$spec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$spec.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$spec.deviceChange[0].operation = 'add'
$spec.deviceChange[0].device = New-Object VMware.Vim.VirtualPCIPassthrough
$spec.deviceChange[0].device.deviceInfo = New-Object VMware.Vim.Description
$spec.deviceChange[0].device.deviceInfo.summary = ''
$spec.deviceChange[0].device.deviceInfo.label = 'New PCI device'
$spec.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualPCIPassthroughVmiopBackingInfo
$spec.deviceChange[0].device.backing.vgpu = $VGPUProfile
(Get-VMHost -Name $VMHost | Get-VM -Name $Name).ExtensionData.ReconfigVM_Task($spec)