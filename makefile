# ==========================================
# MAKEFILE PARA CONSULTA CNPJ - GIT BASH
# ==========================================
# 
# Requisitos:
#   - Git Bash instalado
#   - Go instalado
#   - Git instalado
#   - Conexão com internet
#
# Uso básico:
#   make setup          - Clonar repositório e configurar
#   make install        - Instalar o programa globalmente
#   make build          - Compilar o programa
#   make run CNPJ=xxx   - Executar busca para o CNPJ informado
#   make clean          - Limpar arquivos gerados
#   make help           - Mostrar ajuda
#
# Exemplo:
#   make setup
#   make run CNPJ=11.222.333/0001-81

# Configurações básicas
BINARY_NAME := consulta-cnpj.exe
MODULE_NAME := github.com/rjunior/consulta-cnpj
REPO_URL := https://github.com/rjunior/consulta-cnpj.git
PROJECT_NAME := consulta-cnpj

# Verificar se estamos no Git Bash
SHELL := /bin/bash

# Diretórios
USERPROFILE_BASH := $(shell cygpath "$$USERPROFILE" 2>/dev/null || echo "$$HOME")
GOBIN_DIR := $(USERPROFILE_BASH)/go/bin

.PHONY: all setup clone pull install build run clean help version check test update

# Target padrão
all: setup build

# Verificar dependências básicas
check-deps:
	@echo "=========================================="
	@echo "  VERIFICANDO DEPENDÊNCIAS"
	@echo "=========================================="
	@echo "Verificando Git Bash..."
	@[[ "$$OSTYPE" == "msys" || "$$OSTYPE" == "cygwin" ]] || { echo "❌ Execute no Git Bash!"; exit 1; }
	@echo "✅ Git Bash OK"
	@echo "Verificando Go..."
	@command -v go >/dev/null 2>&1 || { echo "❌ Go não instalado!"; echo "Baixe em: https://golang.org/dl/"; exit 1; }
	@echo "✅ Go encontrado: $$(go version)"
	@echo "Verificando Git..."
	@command -v git >/dev/null 2>&1 || { echo "❌ Git não encontrado!"; exit 1; }
	@echo "✅ Git encontrado: $$(git --version)"
	@echo "Verificando conectividade..."
	@ping -c 1 -W 2000 github.com >/dev/null 2>&1 && echo "✅ Conectividade OK" || echo "⚠️  Aviso: Problemas de conectividade"
	@echo

# Clonar repositório
clone: check-deps
	@echo "=========================================="
	@echo "  CLONANDO REPOSITÓRIO"
	@echo "=========================================="
	@if [[ -d "$(PROJECT_NAME)" ]]; then \
		echo "📁 Diretório $(PROJECT_NAME) já existe"; \
		read -p "Deseja remover e clonar novamente? (s/N): " -r; \
		if [[ $$REPLY =~ ^[Ss]$$ ]]; then \
			echo "🗑️  Removendo diretório existente..."; \
			rm -rf "$(PROJECT_NAME)"; \
		else \
			echo "✅ Usando diretório existente"; \
			exit 0; \
		fi; \
	fi
	@echo "⬇️  Clonando repositório..."
	@git clone $(REPO_URL) $(PROJECT_NAME)
	@if [[ $$? -eq 0 ]]; then \
		echo "✅ Repositório clonado com sucesso"; \
		echo "📍 Local: $$(pwd)/$(PROJECT_NAME)"; \
	else \
		echo "❌ Erro ao clonar repositório"; \
		echo "Verifique: $(REPO_URL)"; \
		exit 1; \
	fi
	@echo

# Atualizar repositório existente
pull:
	@echo "=========================================="
	@echo "  ATUALIZANDO REPOSITÓRIO"
	@echo "=========================================="
	@if [[ -d ".git" ]]; then \
		echo "🔄 Atualizando repositório local..."; \
		git pull origin main; \
		echo "✅ Repositório atualizado"; \
	else \
		echo "❌ Não é um repositório Git"; \
		echo "Execute: make clone"; \
		exit 1; \
	fi
	@echo

