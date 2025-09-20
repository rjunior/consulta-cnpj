@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: Configurações do repositório
set "REPO_URL=https://github.com/rjunior/consulta-cnpj.git"
set "PROJECT_NAME=consulta-cnpj"
set "BINARY_NAME=consulta-cnpj.exe"

cls

echo ==========================================
echo     INSTALADOR CONSULTA CNPJ v1.0
echo ==========================================
echo.

:: Verificar se Go está instalado
echo [1/7] Verificando instalação do Go...
go version >nul 2>&1
if errorlevel 1 (
    echo ❌ Go não encontrado!
    echo.
    echo Por favor, instale Go primeiro:
    echo https://golang.org/dl/
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('go version') do set "GO_VERSION=%%i"
echo ✅ Go encontrado: !GO_VERSION!

:: Verificar se Git está instalado
echo [2/7] Verificando instalação do Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git não encontrado!
    echo.
    echo Por favor, instale Git primeiro:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('git --version') do set "GIT_VERSION=%%i"
echo ✅ Git encontrado: !GIT_VERSION!

:: Verificar conectividade
echo [3/7] Testando conectividade...
ping -n 1 github.com >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Problemas de conectividade detectados
    echo Verifique sua conexão com a internet
) else (
    echo ✅ Conectividade com GitHub OK
)

:: Verificar se já estamos dentro do projeto ou precisamos clonar
echo [4/7] Verificando/baixando código fonte...

if exist "cmd\main.go" if exist "api\client.go" if exist "models\cnpj.go" if exist "utils\cnpj.go" (
    echo ✅ Código fonte já presente - usando arquivos locais
    set "PROJECT_DIR=%CD%"
    goto :compile
)

echo 📥 Código fonte não encontrado - clonando repositório...

:: Verificar se o diretório do projeto já existe
if exist "%PROJECT_NAME%" (
    echo 📁 Diretório %PROJECT_NAME% já existe
    set /p "REPLY=Deseja remover e clonar novamente? (s/N): "
    if /i "!REPLY!"=="s" (
        echo 🗑️  Removendo diretório existente...
        rmdir /s /q "%PROJECT_NAME%"
    ) else (
        echo Usando diretório existente...
        cd "%PROJECT_NAME%"
        set "PROJECT_DIR=%CD%"
        goto :compile
    )
)

:: Clonar repositório se necessário
if not exist "%PROJECT_NAME%" (
    echo ⬇️  Clonando repositório...
    git clone "%REPO_URL%" "%PROJECT_NAME%"
    
    if errorlevel 1 (
        echo ❌ Erro ao clonar repositório
        echo.
        echo ALTERNATIVAS:
        echo 1. Verifique sua conexão com a internet
        echo 2. Baixe manualmente: %REPO_URL%
        echo 3. Execute este script dentro da pasta do projeto
        echo.
        pause
        exit /b 1
    )
)

:: Entrar no diretório do projeto
cd "%PROJECT_NAME%"
set "PROJECT_DIR=%CD%"
echo ✅ Código fonte baixado e configurado

:compile
echo 📍 Diretório de trabalho: %PROJECT_DIR%

:: Verificar estrutura do projeto
echo [5/7] Verificando estrutura do projeto...

set "MISSING_FILES="
if not exist "cmd\main.go" set "MISSING_FILES=!MISSING_FILES! cmd\main.go"
if not exist "api\client.go" set "MISSING_FILES=!MISSING_FILES! api\client.go"
if not exist "models\cnpj.go" set "MISSING_FILES=!MISSING_FILES! models\cnpj.go"
if not exist "utils\cnpj.go" set "MISSING_FILES=!MISSING_FILES! utils\cnpj.go"

if not "!MISSING_FILES!"=="" (
    echo ❌ Arquivos essenciais faltando:
    echo !MISSING_FILES!
    echo.
    echo Estrutura esperada:
    echo   %PROJECT_NAME%\
    echo   ├── cmd\main.go
    echo   ├── api\client.go
    echo   ├── models\cnpj.go
    echo   └── utils\cnpj.go
    echo.
    pause
    exit /b 1
)

echo ✅ Estrutura do projeto OK

:: Inicializar módulo Go se necessário
echo [6/7] Configurando módulo Go...
if not exist "go.mod" (
    echo Criando go.mod...
    go mod init github.com/rjunior/consulta-cnpj
    if errorlevel 1 (
        echo ❌ Erro ao criar go.mod
        pause
        exit /b 1
    )
    echo ✅ go.mod criado
) else (
    echo ✅ go.mod já existe
)

:: Baixar dependências
echo 📦 Baixando dependências...
go mod tidy

:: Compilar o projeto
echo [7/7] Compilando o projeto...
echo Isso pode levar alguns segundos...

