:: Licensed Materials - Property of IBM
:: 5737-B16
:: © Copyright IBM Corp. 2023
:: US Government Users Restricted Rights- Use, duplication or disclosure 
:: restricted by GSA ADP  Schedule Contract with IBM Corp.
@echo off
setlocal

:: Parse input arguments
set allInputArgs=%*

:parseInputArgsLoop
for /f "tokens=1*" %%a in ("%allInputArgs%") do (
	for /F "delims=^= tokens=1,2" %%i in ("%%a") do (
		if [%%i]==[dbName] set dbName=%%j
		if [%%i]==[db2Host] set db2Host=%%j
		if [%%i]==[db2Port] set db2Port=%%j
		if [%%i]==[db2User] set db2User=%%j
		if [%%i]==[db2Password] set db2Password=%%j
		if [%%i]==[useTLS] set useTLS=%%j
	)
   
	set allInputArgs=%%b
)
if defined allInputArgs goto :parseInputArgsLoop

if [%dbName%]==[] call :missingInputArgument dbName && exit /B 1
if [%db2Host%]==[] call :missingInputArgument db2Host && exit /B 1
if [%db2Port%]==[] call :missingInputArgument db2Port && exit /B 1
if [%db2User%]==[] call :missingInputArgument db2User && exit /B 1
if [%db2Password%]==[] call :missingInputArgument db2Password && exit /B 1
if [%useTLS%]==[] call :missingInputArgument useTLS && exit /B 1

:: Get script's execution folder and remove the trailing backslash
set base=%~dp0
set base=%base:~0,-1%

:: Set log file path
set logFile="%base%\%~n0.log"

:: Run the curl GET API to get active Environment ID and store CSRF token 
curl -i -k -c cookie.txt "https://localhost:9443/ad/admin/api/configuration/environments/active" > %logFile% 2>&1

:: Read log file for XSRF token
for /F "delims=^=; tokens=2*" %%i in ('findstr /c:"XSRF-TOKEN=" %logFile%') do (
	set XSRF_TOKEN=%%i
)

if [%XSRF_TOKEN%]==[] echo XSRF token is empty. Make sure ADDI Websphere Liberty Profile server is running and https://localhost:9443/ad/admin/dashboard is accessible. && exit /B 2

:: Read log file for environment id
for /F "delims=:, tokens=2*" %%i in ('findstr /c:"\"id\":" %logFile%') do (
	for /F delims^=^"^ tokens^=1 %%e in ("%%i") do (
		set ENVIRONMENT_ID=%%e
	)
)

if [%ENVIRONMENT_ID%]==[] echo Environment ID is empty. Make sure ADDI Websphere Liberty Profile server is running and https://localhost:9443/ad/admin/dashboard is accessible. && exit /B 2

:: Run the curl POST API to add DB2 on Cloud db instance into ADDI
echo Adding new DB2 database instance into ADDI
curl -k -b cookie.txt "https://localhost:9443/ad/admin/api/configuration/environments/%ENVIRONMENT_ID%/rds" -H "X-XSRF-TOKEN: %XSRF_TOKEN%" -H "Content-Type: application/json; charset=""utf-8""" --data-raw "{""formatVersion"":""2.0"",""dataVersion"":0,""name"":""%dbName%"",""host"":""%db2Host%"",""port"":%db2Port%,""instance"":"""",""location"":"""",""storageGroup"":"""",""dbName"":"""",""username"":""%db2User%"",""password"":""%db2Password%"",""useTLS"":%useTLS%,""active"":false,""type"":""db2""}" >> %logFile% 2>&1

:: Read log file for response and verify success
find "%dbName%" %logFile% >nul
if %ERRORLEVEL% equ 0 (echo Success.) else (echo Failed. Check %logFile% for more details.)

exit /B 0

:missingInputArgument
echo %~1 is missing from the input arguments. Script usage "configureDB2DatabaseADDI.bat dbName=<DB_NAME> db2Host=<HOST_NAME> db2Port=<PORT_NUMBER> db2User=<USER_NAME> db2Password=<PASSWORD> useTLS=<true_false>" && exit /B 0

endlocal