# Configurar projeto (clonar se necessário e verificar estrutura)
setup:
	@echo "=========================================="
	@echo "  CONFIGURAÇÃO DO PROJETO"
	@echo "=========================================="
	@$(MAKE) check-deps
	@if [[ -f "cmd/main.go" && -f "api/client.go" && -f "models/cnpj.go" && -f "utils/cnpj.go" ]]; then \
		echo "✅ Código fonte já presente - usando arquivos locais"; \
	else \
		echo "📥 Código fonte não encontrado - executando clone..."; \
		$(MAKE) clone; \
		echo "📂 Entrando no diretório do projeto..."; \
		cd $(PROJECT_NAME); \
	fi
	@$(MAKE) check
	@echo "✅ Configuração concluída"
	@echo

# Verificar estrutura do projeto
check: check-deps
	@echo "=========================================="
	@echo "  VERIFICANDO ESTRUTURA"
	@echo "=========================================="
	@echo "Verificando estrutura do projeto..."
	@test -f cmd/main.go || { echo "❌ cmd/main.go não encontrado!"; echo "Execute: make setup"; exit 1; }
	@test -f api/client.go || { echo "❌ api/client.go não encontrado!"; exit 1; }
	@test -f models/cnpj.go || { echo "❌ models/cnpj.go não encontrado!"; exit 1; }
	@test -f utils/cnpj.go || { echo "❌ utils/cnpj.go não encontrado!"; exit 1; }
	@echo "✅ Estrutura do projeto OK"
	@echo

# Inicializar módulo Go
init:
	@echo "=========================================="
	@echo "  INICIALIZANDO MÓDULO GO"
	@echo "=========================================="
	@if [[ ! -f "go.mod" ]]; then \
		echo "Criando go.mod..."; \
		go mod init $(MODULE_NAME); \
		echo "✅ go.mod criado"; \
	else \
		echo "✅ go.mod já existe"; \
	fi
	@echo "📦 Baixando dependências..."
	@go mod tidy
	@echo

# Compilar o programa
build: check init
	@echo "=========================================="
	@echo "  COMPILANDO CONSULTA CNPJ"
	@echo "=========================================="
	@echo "Compilando para Windows..."
	@go build -ldflags="-s -w" -o $(BINARY_NAME) ./cmd
	@if [[ $$? -eq 0 ]]; then \
		echo "✅ Compilação concluída!"; \
		echo "📦 Arquivo gerado: $(BINARY_NAME) ($$(du -h $(BINARY_NAME) | cut -f1))"; \
	else \
		echo "❌ Erro na compilação"; \
		exit 1; \
	fi
	@echo

# Instalar globalmente
install: build
	@echo "=========================================="
	@echo "  INSTALANDO GLOBALMENTE"
	@echo "=========================================="
	@echo "Criando diretório de instalação..."
	@mkdir -p "$(GOBIN_DIR)"
	@echo "Copiando executável..."
	@cp $(BINARY_NAME) "$(GOBIN_DIR)/"
	@if [[ $$? -eq 0 ]]; then \
		echo "✅ Instalação concluída!"; \
		echo "📍 Local: $(GOBIN_DIR)/$(BINARY_NAME)"; \
	else \
		echo "❌ Erro na instalação"; \
		exit 1; \
	fi
	@echo "CONFIGURAR PATH:"
	@echo "Windows: Adicione $(shell cygpath -w "$(GOBIN_DIR)" 2>/dev/null || echo "%USERPROFILE%\\go\\bin") ao PATH"
	@echo "Git Bash: export PATH=\"\$$PATH:$(GOBIN_DIR)\""
	@echo

# Executar com CNPJ informado
run: build
	@echo "=========================================="
	@echo "  EXECUTANDO COM CNPJ: $(CNPJ)"
	@echo "=========================================="
	@if [[ -z "$(CNPJ)" ]]; then \
		echo "❌ CNPJ não informado!"; \
		echo "Uso: make run CNPJ=11.222.333/0001-81"; \
		exit 1; \
	fi
	@echo "🔍 Consultando: $(CNPJ)"
	@echo
	@./$(BINARY_NAME) "$(CNPJ)"

