# Collectible - CERC721

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

## Sumário

O **Collectible** é uma implementação de um sistema de colecionáveis baseado no padrão ERC721 para tokens não fungíveis (NFTs). Ele oferece funcionalidades como a criação de tokens, doações para criadores, sorteios (raffles), e controle dinâmico de taxas de minting, tudo gerido por papéis de acesso como "Criador" e "Contribuidor".

## Resumo

Este contrato permite que criadores mintem tokens ERC721 com URIs associadas, e estabelece um sistema de doações e sorteios (raffles) para engajar a comunidade. Criadores podem organizar sorteios onde contribuintes podem participar, e o contrato garante que os tokens sejam distribuídos de forma transparente e aleatória. Além disso, a implementação inclui a habilidade de pausar o contrato e taxas de minting que aumentam conforme o número de tokens de um usuário.

## Motivação

A motivação por trás deste contrato é fornecer uma plataforma flexível e segura para a criação e gestão de tokens não fungíveis (NFTs) que vão além de simples coleções. O uso de doações e sorteios é projetado para fomentar a interação entre criadores e contribuintes, oferecendo incentivos para participar do ecossistema. As taxas dinâmicas de minting tornam o sistema justo, considerando a contribuição e a participação dos usuários.

## Especificação

Este contrato implementa o padrão **ERC721** com algumas extensões:

- **ERC721URIStorage**: Permite associar URIs aos tokens.
- **ERC721Pausable**: Possibilita pausar o contrato para emergências.
- **AccessControl**: Define papéis para "Criador" e "Contribuidor".
- **ERC721Burnable**: Permite a queima (destruição) de tokens.
- **ReentrancyGuard**: Previne ataques de reentrância.

### Funções Principais:

1. **safeMint**: Permite a criação de tokens por criadores. Requer uma taxa de minting.
2. **donate**: Usuários podem doar ETH para criadores, tornando-se contribuintes.
3. **createRaffle**: Criadores podem criar sorteios para seus tokens.
4. **joinRaffle**: Contribuintes podem participar de sorteios dos tokens.
5. **getCreatorSignature**: Usuários podem pagar para obter o status de criador e mintar tokens.
6. **withdraw**: Permite ao administrador retirar ETH acumulado no contrato.

## Advertências

- O contrato exige que o criador seja definido com a função `getCreatorSignature`, e o dono do token deve ser o criador do sorteio para poder gerenciar os participantes.
- A função de sorteio (`joinRaffle`) é projetada para garantir que os sorteios ocorram somente quando o valor esperado for atingido e quando houver contribuintes suficientes.

## Lógica

A escolha de integrar **ERC721**, **ERC721URIStorage**, **ERC721Pausable**, **AccessControl** e **ReentrancyGuard** foi motivada pela necessidade de um sistema robusto e flexível para suportar a criação de colecionáveis com papéis de participação e controle de acesso. A implementação de sorteios e doações também é inspirada em modelos de financiamento coletivo.

## Compatibilidade

Este contrato é compatível com contratos ERC721 e segue o padrão, garantindo que a implementação seja interoperável com outras soluções de tokens não fungíveis e marketplaces.

## Casos de teste

Testes de funcionalidade foram realizados para verificar as seguintes características:

- Criação de tokens e associação de URIs.
- Doações e atribuição de papéis de criador e contribuidor.
- Funcionamento dos sorteios com valores dinâmicos e participantes.
- Pausa e retomada do contrato.
- Funções do administrador da coleção como atualização de taxas e resgate do dinheiro.

## Implementações

O contrato foi desenvolvido e testado em ambientes compatíveis com a versão **Solidity ^0.8.20** e utilizando a biblioteca **OpenZeppelin Contracts ^5.0.0**.

## Referências

- [ERC721 - Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

## Direitos autorais

    Direitos autorais [2024] [gfLobo]

    Licenciado sob a Licença Apache, Versão 2.0 (a "Licença");
    você não pode usar este arquivo, exceto em conformidade com a Licença.
    Você pode obter uma cópia da Licença em

    http://www.apache.org/licenses/LICENSE-2.0

    A menos que exigido pela lei aplicável ou acordado por escrito, o software
    distribuído sob a Licença é distribuído "NO ESTADO EM QUE SE ENCONTRA",
    SEM GARANTIAS OU CONDIÇÕES DE QUALQUER TIPO, expressas ou implícitas.
    Consulte a Licença para obter o idioma específico que rege as permissões e
    limitações sob a Licença.