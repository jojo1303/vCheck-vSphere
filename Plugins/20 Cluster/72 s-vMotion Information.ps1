# Start of Settings 
# Set the number of days to go back and check for s/vMotions
$vMotionAge = 14
# End of Settings

Function Get-MotionDuration {
    $events = Get-VIEvent -Start ((Get-Date).AddDays(-$vMotionAge)) -MaxSamples $MaxSampleVIEvent
    $relocates = $events |
        where {$_.GetType().Name -eq "TaskEvent" -and $_.Info.DescriptionId -eq "VirtualMachine.migrate" -or $_.Info.DescriptionId -eq "VirtualMachine.relocate"}
    foreach($task in $relocates){
        $tEvents = $events | where {$_.ChainId -eq $task.ChainId} |
            Sort-Object -Property CreatedTime
        if($tEvents.Count){
            New-Object PSObject -Property @{
                Name = $tEvents[0].Vm.Name
                Type = &{if($tEvents[0].Host.Name -eq $tEvents[-1].Host.Name){"SvMotion"}else{"vMotion"}}
                StartTime = $tEvents[0].CreatedTime
                EndTime = $tEvents[-1].CreatedTime
                Duration = New-TimeSpan -Start $tEvents[0].CreatedTime -End $tEvents[-1].CreatedTime
            }
        }
    }
}

$Motions = Get-MotionDuration
$Motions

$Title = "s/vMotion Information"
$Header = "s/vMotion Information (Over $vMotionAge Days Old) : $(@($Motions).count)"
$Comments = "s/vMotions and how long they took to migrate between hosts and datastores"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
