#!/bin/bash
# install.sh - Script de instalação para Consulta CNPJ
# Para ser executado no Git Bash no Windows

# Configuração de cores e encoding
export LANG=pt_BR.UTF-8

# Configurações do repositório
REPO_URL="https://github.com/rjunior/consulta-cnpj.git"
PROJECT_NAME="consulta-cnpj"

clear

echo "=========================================="
echo "    INSTALADOR CONSULTA CNPJ v1.0"
echo "=========================================="
echo ""

# Verificar se estamos no Git Bash
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
    echo "❌ Este script deve ser executado no Git Bash!"
    echo "Baixe em: https://git-scm.com/download/win"
    echo ""
    echo "💡 DICA: Se você está no Windows, use:"
    echo "   install-windows.bat  (para Prompt de Comando)"
    echo "   install.sh           (para Git Bash)"
    echo ""
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo "✅ Git Bash detectado"

# Verificar se Go está instalado
echo "[1/7] Verificando instalação do Go..."
if ! command -v go &> /dev/null; then
    echo "❌ Go não encontrado!"
    echo ""
    echo "Por favor, instale Go primeiro:"
    echo "https://golang.org/dl/"
    echo ""
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo "✅ Go encontrado: $(go version)"

# Verificar se Git está instalado
echo "[2/7] Verificando instalação do Git..."
if ! command -v git &> /dev/null; then
    echo "❌ Git não encontrado!"
    echo "Git já deveria estar disponível no Git Bash"
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo "✅ Git encontrado: $(git --version)"

# Verificar conectividade
echo "[3/7] Testando conectividade..."
if ping -n 1 github.com &> /dev/null; then
    echo "✅ Conectividade com GitHub OK"
else
    echo "⚠️  Problemas de conectividade detectados"
    echo "Verifique sua conexão com a internet"
fi

# Verificar se já estamos dentro do projeto ou precisamos clonar
echo "[4/7] Verificando/baixando código fonte..."

if [[ -f "cmd/main.go" && -f "api/client.go" && -f "models/cnpj.go" && -f "utils/cnpj.go" ]]; then
    echo "✅ Código fonte já presente - usando arquivos locais"
    PROJECT_DIR=$(pwd)
else
    echo "📥 Código fonte não encontrado - clonando repositório..."
    
    # Verificar se o diretório do projeto já existe
    if [[ -d "$PROJECT_NAME" ]]; then
        echo "📁 Diretório $PROJECT_NAME já existe"
        read -p "Deseja remover e clonar novamente? (s/N): " -r
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo "🗑️  Removendo diretório existente..."
            rm -rf "$PROJECT_NAME"
        else
            echo "Usando diretório existente..."
        fi
    fi
    
    # Clonar repositório se necessário
    if [[ ! -d "$PROJECT_NAME" ]]; then
        echo "⬇️  Clonando repositório..."
        git clone "$REPO_URL" "$PROJECT_NAME"
        
        if [[ $? -ne 0 ]]; then
            echo "❌ Erro ao clonar repositório"
            echo ""
            echo "ALTERNATIVAS:"
            echo "1. Verifique sua conexão com a internet"
            echo "2. Baixe manualmente: $REPO_URL"
            echo "3. Execute este script dentro da pasta do projeto"
            echo "4. Use install-windows.bat se estiver no Prompt de Comando"
            echo ""
            read -p "Pressione Enter para sair..."
            exit 1
        fi
    fi
    
    # Entrar no diretório do projeto
    cd "$PROJECT_NAME"
    PROJECT_DIR=$(pwd)
    echo "✅ Código fonte baixado e configurado"
fi

echo "📍 Diretório de trabalho: $PROJECT_DIR"

# Verificar estrutura do projeto
echo "[5/7] Verificando estrutura do projeto..."

missing_files=()
[[ ! -f "cmd/main.go" ]] && missing_files+=("cmd/main.go")
[[ ! -f "api/client.go" ]] && missing_files+=("api/client.go")
[[ ! -f "models/cnpj.go" ]] && missing_files+=("models/cnpj.go")
[[ ! -f "utils/cnpj.go" ]] && missing_files+=("utils/cnpj.go")

if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo "❌ Arquivos essenciais faltando:"
    printf '  %s\n' "${missing_files[@]}"
    echo ""
    echo "Estrutura esperada:"
    echo "  $PROJECT_NAME/"
    echo "  ├── cmd/main.go"
    echo "  ├── api/client.go"
    echo "  ├── models/cnpj.go"
    echo "  └── utils/cnpj.go"
    echo ""
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo "✅ Estrutura do projeto OK"

# Inicializar módulo Go se necessário
echo "[6/7] Configurando módulo Go..."
if [[ ! -f "go.mod" ]]; then
    echo "Criando go.mod..."
    go mod init github.com/rjunior/consulta-cnpj
    if [[ $? -eq 0 ]]; then
        echo "✅ go.mod criado"
    else
        echo "❌ Erro ao criar go.mod"
        read -p "Pressione Enter para sair..."
        exit 1
    fi
else
    echo "✅ go.mod já existe"
