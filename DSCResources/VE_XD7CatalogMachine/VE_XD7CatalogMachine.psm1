Import-LocalizedData -BindingVariable localizedData -FileName VE_XD7CatalogMachine.Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Members,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    begin {

        AssertXDModule -Name 'Citrix.Broker.Admin.V2' -IsSnapin;

    }
    process {

        $scriptBlock = {

            Add-PSSnapin -Name 'Citrix.Broker.Admin.V2' -ErrorAction Stop;
            $brokerMachines = Get-BrokerMachine -CatalogName $using:Name | Select-Object -ExpandProperty DnsName;

            $targetResource = @{
                Name = $using:Name;
                Members = $brokerMachines;
                Ensure = $using:Ensure;
            }

            return $targetResource;

        } #end scriptBlock

        $invokeCommandParams = @{
            ScriptBlock = $scriptBlock;
            ErrorAction = 'Stop';
        }

        Write-Verbose ($localizedData.InvokingScriptBlockWithParams -f [System.String]::Join("','", @($Name)));
        if ($Credential) {
            AddInvokeScriptBlockCredentials -Hashtable $invokeCommandParams -Credential $Credential;
            $targetResource =  Invoke-Command  @invokeCommandParams;
        }
        else {
            $invokeScriptBlock = [System.Management.Automation.ScriptBlock]::Create($scriptBlock.ToString().Replace('$using:','$'));
            $targetResource = InvokeScriptBlock -ScriptBlock $invokeScriptBlock;
        }
        return $targetResource;

    } #end process
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Members,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {

        $targetResource = Get-TargetResource @PSBoundParameters;

        if (TestXDMachineMembership -RequiredMembers $Members -ExistingMembers $targetResource.Members -Ensure $Ensure) {

            Write-Verbose ($localizedData.ResourcePropertyMismatch -f 'Members', $Members, $targetResource.Members);
            Write-Verbose ($localizedData.ResourceInDesiredState -f $Name);
            return $true;
        }
        else {

            Write-Verbose ($localizedData.ResourceNotInDesiredState -f $Name);
            return $false;
        }

    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Members,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    begin {

        AssertXDModule -Name 'Citrix.Broker.Admin.V2' -IsSnapin;

    }
    process {

        $scriptBlock = {

            Add-PSSnapin -Name 'Citrix.Broker.Admin.V2' -ErrorAction Stop;
            ## Load modules from relative path to avoid v5 module versioning interference (#15)
            Import-Module (Join-Path -Path $using:moduleParent -ChildPath 'VE_XD7Common');

            $brokerMachines = Get-BrokerMachine -CatalogName $using:Name;
            $brokerCatalog = Get-BrokerCatalog -Name $using:Name;

            foreach ($member in $using:Members) {

                $brokerMachine = ResolveXDBrokerMachine -MachineName $member -BrokerMachines $brokerMachines;
                if (($using:Ensure -eq 'Absent') -and ($brokerMachine.CatalogName -eq $using:Name)) {

                    Write-Verbose ($using:localizedData.RemovingMachineCatalogMachine -f $member, $using:Name);
                    $brokerMachine | Remove-BrokerMachine -CatalogName $using:Name -Force;
                }
                elseif (($using:Ensure -eq 'Present') -and ($brokerMachine.CatalogName -ne $using:Name)) {

                    [ref] $null = New-BrokerMachine -MachineName $member -CatalogUid $brokerCatalog.Uid -ErrorAction Stop;
                }

            } #end foreach member

        } #end scriptBlock

        $invokeCommandParams = @{
            ScriptBlock = $scriptBlock;
            ErrorAction = 'Stop';
        }

        Write-Verbose ($localizedData.InvokingScriptBlockWithParams -f [System.String]::Join("','", @($Name, $Members, $Ensure)));
        if ($Credential) {
            AddInvokeScriptBlockCredentials -Hashtable $invokeCommandParams -Credential $Credential;
            [ref] $null = Invoke-Command @invokeCommandParams;
        }
        else {
            $invokeScriptBlock = [System.Management.Automation.ScriptBlock]::Create($scriptBlock.ToString().Replace('$using:','$'));
            [ref] $null = InvokeScriptBlock -ScriptBlock $invokeScriptBlock;
        }
    } #end process
} #end function Set-TargetResource


$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;

## Import the XD7Common library functions
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_XD7Common');

## Import the InvokeScriptBlock function into the current scope
. (Join-Path -Path (Join-Path -Path $moduleParent -ChildPath 'VE_XD7Common') -ChildPath 'InvokeScriptBlock.ps1');

Export-ModuleMember -Function *-TargetResource;
