CLS
ECHO OFF
CHCP 866

REM Variables

SET PGBIN=C:\Program Files\PostgreSQL\10.9-5.1C\bin
SET PGDATABASE=DB_LH
SET PGHOST=127.0.0.1
SET PGPORT=5432
SET PGUSER=postgres
SET PGPASSWORD=postgres
SET BackupFolder=C:\beki
SET BackupsNumber=29


REM ПЕРЕХОД В КАТАЛОГ С bat-ФАЙЛОМ (ОТКУДА ЗАПУЩЕН ФАЙЛ)
%~d0
CD %~dp0

REM ФОРМИРОВАНИЕ ИМЕНИ ФАЙЛА ДЛЯ РЕЗЕРВНОЙ КОПИИ И LOG ФАЙЛА ОТЧЕТА
SET DAT=%date:~0,2%%date:~3,2%%date:~6,4%
SET DUMPFILE=%BackupFolder%\%DAT%-%PGDATABASE%.pgsql.backup
SET LOGFILE=%BackupFolder%\%DAT%-%PGDATABASE%.pgsql.log
SET DUMPPATH="%DUMPFILE%"
SET LOGPATH="%LOGFILE%"


REM ВЫПОЛНЕНИЕ КОМАНДЫ (ПРОГРАММЫ) ДЛЯ СОЗДАНИЕ РЕЗЕРВНОЙ КОПИИ БАЗЫ
CALL "%PGBIN%\pg_dump.exe" --format=custom --verbose --file=%DUMPPATH% 2>%LOGPATH%

REM ВЫПОЛНЕНИЕ КОМАНДЫ (ПРОГРАММЫ) ЗАВЕРШЕНО, ЕСЛИ ОШИБОК НЕТ ТО КОНЕЦ
IF NOT %ERRORLEVEL%==0 GOTO Error
GOTO Successfull
REM ПРИ ВОЗНИКНОВЕНИИ ОШИБОК УДАЛЯЕТСЯ ПОВРЕЖДЕННЫЙ ФАЙЛ КОПИИ И СООТВЕТСТВУЮЩАЯ ЗАПИСЬ В ЖУРНАЛЕ О ЕЕ СОЗДАНИИ
:Error
DEL %DUMPPATH%
MSG * "oshibka pri sozdanii rezervnoi kopii BD. Smotrite backup_%PGDATABASE%.log."
ECHO %DATETIME%  oshibki pri sozdanii rezervnoi kopii BD %DUMPFILE%. Smotrite otchet %LOGFILE%. >> backup_%PGDATABASE%.log
GOTO End

REM ЕСЛИ КОПИЯ СДЕЛАНА БЕЗ ОШИБОК ДЕЛАЕТСЯ ЗАПИСЬ В ЖУРНАЛЕ РЕГИСТРАЦИИ
:Successfull
ECHO %DATETIME% Uspeshnoe sozdanie kopii %DUMPFILE% >> backup_%PGDATABASE%.log
GOTO End
:End

Forfiles -p "%BackupFolder%" -s -m *.* -d -%BackupsNumber% -c "cmd /c del /q @path"