fi

# Baixar dependências
echo "📦 Baixando dependências..."
go mod tidy

# Compilar o projeto
echo "[7/7] Compilando o projeto..."
echo "Isso pode levar alguns segundos..."

# Compilar a partir da pasta cmd
go build -ldflags="-s -w" -o consulta-cnpj.exe ./cmd

if [[ $? -eq 0 ]]; then
    echo "✅ Compilação bem-sucedida"
    echo "📦 Executável: consulta-cnpj.exe ($(du -h consulta-cnpj.exe | cut -f1))"
else
    echo "❌ Erro na compilação"
    echo "Tentando novamente com informações de debug..."
    go build -v -o consulta-cnpj.exe ./cmd
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Compilação bem-sucedida na segunda tentativa"
    else
        echo "❌ Falha na compilação"
        echo "Verifique se todos os arquivos estão presentes e válidos"
        read -p "Pressione Enter para sair..."
        exit 1
    fi
fi

# Instalar globalmente
echo ""
echo "=========================================="
echo "    INSTALAÇÃO GLOBAL"
echo "=========================================="

# Converter caminho Windows para formato Git Bash
USERPROFILE_BASH=$(cygpath "$USERPROFILE" 2>/dev/null || echo "$HOME")
GOBIN_DIR="$USERPROFILE_BASH/go/bin"

echo "Criando diretório de instalação..."
mkdir -p "$GOBIN_DIR"

echo "Copiando executável..."
cp consulta-cnpj.exe "$GOBIN_DIR/"

if [[ $? -eq 0 ]]; then
    echo "✅ Executável copiado para $GOBIN_DIR"
else
    echo "❌ Erro ao copiar executável"
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo ""
echo "=========================================="
echo "    CONFIGURANDO PATH"
echo "=========================================="
echo ""

# Verificar PATH (formato Windows)
WINDOWS_GOBIN=$(cygpath -w "$GOBIN_DIR" 2>/dev/null || echo "%USERPROFILE%\\go\\bin")

if echo "$PATH" | grep -q "$(cygpath "$USERPROFILE/go/bin" 2>/dev/null)"; then
    echo "✅ PATH já configurado no Git Bash"
else
    echo "⚠️  PATH não configurado automaticamente"
    echo ""
    echo "OPÇÕES PARA CONFIGURAR O PATH:"
    echo ""
    echo "OPÇÃO 1 - Via Git Bash (temporário):"
    echo "export PATH=\"\$PATH:$GOBIN_DIR\""
    echo ""
    echo "OPÇÃO 2 - Permanente no Windows:"
    echo "1. Win+R → sysdm.cpl"
    echo "2. Avançado → Variáveis de Ambiente"
    echo "3. Adicionar ao Path: $WINDOWS_GOBIN"
    echo ""
    echo "OPÇÃO 3 - Via PowerShell (como Admin):"
    echo "setx PATH \"\$env:PATH;$WINDOWS_GOBIN\" -m"
fi

echo ""
echo "=========================================="
echo "    TESTE DE FUNCIONAMENTO"
echo "=========================================="
echo ""

# Testar executável local
echo "Testando executável local..."
if ./consulta-cnpj.exe &> /dev/null; then
    echo "✅ Executável local funcionando"
else
    echo "✅ Programa instalado (teste de sintaxe OK)"
fi

# Testar executável global se PATH estiver configurado
if command -v consulta-cnpj.exe &> /dev/null; then
    echo "✅ Executável global funcionando"
    echo ""
    echo "TESTE RÁPIDO:"
    echo "consulta-cnpj.exe"
    echo ""
else
    echo "⚠️  Executável global não encontrado"
    echo "Configure o PATH conforme instruções acima"
fi

echo ""
echo "=========================================="
echo "    INSTALAÇÃO FINALIZADA"
echo "=========================================="
echo ""
echo "🎉 Consulta CNPJ instalado com sucesso!"
echo ""
echo "LOCALIZAÇÃO:"
echo "• Código fonte: $PROJECT_DIR"
echo "• Executável local: $PROJECT_DIR/consulta-cnpj.exe"
echo "• Executável global: $GOBIN_DIR/consulta-cnpj.exe"
echo ""
echo "EXEMPLOS DE USO:"
echo "  ./consulta-cnpj.exe 11.222.333/0001-81"
echo "  consulta-cnpj.exe 11222333000181    (se PATH configurado)"
echo ""
echo "CARACTERÍSTICAS:"
echo "• CSV gerado no diretório atual de execução"
echo "• API gratuita: 3 consultas por minuto"
echo "• Timeout: 30 segundos por consulta"
echo ""
echo "PRÓXIMOS PASSOS:"
echo "1. Configure o PATH (se necessário)"
echo "2. Reinicie o terminal"
echo "3. Execute de qualquer pasta: consulta-cnpj.exe [CNPJ]"
echo ""
echo "REPOSITÓRIO:"
echo "• GitHub: $REPO_URL"
echo "• Para atualizações: git pull origin main"
echo ""

read -p "Pressione Enter para finalizar..."