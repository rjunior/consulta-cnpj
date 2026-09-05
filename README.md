# 📋 Manual de Instalação e Uso - Consulta CNPJ

## 🎯 Visão Geral
Script em Go para consultar informações de CNPJ através da API ReceitaWS, gerando relatórios em CSV no diretório atual de execução.

## 🚀 Pré-requisitos

### 1. Instalar Go
- **Baixe**: https://golang.org/dl/
- **Windows**: Baixar o instalador `.msi` e executar
- **Versão mínima**: Go 1.21

### 2. Instalar Git Bash
- **Baixe**: https://git-scm.com/download/win
- **Instale**: Git for Windows (inclui Git Bash)
- **Necessário**: Para compilação, clone e execução dos scripts
- **Recomendado**: Reiniciar o computador após instalação

### 3. Verificar Instalação
Abra o **Git Bash** e execute:
```bash
go version
git --version
```
Deve retornar as versões instaladas.

## 📦 Instalação do Script

### Opção 1: Instalação Automática com Clone (Recomendada)

1. **Abra Git Bash** em qualquer pasta
2. **Baixe e execute o instalador**:
```bash
# Baixar o instalador
curl -O https://raw.githubusercontent.com/rjunior/consulta-cnpj/main/install.sh

# Executar (fará clone automático do repositório)
./install.sh
```

**O que acontece durante a execução:**
- ✅ Verifica dependências (Go, Git Bash, Git)
- 📥 **CLONA automaticamente** o repositório do GitHub
- 🔧 Inicializa módulo Go (`go mod init`)
- 📦 Baixa dependências (`go mod tidy`)
- **🔨 COMPILA o código** (`go build -o consulta-cnpj.exe ./cmd`)
- 📂 Instala globalmente em `~/go/bin/`
- ⚙️ Orienta sobre configuração do PATH

### Opção 2: Via Makefile com Clone Automático

1. **Abra Git Bash** em qualquer pasta
2. **Baixe o Makefile**:
```bash
# Baixar Makefile
curl -O https://raw.githubusercontent.com/rjunior/consulta-cnpj/main/Makefile

# Configurar projeto completo (clone + build + install)
make auto-install
```

**Comandos disponíveis:**
```bash
# Configurar projeto (clone se necessário)
make setup

# Apenas compilar
make build

# Compilar + instalar globalmente
make install

# Processo completo automatizado
make auto-install
```

### Opção 3: Clone Manual + Compilação

1. **Clone o repositório**:
```bash
git clone https://github.com/rjunior/consulta-cnpj.git
cd consulta-cnpj
```

2. **Compile manualmente**:
```bash
# Inicializar módulo Go
go mod init github.com/rjunior/consulta-cnpj
go mod tidy

# Compilar o executável (da pasta cmd)
go build -o consulta-cnpj.exe ./cmd

# Usar localmente OU instalar globalmente
./consulta-cnpj.exe 11222333000181
# OU
mkdir -p ~/go/bin && cp consulta-cnpj.exe ~/go/bin/
```

### Opção 4: Baixar Arquivos Individualmente

Se não puder usar Git:

1. **Baixe os arquivos** do repositório:
   - https://github.com/rjunior/consulta-cnpj
2. **Organize a estrutura**:
```
consulta-cnpj/
├── cmd/main.go
├── api/client.go  
├── models/cnpj.go
├── utils/cnpj.go
└── install.bat
```

3. **Execute o instalador**:
```bash
./install.bat
```

## 📁 Estrutura do Projeto (Automática)

Após o clone automático:
```
consulta-cnpj/
├── cmd/
│   └── main.go         ⭐ Arquivo principal
├── api/
│   └── client.go       🌐 Cliente da API
├── models/
│   └── cnpj.go         📊 Estruturas de dados  
├── utils/
│   └── cnpj.go         🔍 Validações
├── go.mod              🔧 Dependências Go
├── install.bat         🚀 Instalador automático
├── Makefile           🛠️ Comandos de build
└── README.md          📖 Documentação
```

## ⚙️ Configuração do PATH

### Windows 10/11:
1. Tecle `Win + R`, digite `sysdm.cpl`
2. Aba "Avançado" → "Variáveis de Ambiente"
3. Em "Variáveis do usuário", encontre "Path"
4. Adicione: `%USERPROFILE%\go\bin`
5. Clique "OK" e reinicie o terminal

### Git Bash (temporário):
```bash
export PATH="$PATH:~/go/bin"
```

### Git Bash (permanente):
```bash
echo 'export PATH="$PATH:~/go/bin"' >> ~/.bashrc
source ~/.bashrc
```

## 🎮 Como Usar

### Sintaxe Básica:
```bash
consulta-cnpj [--formato coluna|linha] <CNPJ>
```

Por padrão, o CSV é gerado no formato `coluna`: um valor por linha, sem cabeçalho.

### Exemplos de Uso:

**Com pontuação:**
```bash
consulta-cnpj 11.222.333/0001-81
```

**Sem pontuação:**
```bash
consulta-cnpj 11222333000181
```

**Formato em coluna (padrão, sem cabeçalho):**
```bash
consulta-cnpj --formato coluna 11222333000181
```

