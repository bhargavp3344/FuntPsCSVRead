using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$storageAccntName= $env:StorageAccountName
$storageaccesskey = $env:StorageAccountKey
$storageAccountContainerName = $env:StorageAccountContainerName
$strogaeAccountBlobName = $env:StorageaccountblobName
$localpathDnld= $env:PathtoDownloadCSV
$gvparam = $Request.Params.id

Write-Host $gvparam

 
try{
        
$param = [int]$gvparam 
   
write-Host "Param Value $param"
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$context= New-AzStorageContext -StorageAccountName $storageAccntName -StorageAccountKey $storageaccesskey

Get-AzStorageBlobContent -Context $context -Container $storageAccountContainerName -Blob $strogaeAccountBlobName  -Destination $localpathDnld -Force

# $blobdynamic = ConvertTo-Json (ConvertTo-Csv (Get-AzStorageBlobContent -Context $context -Container $storageAccountContainerName -Blob $strogaeAccountBlobName -Force).ICloudBlob.DownloadText())

$csvobj = Import-Csv -Path ".\emp.csv"


$retobj = $csvobj | Where-Object { $_.empid -eq $param}

# $retdata =  ConvertTo-Json $csvobj #ConvertTo-Json $TriggerMetadata # 
# Write-Host  "csv obj $firstname"

$retobj2= ConvertTo-Json $retobj

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$body = $retobj2


# $body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# if ($name) {
#     $body = "Hello, $name. This HTTP triggered function executed successfully."
# }

if($null -ne $retobj)
{
    Write-Host "if condition"
    $StatusCode = [HttpStatusCode]::OK
}
else {
    Write-Host "else condition"
    $StatusCode = [HttpStatusCode]::NotFound
    $body = $null
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    
   StatusCode=$StatusCode
   Body = $body
    
}) -Clobber


}
catch{
    
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        
    }) -Clobber
}   
    






