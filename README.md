# Pokédex Delphi Skia (MVP 1.0)

Uma Pokédex moderna construída em Delphi 12 utilizando a PokeAPI e o framework Skia4Delphi para uma interface fluida.

## Tecnologias e Conceitos

* **Delphi 12 Community Edition**
* **Skia4Delphi**: Renderização gráfica de alta performance.
* **Arquitetura MVC**: Separação clara entre View, Controller e Service.
* **REST.Client**: Consumo de API RESTful.
* **JSON Serialization**: Mapeamento de objetos com `REST.Json`.

## Funcionalidades

* Busca por Nome ou ID do Pokémon.
* Exibição de tipos, habilidades, peso e altura.
* Download dinâmico de sprites oficiais.
* Tratamento de erros e resiliência de rede (404/Connection Error).

## Como rodar

1. Clone o repositório.
2. Certifique-se de ter o **Skia4Delphi** instalado no seu RAD Studio.
3. Abra o projeto `Pokedex.dproj` e compile em **Debug** ou **Release**.

