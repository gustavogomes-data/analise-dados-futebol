# Análise de Desempenho e Evolução de Jogadores — Top 5 Ligas Europeias

Projeto de análise de dados aplicado ao futebol europeu, com pipeline completo de coleta, tratamento, modelagem em banco relacional e visualização em Power BI.

O foco é medir desempenho e identificar tendências de evolução ou declínio de jogadores ao longo de múltiplas temporadas, com atenção a problemas comuns em análises esportivas, como amostras pequenas, ruído estatístico e interpretação equivocada de variações naturais como tendências reais.

## 1. Descrição

O projeto coleta dados de jogadores das cinco principais ligas nacionais da Europa ao longo das últimas cinco temporadas (2021/22 a 2025/26), trata e organiza essas informações em um banco SQL Server e constrói um dashboard em Power BI dividido em duas páginas: uma voltada para a evolução individual de jogadores ao longo do tempo e outra para ranking comparativo de desempenho por temporada.

A motivação não foi apenas exibir estatísticas de futebol, mas praticar um fluxo de análise de dados completo — desde a coleta bruta até decisões metodológicas explícitas sobre como medir "evolução" de forma que a análise seja menos sensível a ruído estatístico e amostras pequenas.

## 2. Objetivo

* Praticar um pipeline de dados ponta a ponta: coleta → tratamento → banco relacional → BI.
* Aplicar critérios para medir tendência de desempenho ao longo do tempo, evitando conclusões precipitadas a partir de poucas observações.
* Construir um dashboard que comunique não apenas números, mas também o contexto e as limitações por trás deles.

## 3. Perguntas de negócio / análise

* Quais jogadores apresentam maior tendência de evolução ou declínio em G+A/90 ao longo das últimas temporadas?
* Essa tendência é consistente ao longo do período analisado?
* Quem lidera os rankings de gols, assistências e G+A em cada temporada dentro das cinco principais ligas?
* Como esses rankings mudam ao segmentar por liga, temporada e métrica?

## 4. Fonte e escopo dos dados

