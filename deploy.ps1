# Automated Deployment Script for ICT Help Desk Data Portal
# Usage: In PowerShell, run: .\deploy.ps1

Write-Host "==========================================" -ForegroundColor Green
Write-Host " Building Flutter Web (Production)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green

flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter build failed. Aborting deploy." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Compressing build output..." -ForegroundColor Cyan
tar.exe -czf web.tar.gz -C build/web .

Write-Host ""
Write-Host "Uploading web package to AlwaysData..." -ForegroundColor Cyan
Write-Host "(Please enter your AlwaysData SSH password if prompted)" -ForegroundColor Yellow
scp web.tar.gz npa-helpdesk-requestform@ssh-npa-helpdesk-requestform.alwaysdata.net:www/

Write-Host ""
Write-Host "Unpacking web package on server..." -ForegroundColor Cyan
ssh npa-helpdesk-requestform@ssh-npa-helpdesk-requestform.alwaysdata.net "cd www && tar -xzf web.tar.gz && rm web.tar.gz"

Write-Host ""
Write-Host "Uploading updated backend PHP files..." -ForegroundColor Cyan
scp update_status.php npa-helpdesk-requestform@ssh-npa-helpdesk-requestform.alwaysdata.net:www/help_desk_request/

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " Deployment Complete!" -ForegroundColor Green
Write-Host " Live at: https://npa-helpdesk-requestform.alwaysdata.net" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Green
