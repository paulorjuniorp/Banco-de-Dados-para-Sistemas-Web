USE ecommerce;

#1.Quais os nomes dos produtos não têm nenhuma venda?

#a) Exists
SELECT p.nome FROM produto p WHERE NOT EXISTS (SELECT * FROM venda v WHERE v.codProduto = p.codProduto);

#b) All
SELECT p.nome FROM produto p WHERE p.codProduto != ALL (SELECT v.codProduto FROM venda v);

#c) join
SELECT p.nome FROM produto p LEFT JOIN venda v ON p.codProduto = v.codProduto WHERE v.codProduto IS NULL;

#2. Qual o produto vendido que teve mais troca em 2016? Informar além do código e do nome do produto, a quantidade de troca do produto.

SELECT p.codProduto, p.nome, SUM(tp.quantidade) AS QuantidadeTroca FROM trocaproduto tp
INNER JOIN produto p ON p.codProduto = tp.codProdutoVenda
WHERE YEAR(tp.dataTroca) = 2016 
GROUP BY p.codProduto
HAVING SUM(tp.quantidade) = (
	SELECT MAX(qtd)
    FROM (
		SELECT p.codProduto, p.nome, SUM(tp.quantidade) qtd
        FROM trocaproduto tp
        INNER JOIN produto p ON tp.codProdutoVenda = p.codProduto
        WHERE YEAR(tp.dataTroca) = 2016 
        GROUP BY p.codProduto
    ) t
);


# 3. Qual o percentual de produto vendido foi trocado? Mostrar o percentual com somente duas casas decimais. 
# OBS: Considerar um produto vendido como a relação de venda de um produto em um determinado pedido.

SELECT TRUNCATE((COUNT(tp.quantidade) / COUNT(v.codProduto)) * 100, 2) AS PercentualPedProdVendido FROM venda v
LEFT JOIN trocaproduto tp ON v.codPedido = tp.codPedido AND v.codProduto = tp.codProdutoVenda;

#4. Quais produtos vendidos têm pelo menos uma troca? Informar o código e o nome do produto.

# a) EXISTS
SELECT p.codProduto, p.nome FROM produto p
WHERE EXISTS (
	SELECT v.codProduto FROM venda v 
    INNER JOIN trocaproduto tp ON tp.codProdutoVenda = v.codProduto
    WHERE p.codProduto = v.codProduto
);

# b) ANY
SELECT p.codProduto, p.nome FROM produto p 
WHERE p.codProduto = ANY (
	SELECT v.codProduto FROM venda v INNER JOIN trocaproduto tp
    ON tp.codProdutoVenda = v.codProduto
);

#5. Quais produtos vendidos têm pelo menos duas trocas? Informar o código,
# o nome do produto e a quantidade de troca.

SELECT p.nome, COUNT(p.codProduto) AS QuantidadeTroca FROM produto p
    INNER JOIN trocaproduto tp ON tp.codProdutoVenda = p.codProduto
    GROUP BY p.codProduto
    HAVING QuantidadeTroca >= 2;
    
#6. Qual é o produto mais vendido entre fevereiro e novembro de 2016? Informar além do código e do
#nome do produto, a quantidade vendida.

SELECT p.codProduto, p.nome, SUM(v.quantidade) AS qtdVendido FROM produto p 
INNER JOIN venda v ON v.codProduto = p.codProduto
INNER JOIN pedido pe ON pe.codPedido = v.codPedido
WHERE pe.data BETWEEN '2016-02-01' AND '2016-11-30'
GROUP BY p.codProduto
HAVING SUM(v.quantidade) = (
	SELECT MAX(qtdVendido)
    FROM (
		SELECT p.codProduto, p.nome, SUM(v.quantidade) AS qtdVendido FROM produto p 
		INNER JOIN venda v ON v.codProduto = p.codProduto
		INNER JOIN pedido pe ON pe.codPedido = v.codPedido
		WHERE pe.data BETWEEN '2016-02-01' AND '2016-11-30'
		GROUP BY p.codProduto
    ) t
);

#7. Qual o total de pedidos de cada forma de pagamento entre 2015 e 2016?

SELECT pe.formaPagamento, COUNT(pe.formaPagamento) AS Quantidade FROM pedido pe 
WHERE YEAR(pe.data) BETWEEN 2015 AND 2016
GROUP BY pe.formaPagamento;

#8. Qual cliente mais comprou produto entre 2016 e 2017? Informar o código e o nome do cliente, o tipo
#do cliente (física ou jurídica) e a quantidade que comprou.

SELECT c.codCLiente, c.nome, c.tipoCliente, SUM(v.quantidade) AS QtdPedidoComprado FROM cliente c 
INNER JOIN pedido pe ON pe.codCliente = c.codCliente
INNER JOIN venda v ON v.codPedido = pe.codPedido
WHERE YEAR(pe.data) BETWEEN 2016 AND 2017
GROUP BY c.codCliente
HAVING SUM(v.quantidade) = (
	SELECT MAX(QtdPedidoComprado)
    FROM (
		SELECT c.codCLiente, c.nome, c.tipoCliente, SUM(v.quantidade) AS QtdPedidoComprado FROM cliente c 
		INNER JOIN pedido pe ON pe.codCliente = c.codCliente
		INNER JOIN venda v ON v.codPedido = pe.codPedido
		WHERE YEAR(pe.data) BETWEEN 2016 AND 2017
		GROUP BY c.codCliente
    ) t
);

#9. Quais os pedidos não têm nenhuma associação com venda (“itemComprado”)? Mostrar o código, o
# ano e o status do pedido e também o nome e o tipo do cliente.

SELECT pe.codPedido, YEAR(pe.data) AS Ano, pe.status, c.nome AS Cliente, c.tipoCliente FROM pedido pe
LEFT JOIN venda v ON v.codPedido = pe.codPedido
INNER JOIN cliente c ON c.codCliente = pe.codCliente
WHERE v.codPedido IS NULL;
 
#10. Qual a quantidade de pedidos aprovados por tipo de cliente (pessoa física e jurídica)?
 
SELECT c.tipoCliente, COUNT(ped.codPedido) AS QtdPedido FROM pedido ped
INNER JOIN cliente c ON ped.codCliente = c.codCliente
WHERE ped.status = 'aprovado'
GROUP BY c.tipoCliente;

