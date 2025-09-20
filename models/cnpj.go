package models

// Atividade representa um CNAE da empresa
type Atividade struct {
	Text string `json:"text"`
	Code string `json:"code"`
}

// CNPJResponse representa a resposta da API ReceitaWS
type CNPJResponse struct {
	Status               string                   `json:"status"`
	Message              string                   `json:"message,omitempty"`
	CNPJ                 string                   `json:"cnpj"`
	Nome                 string                   `json:"nome"`
	Fantasia             string                   `json:"fantasia"`
	Abertura             string                   `json:"abertura"`
	Situacao             string                   `json:"situacao"`
	DataSituacao         string                   `json:"data_situacao"`
	Logradouro           string                   `json:"logradouro"`
	Numero               string                   `json:"numero"`
	Complemento          string                   `json:"complemento"`
	CEP                  string                   `json:"cep"`
	Bairro               string                   `json:"bairro"`
	Municipio            string                   `json:"municipio"`
	UF                   string                   `json:"uf"`
	Email                string                   `json:"email"`
	Telefone             string                   `json:"telefone"`
	EFR                  string                   `json:"efr"`
	MotivoSituacao       string                   `json:"motivo_situacao"`
	SituacaoEspecial     string                   `json:"situacao_especial"`
	DataSituacaoEspecial string                   `json:"data_situacao_especial"`
	CapitalSocial        string                   `json:"capital_social"`
	Porte                string                   `json:"porte"`
	NaturezaJuridica     string                   `json:"natureza_juridica"`
	Atividades           []Atividade              `json:"atividades"`
	QSA                  []map[string]interface{} `json:"qsa"`
	Extra                map[string]interface{}   `json:"extra,omitempty"`
	Billing              map[string]interface{}   `json:"billing,omitempty"`
}
