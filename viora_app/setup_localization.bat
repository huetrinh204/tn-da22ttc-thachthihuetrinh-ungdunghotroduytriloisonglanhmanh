@echo off
echo ========================================
echo Setup Localization for Viora App
echo ========================================
echo.

echo [1/3] Installing dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)
echo.

echo [2/3] Generating localization files...
call flutter gen-l10n
if %errorlevel% neq 0 (
    echo Error: Failed to generate localization files
    pause
    exit /b 1
)
echo.

echo [3/3] Cleaning build...
call flutter clean
call flutter pub get
echo.

echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo You can now run: flutter run
echo.
pause
