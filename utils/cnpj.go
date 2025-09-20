package utils

import (
	"regexp"
	"strconv"
	"strings"
)

// LimparCNPJ remove pontuação do CNPJ
func LimparCNPJ(cnpj string) string {
	return regexp.MustCompile(`[^0-9]`).ReplaceAllString(cnpj, "")
}

// ValidarCNPJ verifica se o CNPJ é válido
func ValidarCNPJ(cnpj string) bool {
	// Limpar CNPJ
	cnpjLimpo := LimparCNPJ(cnpj)

	// Verificar se tem 14 dígitos
	if len(cnpjLimpo) != 14 {
		return false
	}

	// Verificar se não é uma sequência de números iguais
	if strings.Repeat(string(cnpjLimpo[0]), 14) == cnpjLimpo {
		return false
	}

	// Calcular primeiro dígito verificador
	soma := 0
	peso := 5
	for i := 0; i < 12; i++ {
		digito, _ := strconv.Atoi(string(cnpjLimpo[i]))
		soma += digito * peso
		peso--
		if peso < 2 {
			peso = 9
		}
	}

	resto := soma % 11
	var dv1 int
	if resto < 2 {
		dv1 = 0
	} else {
		dv1 = 11 - resto
	}

	// Verificar primeiro dígito
	if dv1 != int(cnpjLimpo[12]-'0') {
		return false
	}

	// Calcular segundo dígito verificador
	soma = 0
	peso = 6
	for i := 0; i < 13; i++ {
		digito, _ := strconv.Atoi(string(cnpjLimpo[i]))
		soma += digito * peso
		peso--
		if peso < 2 {
			peso = 9
		}
	}

	resto = soma % 11
	var dv2 int
	if resto < 2 {
		dv2 = 0
	} else {
		dv2 = 11 - resto
	}

	// Verificar segundo dígito
	return dv2 == int(cnpjLimpo[13]-'0')
}
