﻿Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ModuleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module $ModuleManifestPath -Force

$TargetFile = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.ps1'
$TargetImplementationPath = '{0}\..\Logging\targets\{1}' -f $PSScriptRoot, $TargetFile

Describe -Tags Targets, TargetAzureLogAnalytics 'AzureLogAnalytics target' {
    It 'should be available in the module' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.AzureLogAnalytics | Should Not BeNullOrEmpty
    }

    It 'should have two required parameters' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.AzureLogAnalytics.ParamsRequired | Should Be @('WorkspaceId','SharedKey')
    }

    It 'should call Invoke-WebRequest' {
        
        Mock Invoke-WebRequest -Verifiable

        $Module = . $TargetImplementationPath

        $Log = [hashtable] @{
            level   = 'INFO'
            essage = 'Hello, Azure!'
            timestamputc = '2020-02-24T22:35:23.000Z'
        }

        $Configuration = @{
            WorkspaceId = '12345'
            SharedKey = 'Q3Vyc2UgeW91ciBzdWRkZW4gYnV0IGluZXZpdGFibGUgYmV0cmF5YWwh'
            LogType = 'TestLog'
        }

        & $Module.Logger $Log $Configuration

        Assert-MockCalled -CommandName 'Invoke-WebRequest' -Times 1 -Exactly
    }
}