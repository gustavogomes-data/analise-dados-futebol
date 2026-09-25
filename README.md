Análise de Desempenho e Evolução de Jogadores — Top 5 Ligas Europeias

Projeto de análise de dados aplicado ao futebol europeu, com pipeline completo de coleta, tratamento, modelagem em banco relacional e visualização em Power BI. O foco é medir desempenho e identificar tendências de evolução (ou declínio) de jogadores ao longo de múltiplas temporadas, com atenção explícita a problemas comuns em análises esportivas: amostras pequenas, ruído estatístico e interpretação equivocada de variação natural como tendência real.

1. Descrição

O projeto coleta dados de jogadores das cinco principais ligas nacionais da Europa ao longo das últimas cinco temporadas (2021/22 a 2025/26), trata e organiza essas informações em um banco SQL Server, e constrói um dashboard em Power BI dividido em duas páginas: uma voltada para a evolução individual de jogadores ao longo do tempo, e outra para ranking comparativo de desempenho por temporada.

A motivação não foi apenas exibir estatísticas de futebol, mas praticar um fluxo de análise de dados completo — desde a coleta bruta até decisões metodológicas explícitas sobre como medir "evolução" de forma que resista a ruído estatístico e amostras pequenas.

2. Objetivo
Praticar um pipeline de dados ponta a ponta (coleta → tratamento → banco relacional → BI).
Aplicar critérios estatísticos defensáveis para medir tendência de desempenho ao longo do tempo, evitando conclusões precipitadas a partir de poucas observações.
Construir um dashboard que comunique não só números, mas o contexto e as limitações por trás deles.
3. Perguntas de negócio / análise
Quais jogadores apresentam a maior tendência de evolução (ou declínio) em G+A/90 ao longo das últimas temporadas?
Essa tendência é estatisticamente defensável, ou pode ser explicada por variação natural entre temporadas?
Quem lidera os rankings de gols, assistências e G+A em cada temporada, dentro das cinco principais ligas?
Como esses rankings mudam ao segmentar por liga, temporada e métrica?
4. Fonte e escopo dos dados
Fonte: FBref, coletado via Python com a biblioteca soccerdata.
Ligas: Premier League, La Liga, Bundesliga, Serie A e Ligue 1.
Temporadas: 2021/22 a 2025/26 (últimas 5 temporadas disponíveis no momento da coleta).
Escopo: apenas jogos das competições nacionais de cada liga. Jogos de Champions League, Europa League e outras competições europeias não são considerados — o foco é comparação de desempenho dentro do contexto de cada liga doméstica, que têm calendários e níveis de competitividade diferentes entre si.
5. Critérios e regras da análise

Esses critérios foram definidos (e em alguns casos revisados) ao longo do desenvolvimento do projeto, para evitar que amostras pequenas ou ruído estatístico distorçam os resultados:

Critério	Valor	Motivo
Minutos mínimos por temporada	900 minutos	Evita que jogadores com poucos minutos jogados tenham taxas por 90 (G+A/90) distorcidas por amostra pequena. Aplicado na base de dados, antes de qualquer cálculo de ranking ou tendência.
Temporadas mínimas para cálculo de tendência	4 temporadas	Com 3 pontos, a regressão linear tem apenas 1 grau de liberdade — insuficiente para distinguir uma tendência real de uma variação isolada entre duas temporadas. Com 4+, o cálculo passa a ter uma base estatística mínima mais sólida.
Classificação de tendência	Positiva: > +0,05 · Negativa: < −0,05 · Neutra: entre −0,05 e +0,05	O coeficiente angular (slope) da regressão tem uma margem de ruído esperada, mesmo sem nenhuma evolução real acontecendo. A faixa neutra reconhece essa margem, em vez de classificar qualquer desvio de zero como uma tendência "real".
Escopo de competições	Apenas jogos da liga nacional	Evita misturar contextos de competitividade diferentes (liga doméstica vs. competições europeias) na mesma métrica.
6. Tecnologias utilizadas
Camada	Ferramenta
Coleta de dados	Python, soccerdata
Tratamento e limpeza	Python, Pandas
Armazenamento	SQL Server
Modelagem e regras de negócio	SQL (views)
Visualização	Power BI (Power Query, DAX)
Versionamento	Git / GitHub
7. Pipeline do projeto
FBref
Coleta de dadosPython + soccerdata
Dados brutosCSV
Limpeza e tratamentoPandas
Dados tratadosCSV limpo
SQL ServerCarga das tabelas
Views SQLRegras e métricas denegócio
Power BIModelo de dados + DAX
DashboardEvolução dos Jogadores +Ranking de Jogadores

