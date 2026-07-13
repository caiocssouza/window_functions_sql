/* ============================================================
   WINDOW FUNCTIONS EM SQL
   Banco: db_dsa_cap14.db (SQLite)
   Autor: Caio Cesar Silva e Souza

   ------------------------------------------------------------
   Tabelas:
   TB_DSA_CLIENTES  (ID_Cliente, Nome_Cliente, Cidade, Estado,
                     Pais, Regiao, Mercado, Segmento)
   TB_DSA_PEDIDOS   (ID_Pedido, Ano, Mes, Dia, Modo_Envio,
                     Prioridade_Pedido)
   TB_DSA_PRODUTOS  (ID_Produto, Nome_Produto, Categoria,
                     SubCategoria)
   TB_DSA_VENDAS    (Pedido, Produto, Cliente, Quantidade_Vendida,
                     Valor_Venda, Custo_Envio)

   ------------------------------------------------------------
   O que são Window Functions?
   Funções que fazem cálculos sobre um conjunto de linhas (a
   "janela") sem eliminar as linhas originais do resultado.
   Diferença principal: GROUP BY agrupa e elimina linhas.
   Window Function calcula e mantém todas as linhas.

   Sintaxe base:
   FUNÇÃO() OVER (PARTITION BY coluna ORDER BY coluna)
   ============================================================ */


/* ------------------------------------------------------------
   1. FUNÇÕES DE RANKING — ROW_NUMBER, RANK, DENSE_RANK
   ------------------------------------------------------------
   ROW_NUMBER : numera sequencialmente, sem empate
   RANK       : empata e pula posições
   DENSE_RANK : empata sem pular posições

   Exemplo com pontuações 100, 90, 90, 90, 70:
   ROW_NUMBER : 1, 2, 3, 4, 5
   RANK       : 1, 2, 2, 2, 5
   DENSE_RANK : 1, 2, 2, 2, 3
   ------------------------------------------------------------ */

-- 1.1 Top 10 vendas com ranking geral (três funções lado a lado)
SELECT
    Produto,
    Valor_Venda,
    ROW_NUMBER() OVER (ORDER BY Valor_Venda DESC) AS Row_Number,
    RANK()       OVER (ORDER BY Valor_Venda DESC) AS Rank,
    DENSE_RANK() OVER (ORDER BY Valor_Venda DESC) AS Dense_Rank
FROM TB_DSA_VENDAS
LIMIT 10;


/* ------------------------------------------------------------
   2. PARTITION BY — RANKING POR GRUPO
   ------------------------------------------------------------
   Divide os dados em grupos e aplica o cálculo separadamente
   dentro de cada grupo. Todas as linhas aparecem no resultado,
   mas cada grupo tem seu próprio ranking reiniciando do 1.

   Diferença importante: PARTITION BY não filtra linhas,
   ele divide. WHERE filtra, PARTITION BY agrupa o cálculo.
   ------------------------------------------------------------ */

-- 2.1 Ranking de compras por cliente (maior para menor valor)
SELECT
    Nome_Cliente AS Nome,
    Produto,
    Valor_Venda,
    ROW_NUMBER() OVER (PARTITION BY Nome_Cliente
                       ORDER BY Valor_Venda DESC) AS Ranking
FROM TB_DSA_VENDAS AS V
INNER JOIN TB_DSA_CLIENTES AS C
    ON V.Cliente = C.ID_Cliente
ORDER BY Nome_Cliente, Ranking;

-- 2.2 Ranking de vendas por segmento de cliente
SELECT
    Segmento,
    Nome_Cliente AS Nome,
    Valor_Venda,
    ROW_NUMBER() OVER (PARTITION BY Segmento
                       ORDER BY Valor_Venda DESC) AS Ranking
FROM TB_DSA_VENDAS AS V
INNER JOIN TB_DSA_CLIENTES AS C
    ON V.Cliente = C.ID_Cliente
ORDER BY Segmento, Ranking;


/* ------------------------------------------------------------
   3. CTE + WINDOW FUNCTION — FILTRAR O RANKING
   ------------------------------------------------------------
   O WHERE não enxerga colunas criadas por Window Function
   na mesma query. A CTE resolve isso em duas etapas:
   1ª etapa (dentro do WITH): calcula o ranking.
   2ª etapa (fora do WITH): filtra usando o ranking calculado.
   ------------------------------------------------------------ */

-- 3.1 Top 3 compras de cada cliente (maior valor por cliente)
WITH CTE_TOP3_CLIENTES AS (
    SELECT
        Nome_Cliente AS Nome,
        Produto,
        Valor_Venda,
        ROW_NUMBER() OVER (PARTITION BY Nome_Cliente
                           ORDER BY Valor_Venda DESC) AS Ranking
    FROM TB_DSA_VENDAS AS V
    INNER JOIN TB_DSA_CLIENTES AS C
        ON V.Cliente = C.ID_Cliente
)
SELECT *
FROM CTE_TOP3_CLIENTES
WHERE Ranking <= 3
ORDER BY Nome, Ranking;

-- 3.2 Top 3 produtos por categoria (maior valor de venda)
WITH CTE_TOP3_CATEGORIA AS (
    SELECT
        Categoria,
        Nome_Produto AS Produto,
        Valor_Venda,
        ROW_NUMBER() OVER (PARTITION BY Categoria
                           ORDER BY Valor_Venda DESC) AS Ranking
    FROM TB_DSA_VENDAS AS V
    INNER JOIN TB_DSA_PRODUTOS AS P
        ON V.Produto = P.ID_Produto
)
SELECT *
FROM CTE_TOP3_CATEGORIA
WHERE Ranking <= 3
ORDER BY Categoria, Ranking;

-- 3.3 Top 2 clientes com maior total gasto por segmento
WITH CTE_TOP2_SEGMENTO AS (
    SELECT
        Segmento,
        Nome_Cliente AS Nome,
        ROUND(SUM(Valor_Venda), 2) AS Total,
        ROW_NUMBER() OVER (PARTITION BY Segmento
                           ORDER BY SUM(Valor_Venda) DESC) AS Ranking
    FROM TB_DSA_VENDAS AS V
    INNER JOIN TB_DSA_CLIENTES AS C
        ON V.Cliente = C.ID_Cliente
    GROUP BY Segmento, Nome_Cliente
)
SELECT *
FROM CTE_TOP2_SEGMENTO
WHERE Ranking <= 2
ORDER BY Segmento, Ranking;
