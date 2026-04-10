# Changelog

All notable changes to this project will be documented in this file.
Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [3.1.0] - 2026-04-10

### Fixed / Corrigido
- **Precision Text Centering**: Implemented exact vertical centering for numeric values inside `TStatsPanel` arcs using native Skia font metrics (`TSkFontMetrics` with `Ascent` and `Descent`), replacing imprecise bounds calculations.
- **Centralização de Texto com Precisão**: Implementada a centralização vertical exata dos valores numéricos dentro dos arcos do `TStatsPanel`, substituindo cálculos imprecisos de limites por métricas nativas do Skia (`TSkFontMetrics` com `Ascent` e `Descent`).
- **Search Bar Alignment**: Fixed the vertical alignment of the borderless `TEdit` within the rounded search bar container, respecting the font's natural height.
- **Alinhamento da Barra de Busca**: Correção do alinhamento vertical do `TEdit` sem bordas na barra de pesquisa, respeitando a altura natural da fonte dentro do container arredondado.
- **Sprite Bounding Box**: Adjusted the geometric center of the `TSkAnimatedImage` (`skImgPokemon`) to prevent the Pokémon sprite from being displaced or visually squashed against the description panel.
- **Bounding Box do Sprite**: Ajuste do centro geométrico do `TSkAnimatedImage` (`skImgPokemon`), evitando que o sprite do Pokémon fique deslocado ou achatado contra o painel de descrição.

---

## [3.0.0] - 2026-04-09

### Added / Adicionado
- **Custom Search Bar**: Replaced native `TSearchBox` with a fully custom component using `TSkPaintBox` (rounded semi-transparent background) and a transparent `TEdit`, matching the dynamic theme color.
- **Barra de Busca Customizada**: Substituído o `TSearchBox` nativo por um componente totalmente customizado com `TSkPaintBox` (fundo arredondado semi-transparente) e `TEdit` transparente, integrado ao tema dinâmico.
- **TStatsPanel Component**: New Skia-based component that draws Pokémon base stats as circular arcs, with weight, height and ability rendered inside the same dark panel.
- **Componente TStatsPanel**: Novo componente baseado em Skia que desenha os atributos base do Pokémon como arcos circulares, com peso, altura e habilidade renderizados no mesmo painel escuro.
- **IPokemonService Interface**: Extracted HTTP service contract into a dedicated interface, enabling dependency injection in the controller.
- **Interface IPokemonService**: Contrato de serviço HTTP extraído para uma interface dedicada, permitindo injeção de dependência no controller.
- **Startup Pokémon**: Application now loads Bulbasaur automatically on startup via `PostMessage` to ensure the form is fully initialized before the first HTTP request.
- **Pokémon Inicial**: A aplicação agora carrega o Bulbasaur automaticamente ao iniciar via `PostMessage`, garantindo que o formulário esteja completamente inicializado antes da primeira requisição HTTP.

### Changed / Alterado
- **TApiResource**: Renamed `TAbilityInfo` to `TApiResource` across the entire model, correctly reflecting the PokeAPI Named Resource pattern used for species, color, evolution chain and language references.
- **TApiResource**: Renomeado `TAbilityInfo` para `TApiResource` em todo o modelo, refletindo corretamente o padrão Named Resource da PokeAPI usado para espécie, cor, cadeia evolutiva e referências de idioma.
- **Description Panel**: Replaced `TMemo` with `TSkLabel` rendered in italic white text over a fixed dark background panel, visually separated from the theme color.
- **Painel de Descrição**: Substituído `TMemo` por `TSkLabel` renderizado em texto branco itálico sobre um painel escuro fixo, separado visualmente da cor do tema.
- **Navigation**: Reverted to ID-based navigation for simplicity, removing the autocomplete list dependency entirely.
- **Navegação**: Revertida para navegação por ID para simplicidade, removendo completamente a dependência da lista de autocomplete.
- **Layout**: Both side panels now extend to full window height, with the topbar floating above via `BringToFront`, creating a seamless full-bleed theme effect.
- **Layout**: Ambos os painéis laterais agora se estendem até a altura total da janela, com a topbar flutuando por cima via `BringToFront`, criando um efeito de tema sem bordas.
- **GetSpeciesJSON**: Fixed shared REST client state mutation by replacing `RESTClientPoke` with a dedicated `TNetHTTPClient` instance for species URL resolution.
- **GetSpeciesJSON**: Corrigida a mutação de estado compartilhado do REST client, substituindo `RESTClientPoke` por uma instância dedicada de `TNetHTTPClient` para resolução da URL de espécie.

### Removed / Removido
- **TComboBox / TButton**: Removed native VCL search input and search button, replaced by the custom Skia search bar.
- **TComboBox / TButton**: Removidos o campo de busca e o botão nativos do VCL, substituídos pela barra de busca Skia customizada.
- **TMemo**: Removed native memo component for flavor text display.
- **TMemo**: Removido o componente memo nativo para exibição do flavor text.
- **Autocomplete List**: Removed `TStringList` and `FillAutoCompleteList` — no longer needed with ID-based navigation.
- **Lista de Autocomplete**: Removidos `TStringList` e `FillAutoCompleteList` — não mais necessários com navegação por ID.

---

## [2.0.0] - 2026-04-07

### Added / Adicionado
- **Dynamic Type Badges**: Implementation of Pokémon type badges using `TSkLabel` and `TShape` with dynamic colors and black outlines.
- **Badges Dinâmicas de Tipo**: Implementação de badges de tipo usando `TSkLabel` e `TShape` com cores dinâmicas e contornos pretos.
- **Index-Based Navigation**: Replaced ID arithmetic with list-index navigation to support special forms and Megas (IDs 10000+).
- **Navegação Baseada em Índice**: Substituída a aritmética de ID por navegação via índice da lista para suportar formas especiais e Megas (IDs 10000+).
- **Safety Boundaries**: Added alerts when reaching the start or end of the Pokémon list.
- **Limites de Segurança**: Adicionados alertas ao atingir o início ou o fim da lista de Pokémon.

### Changed / Alterado
- **UI Refactoring**: Repositioned type badges below the Pokémon name to prevent clipping with large sprites.
- **Refatoração da UI**: Reposicionadas as badges de tipo abaixo do nome do Pokémon para evitar cortes visuais em sprites grandes.
- **Modular View Logic**: Fatched the `PerformSearch` method and badge rendering into specialized sub-procedures for better maintainability.
- **Lógica de View Modular**: Fatiado o método `PerformSearch` e a renderização de badges em sub-procedures especializadas para melhor manutenção.
- **Form Layout**: Increased form height and added padding to `pnlImage` for better visual breathing room.
- **Layout do Formulário**: Aumentada a altura do form e adicionado padding ao `pnlImage` para melhor respiro visual.

### Optimized / Otimizado
- **O(1) Performance**: Migrated Pokémon color lookups from sequential `IF` blocks to `TDictionary` hash maps.
- **Performance O(1)**: Migrada a busca de cores de Pokémon de blocos `IF` sequenciais para mapas hash `TDictionary`.

---

## [1.0.0] - 2026-03-27

### Added / Adicionado
- **Initial Release**: Basic Pokédex structure integrated with PokeAPI.
- **Lançamento Inicial**: Estrutura básica da Pokédex integrada com a PokeAPI.
- **Visuals**: Sprite display using Skia and basic stat information.
- **Visuais**: Exibição de sprites usando Skia e informações básicas de estatísticas.