**Formato em linha (com cabeçalho):**
```bash
consulta-cnpj --formato linha 11222333000181
```

**De qualquer diretório:**
```bash
# Exemplo: estando em C:\Users\Usuario\Documents\
consulta-cnpj 27.865.757/0001-02

# O arquivo CSV será gerado em C:\Users\Usuario\Documents\
```

## 📊 Resultado Gerado

### Arquivo CSV:
- **Nome**: `empresas_cnpj_AAAAMMDD_HHMMSS.csv`
- **Local**: Diretório atual de execução
- **Exemplo**: `empresas_cnpj_20241215_143052.csv`
- **Formato padrão**: `coluna`, com um valor por linha e sem cabeçalho
- **Formato alternativo**: `linha`, com cabeçalho e uma linha de valores

### Dados exportados no CSV:
- **Básicas**: CNPJ, Razão Social, Nome Fantasia, Data Abertura
- **Situação**: Situação Cadastral, Data Situação, Motivo
- **Atividades**: CNAE Principal, Descrição, Total de Atividades
- **Endereço**: Logradouro, Número, Bairro, CEP, Município, UF
- **Contato**: Telefone, Email
- **Outros**: Capital Social, Porte, Qtd Sócios, Natureza Jurídica

## 🔄 Atualizações

### Atualizar o código:
```bash
# Via Makefile (dentro da pasta do projeto)
make update

# Ou manualmente
git pull origin main
make install
```

### Reinstalar do zero:
```bash
# Remove tudo e reinstala
make clean-all
make auto-install
```

## 🚨 Limitações da API

- **Gratuita**: 3 consultas por minuto
- **Timeout**: 30 segundos por consulta
- **Fonte**: ReceitaWS (https://receitaws.com.br/)

## ❌ Solução de Problemas

### "consulta-cnpj não é reconhecido"
```bash
# Verificar se Go está instalado
go version

# Verificar se o executável existe
ls ~/go/bin/consulta-cnpj.exe

# Executar com caminho completo
~/go/bin/consulta-cnpj.exe 11222333000181
```

### Erro de clone do repositório:
```bash
# Verificar conectividade
ping github.com

# Verificar se Git está instalado
git --version

# Tentar clone manual
git clone https://github.com/rjunior/consulta-cnpj.git
```

### Erro de CNPJ inválido:
- Verificar se o CNPJ tem 14 dígitos
- Confirmar se os dígitos verificadores estão corretos
- Testar com e sem pontuação

### Erro de rede:
```bash
# Testar conectividade
ping receitaws.com.br

# Verificar proxy/firewall se necessário
```

### Arquivo não encontrado:
- O CSV é gerado no diretório atual (`%cd%`)
- Verificar permissões de escrita no diretório

### Erro: "repositório não encontrado"
- Verificar URL: https://github.com/rjunior/consulta-cnpj
- Tentar baixar arquivos manualmente
- Verificar conectividade com GitHub

## 📋 Comandos Úteis

### Makefile:
```bash
make help           # Ver todos os comandos
make status         # Status do repositório
make clean          # Limpar arquivos temporários
make test           # Testar funcionamento
make list-csv       # Listar CSVs gerados
```

### Git:
```bash
git status          # Status do repositório
git pull            # Atualizar código
git log --oneline   # Histórico de commits
```

### Sistema:
```bash
go version          # Versão do Go
git --version       # Versão do Git
echo $PATH          # Ver PATH atual
```

## 🎯 Fluxos de Instalação

### **Primeira instalação (usuário novo):**
```bash
# 1. Instalar Go e Git Bash
# 2. Baixar e executar instalador
curl -O https://raw.githubusercontent.com/rjunior/consulta-cnpj/main/install.bat
./install.bat

# 3. Configurar PATH e usar
consulta-cnpj 11222333000181
```

### **Instalação via Makefile:**
```bash
# 1. Baixar Makefile
curl -O https://raw.githubusercontent.com/rjunior/consulta-cnpj/main/Makefile

# 2. Configurar tudo
make auto-install

# 3. Usar
make run CNPJ=11222333000181
```

### **Instalação manual completa:**
```bash
# 1. Clonar repositório
git clone https://github.com/rjunior/consulta-cnpj.git
cd consulta-cnpj

# 2. Compilar e instalar
go mod tidy
go build -o consulta-cnpj.exe ./cmd
mkdir -p ~/go/bin && cp consulta-cnpj.exe ~/go/bin/

# 3. Configurar PATH e usar
export PATH="$PATH:~/go/bin"
consulta-cnpj 11222333000181
```

## 🎯 Resumo de Uso Rápido

1. **Instalar pré-requisitos**: Go + Git Bash
2. **Executar**: `curl -O [url]/install.bat && ./install.bat`
3. **Configurar PATH**: Seguir instruções na tela
4. **Usar**: `consulta-cnpj 11222333000181`
5. **CSV gerado** no diretório atual

---

## 🆘 Suporte

Para problemas ou dúvidas:
- Verificar se Go e Git estão instalados
- Confirmar conectividade com GitHub
- Testar com CNPJs válidos conhecidos
- Verificar configuração do PATH
- Consultar logs de erro na execução
- **Repositório**: https://github.com/rjunior/consulta-cnpj
- **Issues**: Para reportar problemas
