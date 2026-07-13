# Window Functions em SQL

Estudo de Window Functions em SQL aplicadas a um banco de dados relacional com 4 tabelas, cobrindo desde o conceito até exercícios práticos com CTE e PARTITION BY.

---

## O que são Window Functions?

Funções que fazem cálculos sobre um conjunto de linhas (a "janela") sem eliminar as linhas originais do resultado.

**Diferença principal:**
- `GROUP BY` agrupa e elimina linhas
- Window Function calcula e **mantém todas as linhas**

---

## Banco de Dados

**Arquivo:** `db_dsa_cap14.db` (SQLite)

| Tabela | Colunas principais |
|---|---|
| TB_DSA_CLIENTES | ID_Cliente, Nome_Cliente, Segmento, Pais, Regiao |
| TB_DSA_PEDIDOS | ID_Pedido, Ano, Mes, Modo_Envio |
| TB_DSA_PRODUTOS | ID_Produto, Nome_Produto, Categoria, SubCategoria |
| TB_DSA_VENDAS | Pedido, Produto, Cliente, Valor_Venda, Quantidade_Vendida |

---

## Conteúdo

### 1. Funções de Ranking
- `ROW_NUMBER` — numera sequencialmente, sem empate
- `RANK` — empata e pula posições
- `DENSE_RANK` — empata sem pular posições

**Exemplo com pontuações 100, 90, 90, 90, 70:**

| Pontuação | ROW_NUMBER | RANK | DENSE_RANK |
|---|---|---|---|
| 100 | 1º | 1º | 1º |
| 90 | 2º | 2º | 2º |
| 90 | 3º | 2º | 2º |
| 90 | 4º | 2º | 2º |
| 70 | 5º | 5º | 3º |

---

### 2. PARTITION BY
Divide os dados em grupos e aplica o cálculo separadamente dentro de cada grupo. Cada grupo tem seu próprio ranking reiniciando do 1.

```sql
ROW_NUMBER() OVER (PARTITION BY Segmento ORDER BY Valor_Venda DESC)
```

---

### 3. CTE + Window Function
O `WHERE` não enxerga colunas criadas por Window Function na mesma query. A CTE resolve isso em duas etapas:

- **1ª etapa (dentro do WITH):** calcula o ranking
- **2ª etapa (fora do WITH):** filtra usando o ranking calculado

```sql
WITH CTE AS (
    SELECT
        Nome_Cliente,
        Valor_Venda,
        ROW_NUMBER() OVER (PARTITION BY Nome_Cliente
                           ORDER BY Valor_Venda DESC) AS Ranking
    FROM TB_DSA_VENDAS AS V
    INNER JOIN TB_DSA_CLIENTES AS C
        ON V.Cliente = C.ID_Cliente
)
SELECT * FROM CTE
WHERE Ranking <= 3;
```

---

## Autor

**Caio Cesar Silva e Souza**
[LinkedIn](https://linkedin.com/in/cacesouza) | [GitHub](https://github.com/caiocssouza)