O fluxo segue uma lógica de responsabilidade única por camada: a coleta em Python não aplica regra de negócio nenhuma, o tratamento em Pandas resolve inconsistências e formata os dados, e as regras de análise (critérios de elegibilidade, cálculo de tendência, classificação) ficam concentradas no SQL, para não haver lógica duplicada entre banco e Power BI.

8. Tratamento e preparação dos dados

Etapas realizadas com Pandas antes da carga no banco:

Padronização de nomes de jogadores e times entre temporadas (para evitar que o mesmo jogador apareça como entidades diferentes por variação de grafia).
Tratamento de jogadores que atuaram por mais de um clube na mesma temporada.
Conversão e padronização de tipos de dado (minutos, partidas, gols e assistências como valores numéricos consistentes).
Geração da métrica derivada G+A/90 a partir dos totais de gols, assistências e minutos jogados.
Exportação para CSV limpo, servindo de base para a carga no SQL Server.
9. Banco de dados / SQL

Os dados tratados são carregados em uma tabela base (DadosFUTLimpos) no SQL Server, com granularidade de jogador por temporada. A partir dela, foram criadas views para concentrar as regras de negócio e evitar recalcular a mesma lógica em múltiplos lugares (banco e Power BI):

vw_RankingTendenciaJogadores — calcula a tendência de G+A/90 de cada jogador via regressão linear (mínimos quadrados), aplicando o critério de mínimo de 4 temporadas.
vw_KPI3_MaiorEvolucao — retorna o jogador com a maior tendência positiva dentro da amostra elegível.
vw_KPI2_MaiorDeclinio — retorna o jogador com a maior tendência negativa dentro da amostra elegível.
vw_DadosJogadorTemporada — base utilizada pelo Power BI para os indicadores dinâmicos por jogador (ex.: média de G+A/90 ponderada por minutos).

A decisão de calcular a regressão linear diretamente em SQL (em vez de recriá-la em DAX) foi deliberada: evita duplicar a mesma fórmula em duas linguagens diferentes, com dois pontos de manutenção e risco de divergência entre eles.

10. Dashboard no Power BI

O dashboard é dividido em duas páginas com propósitos distintos.

Página 1 — Evolução dos Jogadores

Mostrar Imagem

Foco na trajetória individual de um jogador ao longo das temporadas disponíveis:

Busca de jogador, com gráfico de G+A/90 por temporada e tabela-resumo (partidas, minutos, gols, assistências, G+A e G+A/90 por temporada).
KPI de média de G+A/90, calculado de forma ponderada por minutos (não é uma média simples das taxas anuais — temporadas com mais minutos jogados têm peso proporcionalmente maior no cálculo). O KPI é dinâmico: mostra a média do jogador selecionado, ou a média geral da base quando nenhum jogador está selecionado.
Ranking de "Maior evolução" e "Maior declínio" de tendência, calculado por regressão linear sobre o G+A/90 do jogador ao longo das temporadas disponíveis, exigindo no mínimo 4 temporadas para garantir uma base estatística mínima na estimativa.
Gráfico de distribuição de tendência (Positiva / Neutra / Negativa) sobre a base elegível.
Página 2 — Ranking de Jogadores

Mostrar Imagem

Foco em comparação de desempenho dentro de um recorte específico:

Segmentação por temporada, métrica (Gols, Assistências, G+A) e liga.
Ranking Top 10 dinâmico, com título que reflete o filtro selecionado.
Considera apenas jogos das ligas nacionais, com o mesmo piso de 900 minutos por temporada aplicado na base.
11. Principais métricas e lógica das análises