* **Fonte:** [FBref](https://fbref.com), coletado via Python com a biblioteca [`soccerdata`](https://github.com/probberechts/soccerdata).
* **Ligas:** Premier League, La Liga, Bundesliga, Serie A e Ligue 1.
* **Temporadas:** 2021/22 a 2025/26.
* **Escopo:** apenas jogos das competições nacionais de cada liga.
* Jogos de Champions League, Europa League e outras competições europeias não são considerados.

O foco é comparar o desempenho dos jogadores dentro do contexto de suas respectivas ligas nacionais.

## 5. Critérios e regras da análise

Os critérios foram definidos ao longo do desenvolvimento do projeto para reduzir o impacto de amostras pequenas e variações isoladas nos resultados.

| Critério                                     | Valor                                                               | Motivo                                                                                            |
| -------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Minutos mínimos por temporada                | 900 minutos                                                         | Reduz o impacto de amostras pequenas nas métricas por 90 minutos.                                 |
| Temporadas mínimas para cálculo de tendência | 4 temporadas                                                        | Garante uma quantidade maior de observações para estimar a direção da evolução ao longo do tempo. |
| Classificação de tendência                   | Positiva: > +0,05 · Negativa: < −0,05 · Neutra: entre −0,05 e +0,05 | Evita classificar pequenas variações próximas de zero como tendência positiva ou negativa.        |
| Escopo de competições                        | Apenas jogos da liga nacional                                       | Mantém o contexto competitivo da análise consistente.                                             |

## 6. Tecnologias utilizadas

| Camada                        | Ferramenta           |
| ----------------------------- | -------------------- |
| Coleta de dados               | Python, `soccerdata` |
| Tratamento e limpeza          | Python, Pandas       |
| Armazenamento                 | SQL Server           |
| Modelagem e regras de negócio | SQL (views)          |
| Visualização                  | Power BI             |
| Versionamento                 | Git / GitHub         |

## 7. Pipeline do projeto

```text
FBref
  ↓
Coleta de dados
Python + soccerdata
  ↓
Dados brutos
CSV
  ↓
Limpeza e tratamento
Pandas
  ↓
Dados tratados
CSV limpo
  ↓
SQL Server
  ↓
Views SQL
Regras e métricas de negócio
  ↓
Power BI
Modelo de dados + visualizações
  ↓
Dashboard
Evolução dos Jogadores + Ranking de Jogadores
```

O fluxo foi organizado por camadas, separando coleta, tratamento, armazenamento, regras de negócio e visualização.

Essa separação facilita a manutenção do projeto e reduz a duplicação de lógica entre SQL e Power BI.

## 8. Tratamento e preparação dos dados

As principais etapas realizadas com Pandas incluem:

* Padronização de nomes de jogadores e times entre temporadas.
* Tratamento de jogadores que atuaram por mais de um clube na mesma temporada.
* Conversão e padronização dos tipos de dados.
* Organização de partidas, minutos, gols e assistências como valores numéricos.
* Geração da métrica derivada G+A/90 a partir dos totais de gols, assistências e minutos jogados.
* Aplicação dos critérios necessários para as análises.
* Exportação dos dados tratados para CSV.
* Preparação da base para carga no SQL Server.

## 9. Banco de dados / SQL

Os dados tratados são carregados em uma tabela base `DadosFUTLimpos` no SQL Server, com granularidade de jogador por temporada.

A partir dessa base, foram criadas views para concentrar regras de negócio e cálculos utilizados pelo dashboard.

Principais views:

* **`vw_RankingTendenciaJogadores`** — calcula a tendência de G+A/90 de cada jogador por meio de regressão linear, considerando o critério mínimo de temporadas.
* **`vw_KPI3_MaiorEvolucao`** — retorna o jogador com maior tendência positiva dentro da amostra elegível.
* **`vw_KPI2_MaiorDeclinio`** — retorna o jogador com maior tendência negativa dentro da amostra elegível.
* **`vw_DadosJogadorTemporada`** — fornece os dados utilizados pelos indicadores e análises individuais no Power BI.

A decisão de concentrar o cálculo da regressão linear no SQL foi adotada para evitar a duplicação da mesma lógica em diferentes camadas do projeto.

## 10. Dashboard no Power BI

O dashboard é dividido em duas páginas com objetivos diferentes.

### Página 1 — Evolução dos Jogadores

![Página 1](docs/images/pagina1.png)

A primeira página é dedicada à análise da trajetória individual dos jogadores ao longo das temporadas.

Principais elementos:

* Busca de jogador.
* Gráfico de G+A/90 por temporada.
* Resumo estatístico do jogador.
* Partidas, minutos, gols, assistências e G+A.
* Média de G+A/90 ponderada por minutos.
* Ranking de maior evolução.
* Ranking de maior declínio.
* Distribuição de tendência entre positiva, neutra e negativa.

Os rankings de evolução e declínio consideram apenas jogadores com quantidade mínima de temporadas elegíveis, reduzindo o impacto de variações isoladas.

### Página 2 — Ranking de Jogadores

![Página 2](docs/images/pagina2.png)

A segunda página é voltada para a comparação de desempenho dos jogadores dentro de um recorte específico.

Principais elementos:

* Segmentação por temporada.
* Segmentação por métrica.
* Segmentação por liga.
* Ranking Top 10 dinâmico.
* Métricas de gols, assistências e G+A.
* Filtro mínimo de 900 minutos por temporada.

Os rankings consideram apenas partidas das ligas nacionais analisadas.

## 11. Principais métricas e lógica das análises

### G+A/90

**G+A/90** representa a quantidade de gols e assistências produzidos pelo jogador a cada 90 minutos.

A métrica permite comparar jogadores com diferentes volumes de minutos jogados, reduzindo a influência direta do tempo total em campo.

Como se trata de uma taxa, ela pode ser mais sensível a amostras pequenas. Por isso, o projeto utiliza um mínimo de **900 minutos por temporada** antes das análises.

### Tendência

A tendência é calculada utilizando uma regressão linear sobre o G+A/90 de cada jogador ao longo das temporadas elegíveis.

O coeficiente angular (**slope**) representa a direção da variação ao longo do tempo:

* **Slope positivo:** tendência de aumento.
* **Slope negativo:** tendência de redução.
* **Slope próximo de zero:** pouca variação sistemática.

Para reduzir a influência de variações isoladas, o projeto exige um mínimo de **4 temporadas elegíveis** para o cálculo da tendência.

Além disso, foi definida uma faixa neutra entre **-0,05 e +0,05**, evitando classificar pequenas variações como tendências positivas ou negativas.

Os resultados devem ser interpretados dentro da amostra analisada e não como uma avaliação absoluta da carreira de um jogador.

## 12. Estrutura de pastas do repositório

```text
projeto-futebol/
├── dados/
│   ├── Bruto/
│   └── Limpo/
├── scripts/
├── notebooks/
├── sql/
├── powerbi/
├── docs/
│   └── images/
├── .gitignore
└── README.md
```

## 13. Como executar / reproduzir o projeto

1. Clone o repositório.
2. Instale as dependências Python utilizadas no projeto.
3. Execute os scripts de coleta para obter os dados do FBref.
4. Execute o processo de tratamento dos dados.
5. Gere o CSV tratado.
6. Carregue os dados no SQL Server.
7. Execute os scripts SQL para criação das views.
8. Abra o arquivo `.pbix` no Power BI.
9. Configure a conexão com o banco SQL Server.
10. Atualize os dados no Power BI.

## 14. Limitações do projeto

* A classificação de tendência utiliza uma faixa fixa de ±0,05 como critério de neutralidade e não um teste formal de significância estatística.
* A regressão linear não diferencia automaticamente uma evolução gradual de uma mudança de patamar causada por uma mudança de clube ou contexto.
* G+A/90 não separa gols de pênalti dos demais gols.
* A análise não realiza ajuste específico por posição ou função tática.
* Os rankings de totais da Página 2 podem ser influenciados por diferenças no número de partidas disponíveis em cada liga e temporada.
* O filtro de 900 minutos e o requisito de temporadas para tendência reduzem a presença de jogadores com pouca participação ou início recente nas principais ligas.

## 15. Possíveis melhorias futuras

* Substituir a faixa fixa de tendência por intervalos de confiança do coeficiente angular.
* Segmentar as análises por posição.
* Adicionar análise por faixa etária.
* Identificar mudanças de clube no gráfico de evolução.
* Adicionar métricas como gols sem pênalti e xG quando disponíveis.
* Normalizar rankings de totais considerando o número de jogos disputados.
* Adicionar novas métricas de desempenho ofensivo e defensivo.
* Comparar diferentes métodos estatísticos de identificação de tendência.

## 16. Conclusão

O projeto foi desenvolvido para aplicar um fluxo completo de análise de dados, desde a coleta e tratamento das informações até a modelagem em SQL Server e visualização no Power BI.

Além da construção do dashboard, o projeto busca demonstrar a importância de definir critérios metodológicos antes de interpretar os resultados.

O uso de um mínimo de minutos por temporada, um número mínimo de temporadas para análise de tendência e uma faixa neutra para pequenas variações ajuda a reduzir interpretações baseadas apenas em oscilações isoladas.

Dessa forma, o projeto combina **Python, SQL e Power BI** em um único fluxo de análise aplicado a dados reais de futebol.

## 17. Autor

Desenvolvido por **Gustavo Gomes** como projeto de portfólio em **Análise de Dados / Business Intelligence**.
