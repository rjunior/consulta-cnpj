package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/rjunior/consulta-cnpj/models"
)

type Client struct {
	baseURL    string
	httpClient *http.Client
}

func NewClient() *Client {
	return &Client{
		baseURL: "https://receitaws.com.br/v1",
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (c *Client) ConsultarCNPJ(cnpj string) (*models.CNPJResponse, error) {
	url := fmt.Sprintf("%s/cnpj/%s", c.baseURL, cnpj)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("erro ao criar requisição: %v", err)
	}
	req.Header.Set("User-Agent", "Go-CNPJ-Consulta/1.0")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erro ao fazer requisição: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("erro na API: status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("erro ao ler resposta: %v", err)
	}

	var cnpjData models.CNPJResponse
	if err := json.Unmarshal(body, &cnpjData); err != nil {
		return nil, fmt.Errorf("erro ao decodificar resposta: %v", err)
	}

	if cnpjData.Status == "ERROR" {
		return nil, fmt.Errorf("erro na consulta: %s", cnpjData.Message)
	}

	return &cnpjData, nil
}
