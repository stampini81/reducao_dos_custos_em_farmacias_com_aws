# RELATÓRIO DE IMPLEMENTAÇÃO DE SERVIÇOS AWS

Data: 15 de agosto de 2025
Empresa: FarmaCorp Soluções
Responsável: Leandro da Silva Stampini

## Introdução
Este relatório apresenta o processo de implementação de ferramentas na empresa FarmaCorp Soluções, realizado por Leandro da Silva Stampini. O objetivo do projeto foi elencar 3 serviços AWS, com a finalidade de realizar diminuição de custos imediatos e otimizar a gestão de dados.

## Repositório do Projeto no GitHub
O código-fonte, scripts de configuração e documentação técnica detalhada deste projeto estão disponíveis neste repositório. Recomenda-se clonar ou fazer um "fork" do repositório para análises e evoluções futuras.

- Link do Repositório: https://github.com/stampini81/reducao_dos_custos_em_farmacias_com_aws

## Descrição do Projeto
O projeto de implementação de ferramentas foi dividido em 3 etapas, cada uma com seus objetivos específicos. A seguir, serão descritas as etapas do projeto:

### Etapa 1
- Nome da ferramenta: Amazon S3 Glacier Deep Archive
- Foco da ferramenta: Armazenamento de dados de longo prazo com o menor custo na nuvem.
- Descrição de caso de uso: A FarmaCorp Soluções precisa reter dados fiscais, receitas médicas e históricos de vendas por muitos anos para cumprir regulações da ANVISA e requisitos legais. Atualmente, esses dados ocupam um espaço custoso em armazenamento primário. A implementação do S3 Glacier Deep Archive permitirá arquivar esses dados raramente acessados a um custo extremamente baixo, liberando storage de alto desempenho e reduzindo drasticamente os custos mensais de armazenamento.

### Etapa 2
- Nome da ferramenta: AWS Lambda
- Foco da ferramenta: Execução de código sem servidor (Serverless), pagando apenas pelo tempo de computação utilizado.
- Descrição de caso de uso: O sistema de gestão de estoque da FarmaCorp executa rotinas noturnas para processar vendas, atualizar níveis de inventário e gerar pedidos de reposição. Essas rotinas rodam em um servidor que fica a maior parte do tempo ocioso. Ao migrar essas tarefas para funções Lambda, a FarmaCorp pagará apenas pelos segundos de processamento, eliminando os custos fixos de um servidor dedicado e a necessidade de manutenção do sistema operacional.

### Etapa 3
- Nome da ferramenta: AWS Backup
- Foco da ferramenta: Centralizar e automatizar o backup de dados em todos os serviços AWS.
- Descrição de caso de uso: A empresa precisa garantir a segurança e a recuperação de dados críticos, como o banco de dados de clientes e sistemas de ponto de venda (PDV). O AWS Backup será configurado para automatizar os backups desses sistemas de forma centralizada. Ele permite criar políticas de retenção que movem backups mais antigos para armazenamentos mais baratos (cold storage) automaticamente, otimizando os custos e garantindo a conformidade e a segurança dos dados de forma eficiente.

## Conclusão
A implementação de ferramentas na empresa FarmaCorp Soluções tem como esperado a otimização drástica dos custos de armazenamento de longo prazo, a redução de despesas com infraestrutura de servidores e a automação segura e econômica das rotinas de backup, o que aumentará a eficiência operacional e a segurança de dados da empresa. Recomenda-se a continuidade da utilização das ferramentas implementadas e a busca por novas tecnologias que possam melhorar ainda mais os processos da empresa.

## Anexos
- N/A

Assinatura do Responsável pelo Projeto:

Leandro da Silva Stampini