# Testar executável
test: build
	@echo "=========================================="
	@echo "  TESTANDO EXECUTÁVEL"
	@echo "=========================================="
	@echo "Teste local..."
	@./$(BINARY_NAME) >/dev/null 2>&1 && echo "❌ Erro: deveria falhar sem parâmetros" || echo "✅ Teste local OK"
	@if command -v consulta-cnpj.exe >/dev/null 2>&1; then \
		echo "Teste global..."; \
		consulta-cnpj.exe >/dev/null 2>&1 && echo "❌ Erro: deveria falhar sem parâmetros" || echo "✅ Teste global OK"; \
	else \
		echo "⚠️  Executável global não encontrado (PATH não configurado)"; \
	fi
	@echo

# Limpar arquivos gerados
clean:
	@echo "=========================================="
	@echo "  LIMPANDO ARQUIVOS"
	@echo "=========================================="
	@echo "Removendo arquivos gerados..."
	@rm -f $(BINARY_NAME)
	@rm -f empresas_cnpj_*.csv
	@echo "✅ Limpeza concluída!"
	@echo

# Limpar tudo incluindo repositório
clean-all: clean
	@echo "=========================================="
	@echo "  LIMPEZA COMPLETA"
	@echo "=========================================="
	@echo "⚠️  Isso removerá TUDO, incluindo o código fonte!"
	@read -p "Tem certeza? (s/N): " -r
	@if [[ $$REPLY =~ ^[Ss]$$ ]]; then \
		echo "🗑️  Removendo tudo..."; \
		cd .. && rm -rf $(PROJECT_NAME); \
		echo "✅ Limpeza completa concluída"; \
	else \
		echo "❌ Operação cancelada"; \
	fi

# Mostrar informações do sistema
version:
	@echo "=========================================="
	@echo "  INFORMAÇÕES DO SISTEMA"
	@echo "=========================================="
	@echo "🐧 Shell: $$SHELL"
	@echo "🔧 Make: $$(make --version | head -1)"
	@echo "🐹 Go: $$(go version)"
	@echo "🔧 Git: $$(git --version)"
	@echo "📁 Diretório atual: $$(pwd)"
	@echo "💻 Sistema: $$(uname -a)"
	@echo "🏠 Home: $$HOME"
	@echo "👤 User Profile: $$USERPROFILE"
	@echo "🌐 Repositório: $(REPO_URL)"
	@echo

# Listar arquivos CSV gerados
list-csv:
	@echo "=========================================="
	@echo "  ARQUIVOS CSV GERADOS"
	@echo "=========================================="
	@if ls *.csv >/dev/null 2>&1; then \
		ls -la *.csv; \
	else \
		echo "📄 Nenhum arquivo CSV encontrado"; \
	fi
	@echo

# Mostrar conteúdo do CSV mais recente
show-latest:
	@echo "=========================================="
	@echo "  ÚLTIMO RESULTADO"
	@echo "=========================================="
	@latest=$$(ls -t *.csv 2>/dev/null | head -1); \
	if [[ -n "$$latest" ]]; then \
		echo "📁 Arquivo: $$latest"; \
		echo "📊 Tamanho: $$(wc -l < "$$latest") linhas"; \
		echo "📋 Cabeçalho:"; \
		head -1 "$$latest" | tr ',' '\n' | nl; \
		echo "📈 Dados:"; \
		tail -n +2 "$$latest" | head -3; \
	else \
		echo "❌ Nenhum arquivo CSV encontrado"; \
	fi

# Abrir pasta no Windows Explorer
explorer:
	@echo "🗂️ Abrindo pasta no Windows Explorer..."
	@explorer . || echo "❌ Erro ao abrir Explorer"

# Verificar configuração do PATH
check-path:
	@echo "=========================================="
	@echo "  VERIFICAÇÃO DE PATH"
	@echo "=========================================="
	@echo "PATH atual (parcial):"
	@echo "$$PATH" | tr ':' '\n' | grep -i "go\|bin" || echo "Nenhum caminho Go encontrado"
	@echo
	@if command -v consulta-cnpj.exe >/dev/null 2>&1; then \
		echo "✅ consulta-cnpj.exe encontrado no PATH"; \
		echo "📍 Local: $$(command -v consulta-cnpj.exe)"; \
	else \
		echo "❌ consulta-cnpj.exe não encontrado no PATH"; \
		echo "Adicione ao PATH: $(GOBIN_DIR)"; \
	fi
	@echo

