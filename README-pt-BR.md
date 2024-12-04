# Collectible

[![Licença: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

### Resumo Simples  

**Collectible** é uma extensão baseada no padrão ERC721 que aprimora o ecossistema de NFTs ao introduzir recursos como taxas de minting dinâmicas, doações para criadores e sorteios transparentes. Essas melhorias incentivam o engajamento entre criadores e contribuidores, promovendo um sistema justo e sustentável.

### Resumo  

Este EIP apresenta um contrato que expande o padrão ERC721 com funcionalidades adicionais:  
1. **Taxas de Minting Dinâmicas**: Taxas calculadas com base na posse de tokens, desincentivando o acúmulo excessivo.  
2. **Sistema de Doações**: Permite apoio direto aos criadores e engajamento da comunidade.  
3. **Sorteios On-Chain**: Oferece um sistema de recompensas transparente utilizando aleatoriedade.  
4. **Controle de Acesso Baseado em Funções**: Garante segurança e descentralização com papéis distintos para criadores e contribuidores.

### Motivação  

O objetivo é superar as limitações dos sistemas NFT tradicionais, como taxas fixas, falta de mecanismos de governança e exclusão de pequenos participantes em sorteios. A proposta promove inclusão, engajamento e distribuição equitativa de ativos digitais.

### Especificação  

O contrato estende o padrão ERC721, incorporando os seguintes módulos:  
- **ERC721URIStorage**: Habilita a associação de URIs aos tokens.  
- **ERC721Pausable**: Permite pausar o contrato em situações de emergência.  
- **AccessControl**: Define papéis como "Criador" e "Contribuidor".  
- **ERC721Burnable**: Permite a destruição de tokens.  
- **ReentrancyGuard**: Protege contra ataques de reentrância.

**Funções Principais**:  
1. `safeMint`: Permite que criadores mintem NFTs com URIs únicos, pagando taxas dinâmicas.  
2. `donate`: Usuários podem doar ETH para criadores, obtendo o status de contribuidores.  
3. `createRaffle`: Permite que criadores organizem sorteios para seus tokens.  
4. `joinRaffle`: Permite que contribuidores participem de sorteios com aleatoriedade on-chain.  
5. `getCreatorSignature`: Usuários podem pagar para se tornarem criadores e mintar tokens.  
6. `withdraw`: Administradores podem retirar ETH acumulado do contrato.  

### Justificativa  

As decisões de design foram guiadas por:  
1. **Taxas Dinâmicas**: Previnem o acúmulo excessivo, promovendo escassez e equidade.  
2. **Doações**: Inspiradas em modelos de financiamento coletivo para sustentar os criadores.  
3. **Sorteios**: Incentivam o engajamento de pequenos contribuidores por meio de transparência on-chain.  
4. **Controle de Acesso Baseado em Funções**: Utiliza `AccessControl` para descentralização e confiança.  
5. **Compatibilidade Modular**: Recursos podem ser adotados individualmente sem comprometer a interoperabilidade com ERC721.

### Compatibilidade Retroativa  

O contrato é totalmente compatível com o padrão ERC721, garantindo interoperabilidade com marketplaces, carteiras e outros sistemas que suportam o padrão.

### Casos de Teste  

Os testes verificam as seguintes funcionalidades:  
1. Criação e destruição de tokens com URIs associados.  
2. Gerenciamento de papéis para criadores e contribuidores.  
3. Operações de doação e sorteios.  
4. Pausar e retomar o contrato.  
5. Segurança contra ataques de reentrância.  

### Implementação de Referência  

Uma implementação funcional foi desenvolvida utilizando **Solidity ^0.8.20** e **OpenZeppelin Contracts ^5.0.0**.  

**Referências**:  
- [ERC721 - Padrão de Token Não Fungível](https://eips.ethereum.org/EIPS/eip-721)  
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)  

## Direitos Autorais  

   Copyright [2024] [gfLobo]

   Licenciado sob a Apache License, Versão 2.0 (a "Licença");  
   você não pode usar este arquivo exceto em conformidade com a Licença.  
   Você pode obter uma cópia da Licença em  

       http://www.apache.org/licenses/LICENSE-2.0  

   A menos que exigido pela legislação aplicável ou acordado por escrito, o software  
   distribuído sob a Licença é distribuído "COMO ESTÁ",  
   SEM GARANTIAS OU CONDIÇÕES DE QUALQUER TIPO, expressas ou implícitas.  
   Veja a Licença para a linguagem específica que governa permissões e  
   limitações sob a Licença.  
