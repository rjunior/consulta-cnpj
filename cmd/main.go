package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/rjunior/consulta-cnpj/api"
	"github.com/rjunior/consulta-cnpj/models"
	"github.com/rjunior/consulta-cnpj/utils"
)

func main() {
	// Verificar se foram fornecidos argumentos
	if len(os.Args) < 2 {
		fmt.Println("Uso: consulta-cnpj <CNPJ>")
		fmt.Println("Exemplo: consulta-cnpj 11.222.333/0001-81")
		fmt.Println("")
		fmt.Println("API utilizada: ReceitaWS (https://receitaws.com.br/)")
		fmt.Println("Nota: A API gratuita tem limitações de taxa (3 consultas por minuto)")
		os.Exit(1)
	}

	// Pegar CNPJ do argumento da linha de comando
	cnpj := os.Args[1]

	fmt.Printf("Iniciando consulta do CNPJ %s via ReceitaWS...\n", cnpj)
	fmt.Println()

	// Validar CNPJ
	if !utils.ValidarCNPJ(cnpj) {
		fmt.Printf("❌ CNPJ inválido: %s\n", cnpj)
		return
	}

	// Criar cliente e fazer consulta
	client := api.NewClient()
	empresa, err := client.ConsultarCNPJ(utils.LimparCNPJ(cnpj))
	if err != nil {
		fmt.Printf("❌ Erro ao consultar CNPJ %s: %v\n", cnpj, err)
		return
	}

	fmt.Printf("✅ Sucesso: %s - %s\n", empresa.CNPJ, empresa.Nome)

	// Obter diretório atual de execução
	diretorioAtual, err := os.Getwd()
	if err != nil {
		fmt.Printf("❌ Erro ao obter diretório atual: %v\n", err)
		return
	}

	// Salvar resultados em CSV no diretório atual
	nomeArquivo := fmt.Sprintf("empresas_cnpj_%s.csv", time.Now().Format("20060102_150405"))
	caminhoCompleto := filepath.Join(diretorioAtual, nomeArquivo)

	if err := salvarCSV(empresa, caminhoCompleto); err != nil {
		fmt.Printf("❌ Erro ao salvar CSV: %v\n", err)
		return
	}

	fmt.Printf("\n🎉 Consulta concluída!")
	fmt.Printf("\n📁 Arquivo salvo em: %s\n", caminhoCompleto)
	fmt.Println("\nColunas disponíveis no CSV:")
	fmt.Println("- Dados básicos: CNPJ, Razão Social, Nome Fantasia, Data Abertura")
	fmt.Println("- Situação: Situação Cadastral, Data Situação, Motivo")
	fmt.Println("- Atividade: CNAE Principal, Descrição, Total de Atividades")
	fmt.Println("- Endereço: Logradouro, Número, Bairro, CEP, Município, UF")
	fmt.Println("- Contato: Telefone, Email")
	fmt.Println("- Outros: Capital Social, Porte, Quantidade de Sócios, Natureza Jurídica")
}

// Função para extrair CNAE principal das atividades
func extrairCNAEPrincipal(atividades []models.Atividade) (codigo, descricao string) {
	if len(atividades) > 0 {
		return atividades[0].Code, atividades[0].Text
	}
	return "", ""
}

// Função para contar sócios
func contarSocios(qsa []map[string]interface{}) int {
	return len(qsa)
}

// Função para salvar dados em CSV
func salvarCSV(empresa *models.CNPJResponse, caminhoArquivo string) error {
	arquivo, err := os.Create(caminhoArquivo)
	if err != nil {
		return fmt.Errorf("erro ao criar arquivo: %v", err)
	}
	defer arquivo.Close()

	writer := csv.NewWriter(arquivo)
	defer writer.Flush()

	// Escrever cabeçalho
	header := []string{
		"CNPJ", "Razão Social", "Nome Fantasia", "Data Abertura", "Situação Cadastral",
		"Data Situação", "Motivo Situação", "Situação Especial", "Data Situação Especial",
		"CNAE Principal", "Descrição CNAE Principal", "Total Atividades", "Natureza Jurídica",
		"Logradouro", "Número", "Complemento", "Bairro", "CEP", "Município", "UF",
		"Telefone", "Email", "Capital Social", "Porte", "Qtd Sócios", "EFR",
	}

	if err := writer.Write(header); err != nil {
		return fmt.Errorf("erro ao escrever cabeçalho: %v", err)
	}

	// Escrever dados
	cnaeCode, cnaeDesc := extrairCNAEPrincipal(empresa.Atividades)
	qtdSocios := contarSocios(empresa.QSA)

	registro := []string{
		empresa.CNPJ,
		empresa.Nome,
		empresa.Fantasia,
		empresa.Abertura,
		empresa.Situacao,
		empresa.DataSituacao,
		empresa.MotivoSituacao,
		empresa.SituacaoEspecial,
		empresa.DataSituacaoEspecial,
		cnaeCode,
		cnaeDesc,
		strconv.Itoa(len(empresa.Atividades)),
		empresa.NaturezaJuridica,
		empresa.Logradouro,
		empresa.Numero,
		empresa.Complemento,
		empresa.Bairro,
		empresa.CEP,
		empresa.Municipio,
		empresa.UF,
		empresa.Telefone,
		empresa.Email,
		empresa.CapitalSocial,
		empresa.Porte,
		strconv.Itoa(qtdSocios),
		empresa.EFR,
	}

	if err := writer.Write(registro); err != nil {
		return fmt.Errorf("erro ao escrever registro: %v", err)
	}

	return nil
}
