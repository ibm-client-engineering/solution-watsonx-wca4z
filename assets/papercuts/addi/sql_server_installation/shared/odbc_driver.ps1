$url = "https://go.microsoft.com/fwlink/?linkid=2249004"
$outputPath = "./msodbcsql.msi"
Invoke-WebRequest -Uri $url -OutFile $outputPath