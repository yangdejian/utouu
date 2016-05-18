cls
@echo off
tasklist|find /i "FlowCenter.exe" ||exit
taskkill /im FlowCenter.exe /f