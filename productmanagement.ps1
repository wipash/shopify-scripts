[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$StoreName = ""
$Username = "API USERNAME"
$Password = "API PASSWORD"

$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

$StoreURL = "https://$($StoreName).myshopify.com/admin/api/2020-01"

$ResultSize = 250

$products = (Invoke-RestMethod -Uri "$($StoreURL)/products.json?limit=$($ResultSize)" -ContentType "application/json" -Method Get -Headers $headers).products

$products.Count


## Sort Variants
#$artprints = $products | Where-Object { $_.product_type -like "Art Print" }
# foreach ($product in $artprints) {
#     Write-Host "$($product.title) - $($product.id)"
#     $variants = $product.variants | Sort-Object -property @{ Expression = { [int]$_.title.substring(1, 1) } } -descending | Select-Object id
#     $payload = @{
#         product = @{
#             id       = $product.id
#             variants = $variants
#         }
#     }
#     $result = Invoke-RestMethod -Uri "$($StoreURL)/products/$($product.id).json" -ContentType "application/json" -Method Put -Body ($payload | ConvertTo-Json -Depth 10) -Authentication Basic -Credential $credential
# }

## Remove <a> tags from description
foreach ($product in $products) {
    Write-Host "$($product.title) - $($product.id)"
    $body_html = ($product.body_html -replace "<a.+<\/a>", "")
    $payload = @{
        product = @{
            id        = $product.id
            body_html = $body_html
        }
    }
    $payload = $payload | ConvertTo-Json -Depth 10 -EscapeHandling EscapeNonAscii
    $result = Invoke-RestMethod -Uri "$($StoreURL)/products/$($product.id).json" -ContentType "application/json" -Method Put -Body $payload -Authentication Basic -Credential $credential
}

