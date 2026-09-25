USE DadosFUT


-- BASE: dados de cada jogador por temporada
CREATE VIEW vw_DadosJogadorTemporada AS
SELECT
    JOGADOR
    ,TEMPORADA
    ,TIME
    ,PARTIDAS
    ,MINUTOS
    ,GOLS
    ,ASSISTENCIAS
    ,GOLS_ASSISTENCIAS
    ,GOLS_ASSISTENCIAS_90
FROM DadosFUTLimpos;




-- Calculo da TENDÊNCIA
CREATE VIEW vw_RankingTendenciaJogadores AS
WITH DADOS_XY AS (
    SELECT
        JOGADOR
        ,TEMPORADA
        ,ROW_NUMBER() OVER(PARTITION BY JOGADOR ORDER BY TEMPORADA ASC) AS X
        ,GOLS_ASSISTENCIAS_90 AS Y
    FROM DadosFUTLimpos
)
,TABELA AS (
    SELECT
        JOGADOR
        ,X
        ,Y
        ,(X * Y) AS [X*Y]
        ,(X * X) AS [X^2]
    FROM DADOS_XY
)
,CALCULO AS (
    SELECT
        JOGADOR
        ,COUNT(*) AS N
        ,SUM([X*Y]) AS [SOMA_X*Y]
        ,SUM(X) AS SOMA_X
        ,SUM(Y) AS SOMA_Y
        ,SUM([X^2]) AS [SOMA_X*X]
    FROM TABELA
    GROUP BY JOGADOR
)
SELECT
    JOGADOR
    ,(
        (N * [SOMA_X*Y]) - (SOMA_X * SOMA_Y)
    )
    /
    (
        (N * [SOMA_X*X]) - (SOMA_X * SOMA_X)
    ) AS TENDENCIA
FROM CALCULO
WHERE N >= 4;

-- KPI: maior tendência de declínio (Top 1)
CREATE VIEW vw_KPI2_MaiorDeclinio AS
SELECT TOP 1
    JOGADOR
    ,TENDENCIA
FROM vw_RankingTendenciaJogadores
ORDER BY TENDENCIA ASC;

-- KPI: maior tendência de evolução (Top 1)
CREATE VIEW vw_KPI3_MaiorEvolucao AS
SELECT TOP 1
    JOGADOR
    ,TENDENCIA
FROM vw_RankingTendenciaJogadores
ORDER BY TENDENCIA DESC;


-- distribuição percentual de tendência
-- Positiva (>0,05) / Negativa (<-0,05) / Neutra
CREATE VIEW vw_KPI4_PercentualTendencias AS
WITH CONT_TENDENCIA AS (
    SELECT
        CASE
            WHEN TENDENCIA > 0.05 THEN 'Positiva'
            WHEN TENDENCIA < -0.05 THEN 'Negativa'
            ELSE 'Neutra'
        END AS CLASS_TENDENCIA
    FROM vw_RankingTendenciaJogadores
)
SELECT
    CLASS_TENDENCIA
    ,COUNT(*) AS QNT
    ,CAST(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()) AS DECIMAL(10,2)
    ) AS PERCENTUAL
FROM CONT_TENDENCIA
GROUP BY CLASS_TENDENCIA;


-- RANKING: desempenho por temporada
CREATE VIEW vw_pagina2_ranking AS
SELECT
    TEMPORADA
    ,JOGADOR
    ,GOLS
    ,ASSISTENCIAS
    ,GOLS_ASSISTENCIAS
FROM DadosFUTLimpos;
