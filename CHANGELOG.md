# Changelog

All notable changes to this project will be documented in this file.
Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [4.0.0] - 2026-04-17

### Added / Adicionado
- **TEvolutionPanel Component**: New Skia-based component that renders the full Pokémon evolution tree, including branching chains (e.g. Eevee's 8 evolutions). Sprites load asynchronously, inactive nodes are rendered in grayscale, and the active Pokémon is highlighted with the theme color.
- **Componente TEvolutionPanel**: Novo componente baseado em Skia que renderiza a árvore completa de evoluções, incluindo cadeias ramificadas (ex.: 8 evoluções do Eevee). Sprites carregam de forma assíncrona, nós inativos são renderizados em escala de cinza, e o Pokémon ativo é destacado com a cor do tema.
- **Evolution Triggers**: Each evolution node displays its trigger condition — level-up (`Nv.16`), friendship (`Amizade (Dia/Noite)`), item use (`Water Stone`), trade (`Troca c/ King's Rock`), or any other mechanism from the PokeAPI.
- **Gatilhos de Evolução**: Cada nó de evolução exibe sua condição de gatilho — level-up (`Nv.16`), amizade (`Amizade (Dia/Noite)`), uso de item (`Water Stone`), troca (`Troca c/ King's Rock`), ou qualquer outro mecanismo da PokeAPI.
- **Evolution Tree Layout**: Branching evolutions are rendered using a tree-branch style (vertical trunk + horizontal branches per child). Linear chains use a direct line. Mouse wheel scrolls the panel when the chain exceeds the visible area.
- **Layout de Árvore Evolutiva**: Evoluções ramificadas são desenhadas no estilo árvore (tronco vertical + galhos horizontais por filho). Cadeias lineares usam linha direta. Mouse wheel rola o painel quando a cadeia excede a área visível.
- **Pokémon Cry Audio**: Clicking the speaker icon or the Pokémon sprite plays the official cry sound (`.ogg` via PokeAPI), streamed in memory using BASS audio library.
- **Áudio do Grito do Pokémon**: Clicar no ícone de som ou no sprite do Pokémon reproduz o grito oficial (`.ogg` via PokeAPI), transmitido em memória via biblioteca de áudio BASS.
- **`TEvolutionTrigger` Record**: New value type in the model carrying all evolution condition data parsed from `evolution_details` — trigger type, level, happiness, item, held item, time of day, and known move type.
- **Record `TEvolutionTrigger`**: Novo tipo valor no modelo que carrega todos os dados de condição de evolução extraídos de `evolution_details` — tipo de gatilho, nível, amizade, item, item segurado, hora do dia e tipo de movimento conhecido.

### Changed / Alterado
- **Async Search**: `PerformSearch` now executes the Pokémon fetch, sprite download, and evolution chain resolution concurrently in a background thread, keeping the UI responsive during network requests.
- **Busca Assíncrona**: `PerformSearch` agora executa a busca do Pokémon, download do sprite e resolução da cadeia evolutiva de forma concorrente em uma thread de background, mantendo a UI responsiva durante requisições de rede.
- **Service Layer**: Removed the visual REST components (`TRESTClient`, `TRESTRequest`, `TRESTResponse`) from `TdmPokeService`. All HTTP calls now use dedicated `TNetHTTPClient` instances.
- **Camada de Serviço**: Removidos os componentes REST visuais (`TRESTClient`, `TRESTRequest`, `TRESTResponse`) do `TdmPokeService`. Todas as chamadas HTTP agora usam instâncias dedicadas de `TNetHTTPClient`.
- **Display Name Label**: `lblDisplayName` (`TLabel`) replaced with a dynamically created `TSkLabel` (`FDisplayNameLabel`) for consistent Skia font rendering and proper theme color integration.
- **Label do Nome**: `lblDisplayName` (`TLabel`) substituído por um `TSkLabel` criado dinamicamente (`FDisplayNameLabel`), garantindo renderização consistente com Skia e integração correta com a cor do tema.
- **Evolution Chain Parsing**: `GetEvolutionChain` rewritten with a recursive nested procedure (`CollectNodes`) that traverses all branches of the evolution tree (previously only followed `evolves_to[0]`). Parsing is now null-safe via `SafeObj` helper to avoid `EInvalidCast` on nullable PokeAPI fields.
- **Parsing da Cadeia Evolutiva**: `GetEvolutionChain` reescrita com uma procedure aninhada recursiva (`CollectNodes`) que percorre todos os galhos da árvore evolutiva (anteriormente seguia apenas `evolves_to[0]`). O parsing agora é null-safe via helper `SafeObj`, evitando `EInvalidCast` em campos nullable da PokeAPI.
- **`EVOLUTION_H`**: Evolution panel height increased from `110` to `200` px to accommodate trigger labels and larger sprite sizes.
- **`EVOLUTION_H`**: Altura do painel de evolução aumentada de `110` para `200` px para acomodar os labels de gatilho e sprites maiores.

### Fixed / Corrigido
- **`EInvalidCast` on Evolution Parsing**: `GetValue<TJSONObject>` raised `EInvalidCast` when PokeAPI returned nullable fields (`item`, `held_item`, `known_move_type`) as `null` in `evolution_details`. Replaced all nullable object reads with a `SafeObj` guard that checks `is TJSONObject` before casting.
- **`EInvalidCast` no Parsing de Evolução**: `GetValue<TJSONObject>` lançava `EInvalidCast` quando a PokeAPI retornava campos nullable (`item`, `held_item`, `known_move_type`) como `null` em `evolution_details`. Todas as leituras de objetos nullable foram substituídas pelo guard `SafeObj`, que verifica `is TJSONObject` antes do cast.
- **Duplicate `CreateForm`**: Removed duplicate `Application.CreateForm(TPokedexView, PokedexView)` call in `Pokedex.dpr` that was creating two main forms on startup.
- **`CreateForm` Duplicado**: Removida chamada duplicada de `Application.CreateForm(TPokedexView, PokedexView)` no `Pokedex.dpr` que criava dois formulários principais na inicialização.

### Removed / Removido
- **`FillAutoCompleteList`**: Removed unused method from controller that fetched all 2000+ Pokémon names for an autocomplete list no longer present in the UI.
- **`FillAutoCompleteList`**: Removido método não utilizado do controller que buscava mais de 2000 nomes de Pokémon para uma lista de autocomplete que não existe mais na interface.

---

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