# Atualizar e reinstalar
update: pull build install
	@echo "🎉 Projeto atualizado e reinstalado!"

# Instalação completa automatizada (do zero)
auto-install:
	@echo "=========================================="
	@echo "  INSTALAÇÃO AUTOMÁTICA COMPLETA"
	@echo "=========================================="
	@$(MAKE) setup
	@$(MAKE) build
	@$(MAKE) install
	@$(MAKE) test
	@echo "🎉 Instalação automática concluída!"
	@echo

# Status do repositório
status:
	@echo "=========================================="
	@echo "  STATUS DO REPOSITÓRIO"
	@echo "=========================================="
	@if [[ -d ".git" ]]; then \
		echo "📊 Status do Git:"; \
		git status --porcelain; \
		echo "🌿 Branch atual: $$(git branch --show-current)"; \
		echo "📝 Último commit: $$(git log -1 --oneline)"; \
	else \
		echo "❌ Não é um repositório Git"; \
	fi
	@echo

# Ajuda completa
help:
	@echo "=========================================="
	@echo "  CONSULTA CNPJ - AJUDA"
	@echo "=========================================="
	@echo
	@echo "🚀 COMANDOS DE CONFIGURAÇÃO:"
	@echo "  make setup         - Configurar projeto (clonar se necessário)"
	@echo "  make clone         - Clonar repositório"
	@echo "  make pull          - Atualizar repositório"
	@echo "  make update        - Atualizar e reinstalar"
	@echo
	@echo "🔧 COMANDOS DE INSTALAÇÃO:"
	@echo "  make install       - Instalar globalmente"
	@echo "  make auto-install  - Instalação automática completa"
	@echo "  make build         - Compilar apenas"
	@echo "  make init          - Inicializar módulo Go"
	@echo
	@echo "🔍 COMANDOS DE USO:"
	@echo "  make run CNPJ=xxx  - Executar com CNPJ informado"
	@echo "  make test          - Testar executável"
	@echo
	@echo "📊 COMANDOS DE INFORMAÇÃO:"
	@echo "  make version       - Informações do sistema"
	@echo "  make check         - Verificar dependências e estrutura"
	@echo "  make check-path    - Verificar configuração PATH"
	@echo "  make status        - Status do repositório Git"
	@echo "  make list-csv      - Listar arquivos CSV gerados"
	@echo "  make show-latest   - Mostrar último resultado"
	@echo
	@echo "🧹 COMANDOS DE LIMPEZA:"
	@echo "  make clean         - Limpar arquivos gerados"
	@echo "  make clean-all     - Limpeza completa (remove tudo)"
	@echo
	@echo "🗂️ COMANDOS ÚTEIS:"
	@echo "  make explorer      - Abrir pasta no Windows Explorer"
	@echo
	@echo "💡 FLUXO RECOMENDADO:"
	@echo "  1. make setup      - Primeira vez"
	@echo "  2. make install    - Instalar"
	@echo "  3. make run CNPJ=11.222.333/0001-81"
	@echo
	@echo "💡 EXEMPLOS DE USO:"
	@echo "  make setup && make run CNPJ=11222333000181"
	@echo "  make update  # Para atualizar código"
	@echo
	@echo "⚠️ LIMITAÇÕES:"
	@echo "  - API gratuita: máximo 3 consultas por minuto"
	@echo "  - Timeout: 30 segundos por consulta"
	@echo
	@echo "🌐 RECURSOS:"
	@echo "  - Repositório: $(REPO_URL)"
	@echo "  - API: https://receitaws.com.br/"
	@echo "  - Go: https://golang.org/"
	@echo "  - Git: https://git-scm.com/"
	@echo

# Target para desenvolvimento
dev: setup build
	@echo "Modo desenvolvedor ativado"
	@echo "Executável: ./$(BINARY_NAME)"
	@echo "Para instalar: make install"