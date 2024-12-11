# Collectible

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

## Resumo Simples

O contrato `Collectible` implementa NFTs economicamente sustentáveis utilizando recursos derivados do padrão ERC721. Ele integra taxas de minting dinâmicas, controle de acesso baseado em funções e engajamento baseado em doações. Esses mecanismos alinham a tokenômica com os princípios de escassez e atribuição de valor, ao mesmo tempo que promovem o engajamento da comunidade entre criadores e colaboradores.

## Resumo

O contrato `Collectible` permite que criadores mintem tokens não-fungíveis (NFTs) e interajam com colaboradores através de doações e funcionalidades de assinatura de criador. As taxas de minting são ajustadas dinamicamente com base na atividade do usuário e em um modelo de decaimento, incentivando o engajamento contínuo enquanto garante a sustentabilidade econômica. Colaboradores podem apoiar diretamente os criadores, e usuários podem obter acesso a papéis especiais de criador ao pagar uma taxa.

## Motivação

Sistemas tradicionais de NFT frequentemente enfrentam desafios como fornecimento inflacionário e incentivos limitados ao engajamento. O contrato `Collectible` resolve esses desafios ao:

1. Implementar uma taxa de minting dinâmica e ajustes controlados para incentivar o engajamento.
2. Introduzir mecânicas de doação para promover contribuições baseadas na comunidade.
3. Definir privilégios claros baseados em papéis para apoiar interações estruturadas entre criadores e colaboradores.

## Especificação

O contrato `Collectible` segue o padrão ERC721 e inclui as seguintes funcionalidades principais:

### Funcionalidades

- **Taxas de Minting Dinâmicas:** As taxas de minting diminuem com base na atividade do usuário, incentivando o engajamento contínuo.
- **Gestão de Papéis:** Usando `AccessControl` do OpenZeppelin, papéis distintos são atribuídos para criadores e colaboradores.
- **Mecânica de Doação:** Usuários podem doar ETH para criadores específicos, promovendo o engajamento da comunidade.
- **Assinaturas de Criador:** Usuários podem pagar uma taxa para adquirir um papel de criador, desbloqueando privilégios especiais.
- **Limites de Minting:** Impõe limites máximos de minting por usuário antes de seus descontos se resetarem dentro de um limite configurável.
- **Cálculo da Taxa de Minting:** As taxas de minting ajustam-se dinamicamente com base na atividade de minting do usuário.

### Funções Principais

- `safeMint`: Permite que os criadores mintem novos tokens, aplicando limites de minting e taxas.
- `donate`: Facilita doações de ETH para criadores específicos.
- `getCreatorSignature`: Concede o papel de criador a usuários que pagam a taxa de assinatura.
- `mintFee`: Retorna a taxa de minting atual para o chamador com base no histórico de minting. A taxa é ajustada dinamicamente usando uma função logarítmica para garantir reduções graduais e suaves à medida que o número de mintings do usuário aumenta.
- `updateTerms`: Função de administração para atualizar os termos de minting, incluindo taxas base, taxas de assinatura e limites máximos de minting por usuário.
- `withdraw`: Permite que o administrador retire ETH do contrato.
- `burn`: Permite que os proprietários de tokens queimem seus NFTs.
- `pause` e `unpause`: Funções de administração para pausar ou retomar o contrato.

### Fórmula de Taxa de Minting

O contrato utiliza uma fórmula de uso inverso para as taxas de minting:

```solidity
if (hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) return 0;
uint256 userMints = mintsPerUserInCycle[msg.sender];
uint256 divisor = userMints == 0 ? 1 : Math.log2(userMints + 2);
return mintBaseFee / divisor;
```

### Intervalo de Atualização dos Termos

O contrato impõe um mecanismo de cooldown para atualizações:

```solidity
require(
    block.timestamp >= lastUpdateTimestamp + UPDATE_INTERVAL, 
    "Atualizações não disponíveis. Tente antes do seu primeiro mint do próximo ciclo."
);
```

- **`UPDATE_INTERVAL`:** Define um intervalo de 30 dias para a atualização dos termos de minting.

## Justificativa

O design do contrato incentiva:

- **Engajamento:** Taxas dinâmicas incentivam interações de longo prazo.
- **Apoio à Comunidade:** Doações permitem que os colaboradores apoiem diretamente seus criadores favoritos.
- **Sustentabilidade:** O acesso baseado em papéis e as taxas ajustáveis garantem um sistema economicamente equilibrado.

## Compatibilidade com Versões Anteriores

O contrato é totalmente compatível com o padrão ERC721 e se integra perfeitamente com as extensões do OpenZeppelin, como `ERC721URIStorage`, `ERC721Pausable` e `AccessControl`. Seu design modular permite escalabilidade e adaptação futuras.

## Casos de Teste

O contrato deve ser testado nos seguintes cenários:

1. **Testes de Minting:** Validar o comportamento de minting, incluindo cálculos das taxas baseadas no histórico e atividade do usuário.
2. **Testes de Doação:** Garantir que as doações de ETH sejam transferidas corretamente para os criadores e a atribuição de papéis de colaboradores esteja correta.
3. **Cálculos de Taxas:** Verificar se as taxas de minting se ajustam com base na atividade do usuário.
4. **Testes de Pausar/Retomar:** Confirmar que a funcionalidade do contrato seja restrita durante as pausas.
5. **Acesso Baseado em Papéis:** Testar as restrições de acesso para criadores e colaboradores.
6. **Funcionalidade de Queima:** Garantir que apenas os proprietários de tokens possam queimá-los.

## Implementação de Referência

O contrato `Collectible` é construído utilizando os contratos do OpenZeppelin, aproveitando seu framework modular e seguro para tokens ERC721. Sobrescritas e hooks-chave garantem compatibilidade e estendem a funcionalidade dentro do framework padrão.

## Referências

- [ERC721 - Padrão de Token Não-Fungível](https://eips.ethereum.org/EIPS/eip-721)  
- [Contratos OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)  
- [Math OpenZeppelin](https://docs.openzeppelin.com/contracts/4.x/api/utils#Math)  

## Licença

   Copyright [2024] [gfLobo]

   Licenciado sob a Licença Apache, Versão 2.0 (a "Licença");
   você não pode usar este arquivo, exceto em conformidade com a Licença.
   Você pode obter uma cópia da Licença em:

       http://www.apache.org/licenses/LICENSE-2.0

   Exceto quando exigido por lei aplicável ou acordado por escrito, o software
   distribuído sob a Licença é distribuído "COMO ESTÁ",
   SEM GARANTIAS OU CONDIÇÕES DE QUALQUER TIPO, expressas ou implícitas.
   Veja a Licença para a linguagem específica que rege permissões e
   limitações sob a Licença.
