# Start of Settings
# Return results in GB or MB?
$Units ="GB"
# End of Settings


# Setup plugin-specific language table
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang


$OverCommit = @()
$i = 0
Foreach ($VMHost in $VMH) {
	Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $VMHost.Name -PercentComplete ((100*$i)/$VMH.Count)
	if ($VMMem) { Clear-Variable VMMem }
	$VM | ?{$_.VMHost.Name -eq $VMHost.Name} | Foreach {
		[INT]$VMMem += $_.MemoryMB
	}


	If ([Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0) -gt 0) {
		$OverCommitMB = [Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0)


		if ($Units -eq "MB") {
			$OverCommit += New-Object PSObject -Property @{"Host" = $VMHost.Name;
								"TotalMemMB" = [Math]::Round($VMHost.MemoryTotalMB,0);
								"TotalAssignedMemMB" = $VMMem;
								"TotalUsedMB" = [Math]::Round($VMHost.MemoryUsageMB,0);
								"OverCommitMB" = $OverCommitMB;
																		}
		}
		else {
			$OverCommit += New-Object PSObject -Property @{"Host" = $VMHost.Name;
								"TotalMemGB" = [Math]::Round(($VMHost.MemoryTotalMB)/1024,0);
								"TotalAssignedMemGB" = [Math]::Round($VMMem/1024,0);
								"TotalUsedGB" = [Math]::Round(($VMHost.MemoryUsageMB)/1024,0);
								"OverCommitGB" = [Math]::Round($OverCommitMB/1024, 0);
																		}
		}
	}
	$i++
}
Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $lang.Complete -Completed


$OverCommit | Select Host, "TotalMem$Units", "TotalAssignedMem$Units", "TotalUsed$Units", "OverCommit$Units"


$Title = "Hosts Overcommit state"
$Header = "Hosts overcommitting memory : $(@($OverCommit).count)"
$Comments = "Overcommitted hosts may cause issues with performance if memory is not issued when needed, this may cause ballooning and swapping"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
