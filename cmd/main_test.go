package main

import (
	"encoding/csv"
	"errors"
	"os"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/rjunior/consulta-cnpj/models"
)

func TestParseArgsUsaFormatoColunaComoPadrao(t *testing.T) {
	args, err := parseArgs([]string{"11.222.333/0001-81"})
	if err != nil {
		t.Fatalf("parseArgs retornou erro: %v", err)
	}

	if args.cnpj != "11.222.333/0001-81" {
		t.Fatalf("cnpj = %q, esperado %q", args.cnpj, "11.222.333/0001-81")
	}

	if args.formato != formatoColuna {
		t.Fatalf("formato = %q, esperado %q", args.formato, formatoColuna)
	}
}

func TestParseArgsAceitaFormatosValidos(t *testing.T) {
	casos := []formatoCSV{formatoColuna, formatoLinha}

	for _, formato := range casos {
		t.Run(string(formato), func(t *testing.T) {
			args, err := parseArgs([]string{"--formato", string(formato), "11222333000181"})
			if err != nil {
				t.Fatalf("parseArgs retornou erro: %v", err)
			}

			if args.formato != formato {
				t.Fatalf("formato = %q, esperado %q", args.formato, formato)
			}
		})
	}
}

func TestParseArgsRejeitaFormatoInvalido(t *testing.T) {
	_, err := parseArgs([]string{"--formato", "vertical", "11222333000181"})
	if !errors.Is(err, errFormatoInvalido) {
		t.Fatalf("erro = %v, esperado errFormatoInvalido", err)
	}
}

func TestSalvarCSVEmColunaEscreveValoresSemCabecalho(t *testing.T) {
	caminho := filepath.Join(t.TempDir(), "empresa.csv")

	if err := salvarCSV(empresaTeste(), caminho, formatoColuna); err != nil {
		t.Fatalf("salvarCSV retornou erro: %v", err)
	}

	registros := lerCSV(t, caminho)
	valoresEsperados := valoresEmpresaTeste()

	if len(registros) != len(valoresEsperados) {
		t.Fatalf("total de registros = %d, esperado %d", len(registros), len(valoresEsperados))
	}

	for i, registro := range registros {
		if len(registro) != 1 {
			t.Fatalf("registro %d tem %d colunas, esperado 1: %#v", i, len(registro), registro)
		}

		if registro[0] != valoresEsperados[i] {
			t.Fatalf("registro %d = %q, esperado %q", i, registro[0], valoresEsperados[i])
		}
	}
}

func TestSalvarCSVEmLinhaMantemCabecalhoEValores(t *testing.T) {
	caminho := filepath.Join(t.TempDir(), "empresa.csv")

	if err := salvarCSV(empresaTeste(), caminho, formatoLinha); err != nil {
		t.Fatalf("salvarCSV retornou erro: %v", err)
	}

	registros := lerCSV(t, caminho)
	esperado := [][]string{cabecalhoEmpresaTeste(), valoresEmpresaTeste()}

	if !reflect.DeepEqual(registros, esperado) {
		t.Fatalf("registros = %#v, esperado %#v", registros, esperado)
	}
}

func lerCSV(t *testing.T, caminho string) [][]string {
	t.Helper()

	arquivo, err := os.Open(caminho)
	if err != nil {
		t.Fatalf("erro ao abrir CSV: %v", err)
	}
	defer arquivo.Close()

	registros, err := csv.NewReader(arquivo).ReadAll()
	if err != nil {
		t.Fatalf("erro ao ler CSV: %v", err)
	}

	return registros
}

func empresaTeste() *models.CNPJResponse {
	return &models.CNPJResponse{
		CNPJ:                 "11.222.333/0001-81",
		Nome:                 "Empresa Teste LTDA",
		Fantasia:             "Empresa Teste",
		Abertura:             "01/01/2020",
		Situacao:             "ATIVA",
		DataSituacao:         "02/01/2020",
		MotivoSituacao:       "SEM MOTIVO",
		SituacaoEspecial:     "NENHUMA",
		DataSituacaoEspecial: "",
		Atividades: []models.Atividade{
			{Code: "6201-5/01", Text: "Desenvolvimento de programas de computador sob encomenda"},
			{Code: "6202-3/00", Text: "Desenvolvimento e licenciamento de programas customizaveis"},
		},
		NaturezaJuridica: "206-2 - Sociedade Empresaria Limitada",
		Logradouro:       "Rua Teste",
		Numero:           "123",
		Complemento:      "Sala 1",
		Bairro:           "Centro",
		CEP:              "01000-000",
		Municipio:        "Sao Paulo",
		UF:               "SP",
		Telefone:         "(11) 1111-1111",
		Email:            "contato@teste.com.br",
		CapitalSocial:    "10000.00",
		Porte:            "ME",
		QSA: []map[string]interface{}{
			{"nome": "Socio Um"},
			{"nome": "Socio Dois"},
		},
		EFR: "",
	}
}

func cabecalhoEmpresaTeste() []string {
	return []string{
		"CNPJ", "Razão Social", "Nome Fantasia", "Data Abertura", "Situação Cadastral",
		"Data Situação", "Motivo Situação", "Situação Especial", "Data Situação Especial",
		"CNAE Principal", "Descrição CNAE Principal", "Total Atividades", "Natureza Jurídica",
		"Logradouro", "Número", "Complemento", "Bairro", "CEP", "Município", "UF",
		"Telefone", "Email", "Capital Social", "Porte", "Qtd Sócios", "EFR",
	}
}

func valoresEmpresaTeste() []string {
	return []string{
		"11.222.333/0001-81",
		"Empresa Teste LTDA",
		"Empresa Teste",
		"01/01/2020",
		"ATIVA",
		"02/01/2020",
		"SEM MOTIVO",
		"NENHUMA",
		"",
		"6201-5/01",
		"Desenvolvimento de programas de computador sob encomenda",
		"2",
		"206-2 - Sociedade Empresaria Limitada",
		"Rua Teste",
		"123",
		"Sala 1",
		"Centro",
		"01000-000",
		"Sao Paulo",
		"SP",
		"(11) 1111-1111",
		"contato@teste.com.br",
		"10000.00",
		"ME",
		"2",
		"",
	}
}
