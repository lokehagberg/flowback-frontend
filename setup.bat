@echo off

REM This file allows for convenient setup for flowback backend and frontend at once. 

REM Make sure to change "cd ..; cd flowback-backend;" if your instalation path for flowback-backend is different
REM Also make sure that docker is running

REM Backend setup
start powershell -NoExit -Command cd ..; cd flowback-backend; venv/Scripts/activate; git fetch; git pull; python manage.py migrate; python manage.py runserver 

REM Frontend setup
start  powershell -NoExit -Command Start-Process "http://localhost:4000"; npm run dev;
