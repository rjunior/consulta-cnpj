package main

import (
	"bytes"
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/rjunior/consulta-cnpj/api"
	"github.com/rjunior/consulta-cnpj/models"
	"github.com/rjunior/consulta-cnpj/utils"
)

type formatoCSV string

const (
	formatoColuna formatoCSV = "coluna"
	formatoLinha  formatoCSV = "linha"
)

var (
	errFormatoInvalido = errors.New("formato invalido")
	errUsoInvalido     = errors.New("informe exatamente um CNPJ")
)

type cliArgs struct {
	cnpj    string
	formato formatoCSV
}

func main() {
	args, err := parseArgs(os.Args[1:])
	if err != nil {
		fmt.Printf("Erro: %v\n\n", err)
		imprimirUso(os.Stdout)
		os.Exit(1)
	}

	// Pegar CNPJ do argumento da linha de comando
	cnpj := args.cnpj

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

	if err := salvarCSV(empresa, caminhoCompleto, args.formato); err != nil {
		fmt.Printf("❌ Erro ao salvar CSV: %v\n", err)
		return
	}

	fmt.Printf("\n🎉 Consulta concluída!")
	fmt.Printf("\n📁 Arquivo salvo em: %s\n", caminhoCompleto)
	fmt.Printf("\nFormato do CSV: %s\n", args.formato)
	fmt.Println("\nDados disponíveis no CSV:")
	fmt.Println("- Dados básicos: CNPJ, Razão Social, Nome Fantasia, Data Abertura")
	fmt.Println("- Situação: Situação Cadastral, Data Situação, Motivo")
	fmt.Println("- Atividade: CNAE Principal, Descrição, Total de Atividades")
	fmt.Println("- Endereço: Logradouro, Número, Bairro, CEP, Município, UF")
	fmt.Println("- Contato: Telefone, Email")
	fmt.Println("- Outros: Capital Social, Porte, Quantidade de Sócios, Natureza Jurídica")
}

func parseArgs(args []string) (cliArgs, error) {
	fs := flag.NewFlagSet("consulta-cnpj", flag.ContinueOnError)
	fs.SetOutput(io.Discard)

	formato := fs.String("formato", string(formatoColuna), "formato do CSV: coluna ou linha")
	if err := fs.Parse(args); err != nil {
		return cliArgs{}, err
	}

	if fs.NArg() != 1 {
		return cliArgs{}, errUsoInvalido
	}

	formatoSelecionado := formatoCSV(*formato)
	switch formatoSelecionado {
	case formatoColuna, formatoLinha:
		return cliArgs{cnpj: fs.Arg(0), formato: formatoSelecionado}, nil
	default:
		return cliArgs{}, fmt.Errorf("%w: %s", errFormatoInvalido, *formato)
	}
}

func imprimirUso(w io.Writer) {
	fmt.Fprintln(w, "Uso: consulta-cnpj [--formato coluna|linha] <CNPJ>")
	fmt.Fprintln(w, "Exemplo: consulta-cnpj --formato coluna 11.222.333/0001-81")
	fmt.Fprintln(w, "Exemplo: consulta-cnpj --formato linha 11.222.333/0001-81")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "API utilizada: ReceitaWS (https://receitaws.com.br/)")
	fmt.Fprintln(w, "Nota: A API gratuita tem limitações de taxa (3 consultas por minuto)")
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
func salvarCSV(empresa *models.CNPJResponse, caminhoArquivo string, formato formatoCSV) error {
	arquivo, err := os.Create(caminhoArquivo)
	if err != nil {
		return fmt.Errorf("erro ao criar arquivo: %v", err)
	}
	defer arquivo.Close()

	valores := valoresCSV(empresa)

	switch formato {
	case formatoLinha:
		writer := csv.NewWriter(arquivo)

		if err := writer.Write(cabecalhoCSV()); err != nil {
			return fmt.Errorf("erro ao escrever cabeçalho: %v", err)
		}

		if err := writer.Write(valores); err != nil {
			return fmt.Errorf("erro ao escrever registro: %v", err)
		}

		writer.Flush()
		if err := writer.Error(); err != nil {
			return fmt.Errorf("erro ao finalizar CSV: %v", err)
		}
	case formatoColuna:
		for _, valor := range valores {
			if err := escreverLinhaCSVColuna(arquivo, valor); err != nil {
				return fmt.Errorf("erro ao escrever registro: %v", err)
			}
		}
	default:
		return fmt.Errorf("%w: %s", errFormatoInvalido, formato)
	}

	return nil
}

func escreverLinhaCSVColuna(w io.Writer, valor string) error {
	if valor == "" {
		_, err := io.WriteString(w, "\"\"\n")
		return err
	}

	var linha bytes.Buffer
	writer := csv.NewWriter(&linha)
	if err := writer.Write([]string{valor}); err != nil {
		return err
	}

	writer.Flush()
	if err := writer.Error(); err != nil {
		return err
	}

	_, err := w.Write(linha.Bytes())
	return err
}

func cabecalhoCSV() []string {
	return []string{
		"CNPJ", "Razão Social", "Nome Fantasia", "Data Abertura", "Situação Cadastral",
		"Data Situação", "Motivo Situação", "Situação Especial", "Data Situação Especial",
		"CNAE Principal", "Descrição CNAE Principal", "Total Atividades", "Natureza Jurídica",
		"Logradouro", "Número", "Complemento", "Bairro", "CEP", "Município", "UF",
		"Telefone", "Email", "Capital Social", "Porte", "Qtd Sócios", "EFR",
	}
}

func valoresCSV(empresa *models.CNPJResponse) []string {
	cnaeCode, cnaeDesc := extrairCNAEPrincipal(empresa.Atividades)
	qtdSocios := contarSocios(empresa.QSA)

	return []string{
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
}