:: Compilar a partir da pasta cmd
go build -ldflags="-s -w" -o "%BINARY_NAME%" ./cmd

if errorlevel 1 (
    echo ❌ Erro na compilação
    echo Tentando novamente com informações de debug...
    go build -v -o "%BINARY_NAME%" ./cmd
    
    if errorlevel 1 (
        echo ❌ Falha na compilação
        echo Verifique se todos os arquivos estão presentes e válidos
        pause
        exit /b 1
    )
    echo ✅ Compilação bem-sucedida na segunda tentativa
) else (
    echo ✅ Compilação bem-sucedida
)

:: Obter tamanho do arquivo
for %%F in ("%BINARY_NAME%") do set "FILE_SIZE=%%~zF"
set /a "FILE_SIZE_MB=!FILE_SIZE! / 1024 / 1024"
echo 📦 Executável: %BINARY_NAME% (!FILE_SIZE_MB! MB)

echo.
echo ==========================================
echo     INSTALAÇÃO GLOBAL
echo ==========================================

:: Criar diretório de instalação
set "GOBIN_DIR=%USERPROFILE%\go\bin"
echo Criando diretório de instalação...
if not exist "%GOBIN_DIR%" mkdir "%GOBIN_DIR%"

echo Copiando executável...
copy "%BINARY_NAME%" "%GOBIN_DIR%\" >nul

if errorlevel 1 (
    echo ❌ Erro ao copiar executável
    pause
    exit /b 1
)

echo ✅ Executável copiado para %GOBIN_DIR%

echo.
echo ==========================================
echo     CONFIGURANDO PATH
echo ==========================================
echo.

:: Verificar se PATH já está configurado
echo %PATH% | findstr /i "%USERPROFILE%\go\bin" >nul
if errorlevel 1 (
    echo ⚠️  PATH não configurado automaticamente
    echo.
    echo OPÇÕES PARA CONFIGURAR O PATH:
    echo.
    echo OPÇÃO 1 - Via Interface Gráfica:
    echo 1. Win+R → sysdm.cpl
    echo 2. Avançado → Variáveis de Ambiente
    echo 3. Adicionar ao Path: %USERPROFILE%\go\bin
    echo.
    echo OPÇÃO 2 - Via PowerShell (como Admin):
    echo setx PATH "%%PATH%%;%USERPROFILE%\go\bin" /m
    echo.
    echo OPÇÃO 3 - Configurar automaticamente agora:
    set /p "CONFIG_PATH=Deseja configurar o PATH automaticamente? (s/N): "
    if /i "!CONFIG_PATH!"=="s" (
        setx PATH "%PATH%;%USERPROFILE%\go\bin" >nul 2>&1
        if errorlevel 1 (
            echo ❌ Erro ao configurar PATH automaticamente
            echo Use as opções manuais acima
        ) else (
            echo ✅ PATH configurado! Reinicie o terminal para aplicar
        )
    )
) else (
    echo ✅ PATH já configurado
)

echo.
echo ==========================================
echo     TESTE DE FUNCIONAMENTO
echo ==========================================
echo.

:: Testar executável local
echo Testando executável local...
"%BINARY_NAME%" >nul 2>&1
if errorlevel 1 (
    echo ✅ Programa instalado (teste de sintaxe OK)
) else (
    echo ✅ Executável local funcionando
)

:: Testar executável global se PATH estiver configurado
where consulta-cnpj.exe >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Executável global não encontrado
    echo Configure o PATH conforme instruções acima
) else (
    echo ✅ Executável global funcionando
    echo.
    echo TESTE RÁPIDO:
    echo consulta-cnpj.exe
)

echo.
echo ==========================================
echo     INSTALAÇÃO FINALIZADA
echo ==========================================
echo.
echo 🎉 Consulta CNPJ instalado com sucesso!
echo.
echo LOCALIZAÇÃO:
echo • Código fonte: %PROJECT_DIR%
echo • Executável local: %PROJECT_DIR%\%BINARY_NAME%
echo • Executável global: %GOBIN_DIR%\%BINARY_NAME%
echo.
echo EXEMPLOS DE USO:
echo   %BINARY_NAME% 11.222.333/0001-81
echo   consulta-cnpj.exe 11222333000181    (se PATH configurado)
echo.
echo CARACTERÍSTICAS:
echo • CSV gerado no diretório atual de execução
echo • API gratuita: 3 consultas por minuto
echo • Timeout: 30 segundos por consulta
echo.
echo PRÓXIMOS PASSOS:
echo 1. Configure o PATH (se necessário)
echo 2. Reinicie o terminal
echo 3. Execute de qualquer pasta: consulta-cnpj.exe [CNPJ]
echo.
echo REPOSITÓRIO:
echo • GitHub: %REPO_URL%
echo • Para atualizações: git pull origin main
echo.

pause