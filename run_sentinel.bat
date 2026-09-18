@echo off
echo ==========================================
echo      Starting HACKgaurd  System
echo ==========================================
echo.
cd /d "%~dp0"
echo [1/2] Launching Backend Server...
cd backend
start "HACKgaurd Server" python app.py

echo [2/2] Opening Dashboard...
timeout /t 3 >nul
start http://localhost:5000/index.html

echo.
echo Success! The system is now running.
echo Please keep the backend server window open.
echo.
pause 
