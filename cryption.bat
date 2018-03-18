@echo off

if "%1"=="en" (
    FOR %%i IN (source/_posts/*.md) DO gpg --batch --yes -ea -r DBE1822F source/_posts/%%i
    FOR %%i IN (source/_drafts/*.md) DO gpg --batch --yes -ea -r DBE1822F source/_drafts/%%i
    echo Encrypt OK
)

if "%1"=="de" (
    FOR %%i IN (source/_posts/*.asc) DO gpg --batch --yes source/_posts/%%i
    FOR %%i IN (source/_drafts/*.asc) DO gpg --batch --yes source/_drafts/%%i
    echo Decrypt OK
)

if "%1" NEQ "en" if "%1" NEQ "de" (
    echo Usage:
    echo   %0 [en de]
    echo   [en] is Encrypt Source. [de] is Decrypt Source.
)