G+A/90 (Gols + Assistências por 90 minutos) Normaliza a produção ofensiva por tempo de jogo, permitindo comparar jogadores com volumes de minutos diferentes. É uma taxa, e como toda taxa calculada sobre poucas observações, tende a ter mais ruído quando a amostra de minutos é pequena — por isso o piso de 900 minutos é aplicado antes de qualquer outro cálculo.

Tendência (regressão linear) Para cada jogador com 4 ou mais temporadas elegíveis, calcula-se o coeficiente angular (slope) da regressão linear de G+A/90 ao longo do tempo. O objetivo é identificar uma direção de evolução ou declínio consistente — não apenas comparar a primeira e a última temporada isoladamente, o que seria mais sensível a uma única variação atípica.

Uma variação isolada entre duas temporadas não é, por si só, evidência de tendência: por isso o mínimo de 4 temporadas e a classificação por faixa (e não pelo sinal exato do coeficiente) fazem parte do critério. Jogadores com coeficiente entre −0,05 e +0,05 são classificados como neutros, por representar uma variação dentro do que se pode esperar por flutuação normal entre temporadas — e não uma tendência real de evolução ou declínio.

Vale destacar: os resultados são interpretados como "maior tendência positiva dentro da amostra analisada", não como afirmações absolutas do tipo "jogador que mais evoluiu no futebol" — a amostra é restrita a jogadores com volume mínimo de minutos e presença consistente nas cinco principais ligas, o que já é um recorte específico, não uma avaliação universal.

12. Estrutura de pastas do repositório
text
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

Alguns diretórios acima (como notebooks/) representam a estrutura planejada do projeto e podem ainda estar em organização.

13. Como executar / reproduzir o projeto
Clone o repositório.
Instale as dependências Python do projeto (Pandas, soccerdata).
Execute os scripts de coleta para obter os dados do FBref.
Execute os scripts/notebooks de tratamento para gerar o CSV limpo.
Carregue o CSV tratado no SQL Server e execute os scripts em sql/ para criar as views.
Abra o arquivo .pbix em powerbi/ e aponte a conexão de dados para o seu banco SQL Server.
Atualize os dados (Refresh) no Power BI.
14. Limitações do projeto
A classificação de tendência usa uma faixa fixa (±0,05) como aproximação do ruído estatístico esperado, e não um teste formal de significância (como intervalo de confiança por jogador). É uma heurística baseada na ordem de grandeza do ruído da regressão com poucas observações, não um cálculo de p-valor.
A regressão linear não distingue uma evolução gradual de uma mudança de patamar associada a um evento específico (ex.: transferência para um clube diferente) — ambas podem gerar o mesmo coeficiente angular.
G+A/90 não separa gols de pênalti dos demais, nem ajusta por posição ou papel tático do jogador em campo.
Diferenças no número de jogos por temporada entre ligas (por exemplo, calendários de 34 rodadas contra 38) não são normalizadas nos rankings de totais (gols, assistências, G+A) da página 2.
A amostra já é filtrada por jogadores estabelecidos (900+ minutos, 4+ temporadas nas cinco principais ligas), o que naturalmente reduz a variabilidade observada — o projeto não captura jogadores em início de carreira ou com passagens mais curtas por essas ligas.
15. Possíveis melhorias futuras
Substituir a faixa fixa de classificação de tendência por um cálculo de intervalo de confiança do coeficiente angular por jogador.
Segmentar as análises por posição e faixa etária.
Identificar e sinalizar mudanças de clube no gráfico de evolução, para diferenciar mudança de contexto de evolução orgânica.
Incluir métricas adicionais (gols sem pênalti, xG, por exemplo) quando disponíveis na fonte.
Normalizar rankings de totais pelo número de jogos disputados por liga/temporada.
16. Conclusão

O projeto foi construído com atenção deliberada a um problema comum em análises esportivas: confundir variação estatística normal com tendência real, especialmente em amostras pequenas. As decisões de critério (piso de minutos, mínimo de temporadas, faixa de classificação neutra) foram tomadas — e revisadas — justamente para reduzir esse risco, e estão documentadas para que qualquer pessoa possa questionar ou ajustar essas escolhas.

17. Autor

Desenvolvido como projeto de portfólio em Análise de Dados / Business Intelligence.
