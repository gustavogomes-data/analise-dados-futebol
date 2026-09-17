# ⚽ Projeto de Análise de Dados de Futebol

## Sobre o projeto

Projeto de análise de dados de jogadores de futebol das 5 principais ligas europeias, ao longo das últimas 5 temporadas, construído com um pipeline de coleta, tratamento e análise de dados — da extração via web scraping até um dashboard interativo no Power BI.

Desenvolvido como parte do meu portfólio como estudante de Ciência da Computação, com foco em Análise de Dados, SQL e Business Intelligence.

## Objetivos

Análise da performance ofensiva de jogadores de meio-campo e ataque nas 5 principais ligas europeias, considerando as temporadas 2021/22 a 2025/26:

* Premier League — Inglaterra
* La Liga — Espanha
* Bundesliga — Alemanha
* Serie A — Itália
* Ligue 1 — França

## Dados utilizados

* **Fonte:** [FBref](https://fbref.com)
* **Coleta:** biblioteca [`soccerdata`](https://github.com/probberechts/soccerdata), em Python
* **Ligas:** Premier League, La Liga, Bundesliga, Serie A, Ligue 1
* **Temporadas:** 2021/22, 2022/23, 2023/24, 2024/25, 2025/26
* **Volume inicial:** 25 arquivos CSV (5 ligas × 5 temporadas)

## Pipeline do projeto

FBref
↓
Python + soccerdata
↓
25 arquivos CSV
↓
Verificação e consolidação
↓
CSV consolidado
↓
Limpeza e tratamento
↓
CSV tratado
↓
SQL Server
↓
Consultas SQL
↓
Dashboard Power BI

## Etapas realizadas

### 1. Coleta dos dados

Script Python (`script.py`) responsável pela coleta automatizada dos dados do FBref, utilizando a biblioteca `soccerdata`.

A coleta foi feita para as 5 ligas e 5 temporadas definidas, gerando **25 arquivos CSV**, um para cada combinação de liga e temporada.

### 2. Verificação e consolidação dos dados

Em um notebook Jupyter, os 25 arquivos CSV coletados foram carregados e verificados quanto à estrutura, confirmando que todos seguiam o mesmo padrão.

Em seguida, os arquivos foram consolidados em um único CSV bruto.

### 3. Limpeza e tratamento

Após a consolidação, foi aplicada a limpeza e padronização dos dados no mesmo notebook.

O resultado foi exportado para um **CSV único e tratado**, que passou a ser a base principal para as próximas etapas do projeto.

### 4. Importação para SQL Server

O CSV consolidado foi importado para o **SQL Server**, que será utilizado para realizar as consultas e análises necessárias para o projeto.

### 5. Definição dos KPIs

Antes do desenvolvimento das consultas SQL, foi realizado o planejamento do dashboard em um caderno físico.

Nessa etapa foram definidos os principais KPIs e métricas que serão utilizados no dashboard, além de um esboço inicial do layout da página.

## Estrutura do projeto

```text
projeto-futebol/
│
├── script.py
├── notebooks/
│   └── limpeza_dados.ipynb
│
├── dados/
│   └── arquivos CSV
│
├── sql/
│
└── README.md
```

## SQL

**Seção em construção.**

A próxima etapa do projeto será o desenvolvimento das consultas SQL responsáveis pelas análises e pelos KPIs planejados.

## Tecnologias

| Tecnologia       | Função no projeto                                              |
| ---------------- | -------------------------------------------------------------- |
| Python           | Linguagem utilizada para coleta e tratamento dos dados         |
| pandas           | Manipulação, limpeza e consolidação dos dados                  |
| soccerdata       | Biblioteca utilizada para coletar dados do FBref               |
| Jupyter Notebook | Ambiente utilizado para verificação e exploração dos dados     |
| CSV              | Formato utilizado para armazenar os dados coletados e tratados |
| SQL Server       | Armazenamento e análise dos dados                              |
| Git/GitHub       | Versionamento e documentação do projeto                        |
| Power BI         | Ferramenta planejada para construção do dashboard              |

## Próximas etapas

* Desenvolver as consultas SQL;
* Implementar os KPIs planejados;
* Realizar as análises dos dados;
* Construir o dashboard no Power BI;
* Validar os resultados;
* Documentar as principais conclusões do projeto.

## Status do projeto

🚧 **Em desenvolvimento**

Atualmente, o projeto está na etapa de desenvolvimento das análises em SQL, após a coleta, limpeza, consolidação e importação dos dados para o SQL Server.

## Autor

**Gustavo Gomes**

Estudante de Ciência da Computação
