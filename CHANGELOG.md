# Changelog

All notable changes to this project will be documented in this file.
Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## V5 Sprint Map / Mapa de Sprints V5

- `Sprint 1` → `feat(5.0.0): Sprint 1 - Shiny Sprite Toggle`
- `Sprint 2` → `feat(5.1.0): Sprint 2 - Quick Wins`
- `Sprint 3` → `feat(5.3.0): Sprint 3 - UX Polish & Type Chart`
- `Sprint 4` → `feat(5.4.0): Sprint 4 - Search History, Type Filter, Favorites & Translation`
- `Sprint 5` → `feat(5.5.0): Sprint 5 - Search Loading & Stability Hardening`
- `Sprint 6` → `feat(5.6.0): Sprint 6 - Offensive Chart & Lazy Movepool`
- `Sprint 7` → `feat(5.7.0): Sprint 7 - Breeding, Flavor Versions & Locations`

## [5.7.0] - 2026-04-23

### Added / Adicionado

- **Breeding info in stats panel**: The main stats tab now displays breeding data from `pokemon-species`, including gender ratio, egg groups and hatch counter.
- **Informações de breeding no painel de stats**: A aba principal de stats agora exibe dados de breeding vindos de `pokemon-species`, incluindo proporção de gênero, grupos de ovo e hatch counter.

### Technical / Técnico

- **Species model expansion**: `TPokemonSpecies` now maps `gender_rate`, `egg_groups` and `hatch_counter`, making breeding metadata available without adding a new network flow.
- **Expansão do modelo de species**: `TPokemonSpecies` agora mapeia `gender_rate`, `egg_groups` e `hatch_counter`, deixando os metadados de breeding disponíveis sem adicionar um novo fluxo de rede.

## [5.7.1] - 2026-04-23

### Changed / Alterado

- **Stats panel top alignment**: The stats panel top inset was reduced so its top edge aligns visually with the search bar.
- **Alinhamento superior do painel de stats**: O recuo superior do painel de stats foi reduzido para alinhar visualmente seu topo com a barra de busca.
- **TM and Egg list layout**: The `TM` and `EGG` subtabs now use the same responsive list presentation already adopted by `LEVEL`.
- **Layout em lista para TM e Egg**: As subabas `TM` e `EGG` agora usam a mesma apresentação responsiva em lista já adotada por `LEVEL`.

### Removed / Removido

- **Offensive effectiveness panel**: The offensive type chart was removed because it implied fixed offensive coverage from native typing alone, which is misleading when a Pokemon can learn moves of many unrelated types.
- **Painel de efetividade ofensiva**: O chart ofensivo de tipos foi removido porque implicava uma cobertura ofensiva fixa apenas pela tipagem nativa, o que é enganoso quando um Pokémon pode aprender golpes de muitos tipos não relacionados.

## [5.7.2] - 2026-04-23

### Changed / Alterado

- **Move lists expanded to 3 columns**: The learning panel now distributes `LEVEL`, `TM` and `EGG` entries across up to three columns when needed, preventing moves from being visually suppressed on dense species.
- **Listas de golpes com até 3 colunas**: O painel de aprendizagem agora distribui entradas de `LEVEL`, `TM` e `EGG` em até três colunas quando necessário, evitando que golpes fiquem visualmente suprimidos em espécies densas.
- **TM and Egg chips removed**: The `TM` and `EGG` subtabs now render plain responsive move chips instead of repeating section labels inside every row.
- **Remoção dos chips de TM e Egg**: As subabas `TM` e `EGG` agora renderizam chips responsivos simples em vez de repetir os rótulos de seção em cada linha.

## [5.7.3] - 2026-04-23

### Changed / Alterado

- **Move list density increased to 4 columns**: The move-learning grid now expands up to four columns when a species has a very dense movepool, reducing clipped chips.
- **Densidade da lista de golpes aumentada para 4 colunas**: A grade de aprendizagem de golpes agora se expande em até quatro colunas quando a espécie tem um movepool muito denso, reduzindo chips cortados.

## [5.7.4] - 2026-04-23

### Added / Adicionado

- **Flavor text version selector**: The stats tab can now expose multiple native `pokemon-species` flavor texts by game version, letting the user switch entries inline.
- **Seletor de versão do flavor text**: A aba de stats agora pode expor múltiplos flavor texts nativos de `pokemon-species` por versão de jogo, permitindo alternar as entradas inline.

### Technical / Técnico

- **Flavor entry model expansion**: `TFlavorText` now maps the `version` resource so the UI can label each description correctly.
- **Expansão do modelo de flavor entry**: `TFlavorText` agora mapeia o recurso `version` para que a UI consiga rotular cada descrição corretamente.

## [5.7.5] - 2026-04-23

### Changed / Alterado

- **Scrollable flavor dropdown overlay**: The game-version selector now opens as an overlay with its own scroll, instead of pushing the stats content downward.
- **Dropdown de flavor com scroll em overlay**: O seletor de versao do flavor agora abre como um overlay com scroll proprio, em vez de empurrar o conteudo de stats para baixo.
- **Lazy translation for version entries**: Flavor texts from English fallback are now translated only for the selected game entry, which reduces the delay when opening a Pokemon from search.
- **Traducao sob demanda para versoes**: Flavor texts vindos do fallback em ingles agora sao traduzidos apenas para a entrada de jogo selecionada, reduzindo a demora ao abrir um Pokemon pela busca.

## [5.7.6] - 2026-04-23

### Changed / Alterado

- **Paged TM and Egg lists**: The `TM` and `EGG` sections now use a simple page selector (`1`, `2`, etc.) when the move list exceeds the visible space.
- **Listas de TM e Egg com paginas**: As secoes `TM` e `EGG` agora usam um seletor simples de paginas (`1`, `2`, etc.) quando a lista de golpes excede o espaco visivel.
- **Move layout back to 3 columns**: Dense move lists were rebalanced to three columns, reducing clipping while keeping the chips readable.
- **Layout de golpes de volta para 3 colunas**: Listas densas de golpes foram reequilibradas para tres colunas, reduzindo cortes sem sacrificar a leitura dos chips.

## [5.7.8] - 2026-04-25

### Changed / Alterado

- **Location entries as chips**: Encounter locations in the `LOCALIZACOES` tab now render as flowing chips (same style as move badges), replacing the previous indented list.
- **Locais de encontro como chips**: Os locais de encontro na aba `LOCALIZACOES` agora são renderizados como chips flutuantes (mesmo estilo dos badges de golpes), substituindo a lista anterior com recuo.
- **Centered defensive type badges**: The type effectiveness badges in the stats tab are now centered per row, consistent with the flavor dropdown and other panel content.
- **Badges de tipo defensivo centralizados**: Os badges de efetividade de tipo na aba de stats agora são centralizados por linha, consistente com o dropdown de flavor e demais conteúdos do painel.
- **More locations per page**: The `LOCALIZACOES` tab now shows up to 8 game-version sections per page (previously 3), reducing unnecessary pagination for most species.
- **Mais localizacoes por pagina**: A aba `LOCALIZACOES` agora exibe ate 8 secoes de versao de jogo por pagina (antes 3), reduzindo a paginacao desnecessaria para a maioria das especies.

## [5.7.7] - 2026-04-23

### Added / Adicionado

- **Lazy-loaded locations tab**: The stats panel now includes a `LOCALIZACOES` tab that loads encounter locations on demand from `pokemon/{id}/encounters`.
- **Aba de localizacoes sob demanda**: O painel de stats agora inclui uma aba `LOCALIZACOES` que carrega os locais de encontro sob demanda a partir de `pokemon/{id}/encounters`.

### Changed / Alterado

- **Centered game dropdown**: The flavor-version dropdown was centered within the stats content area for cleaner alignment.
- **Dropdown de jogos centralizado**: O dropdown de versoes do flavor foi centralizado dentro da area de stats para um alinhamento mais limpo.

## [5.6.0] - 2026-04-23

### Added / Adicionado

- **Offensive type chart**: The stats panel now shows what the current Pokemon hits for super-effective, resisted, or null damage based on its own typing.
- **Chart ofensivo de tipos**: O painel de stats agora mostra o que o Pokémon atual acerta com dano super efetivo, resistido ou nulo com base em sua própria tipagem.
- **Type-colored movepool**: Moves in the learning panel now inherit their elemental colors, making TM, Egg and Level sections easier to scan.
- **Movepool colorido por tipo**: Os golpes no painel de aprendizagem agora herdam suas cores elementais, facilitando a leitura das seções `TM`, `Egg` e `Level`.
- **Tabbed learning panel**: The stats area gained a second tab dedicated to move learning, with internal subtabs for `LEVEL`, `TM`, and `EGG`.
- **Painel de aprendizagem com abas**: A área de stats ganhou uma segunda aba dedicada à aprendizagem de golpes, com subabas internas para `LEVEL`, `TM` e `EGG`.
- **Lazy-loaded move learning**: Move data is fetched only when the learning tab is opened, reducing wasted work when browsing multiple Pokemon.
- **Aprendizagem de golpes sob demanda**: Os dados dos golpes agora são buscados apenas quando a aba de aprendizagem é aberta, reduzindo trabalho desnecessário ao navegar por vários Pokémon.
- **Level-up list layout**: The `LEVEL` subtab now uses a list-style presentation with level markers and move chips, inspired by encyclopedia layouts.
- **Layout em lista para level-up**: A subaba `LEVEL` agora usa uma apresentação em lista com marcadores de nível e chips de golpes, inspirada em layouts de enciclopédia.

### Changed / Alterado

- **Defensive chart with abilities**: The weakness panel now factors in `Levitate`, `Thick Fat`, and `Filter`, including a note when one of these abilities modifies the chart.
- **Chart defensivo com habilidades**: O painel de fraquezas agora considera `Levitate`, `Thick Fat` e `Filter`, incluindo uma nota quando uma dessas habilidades modifica o chart.
- **Stats panel organization**: The right column was rebalanced into tabs so the original stats view remains readable without a scroll-heavy panel.
- **Organização do painel de stats**: A coluna da direita foi reequilibrada em abas para que a visualização original de stats continue legível sem depender de um painel carregado de scroll.
- **Search/history interactions**: The search history dropdown now closes on more interactions and no longer lingers over the main content.
- **Interações de busca/histórico**: O dropdown de histórico da busca agora fecha em mais interações e não fica mais persistindo sobre o conteúdo principal.
- **Left-column layout polish**: Search, name, favorite icon, navigation arrows and sprite spacing were rebalanced to reduce clutter and better center the composition.
- **Polimento do layout da coluna esquerda**: Busca, nome, ícone de favorito, setas de navegação e espaçamento do sprite foram reequilibrados para reduzir ruído visual e centralizar melhor a composição.
- **Top overlay containment**: The top search container is now constrained to the left column, preventing it from overlapping the stats panel.
- **Contenção do overlay superior**: O container de busca do topo agora fica restrito à coluna esquerda, evitando sobreposição com o painel de stats.

### Technical / Técnico

- **Controller split for movepool**: `TPokemonController` now exposes a dedicated `GetMovePool` flow instead of forcing move parsing during the main Pokemon load.
- **Separação do controller para movepool**: `TPokemonController` agora expõe um fluxo dedicado de `GetMovePool` em vez de forçar o parsing dos golpes durante a carga principal do Pokémon.
- **Move metadata model**: `TMovePoolSection` now carries move types alongside move names so the UI can render contextual coloring.
- **Modelo com metadados dos golpes**: `TMovePoolSection` agora carrega os tipos dos golpes junto com seus nomes para que a UI possa renderizar coloração contextual.
- **Stale request protection for moves**: Lazy movepool loading uses its own request token to avoid showing moves from a previously selected Pokemon.
- **Proteção contra requisições obsoletas de golpes**: O carregamento lazy do movepool usa seu próprio token de requisição para evitar exibir golpes de um Pokémon selecionado anteriormente.

## [5.6.1] - 2026-04-23

### Docs / Documentação

- **Bilingual changelog consistency**: The `5.6.0` release notes were updated so every new entry once again includes both English and Portuguese text, matching the established V5 documentation pattern.
- **Consistência bilíngue do changelog**: As notas da versão `5.6.0` foram atualizadas para que toda nova entrada volte a incluir texto em inglês e em português, seguindo o padrão de documentação já estabelecido na V5.

## [5.5.0] - 2026-04-22

### Added / Adicionado
- **Search loading state**: The search bar and main sprite panel now show an animated loading indicator while a Pokémon search is in progress, making network wait time explicit instead of looking frozen.
- **Estado de carregamento da busca**: A barra de busca e o painel principal do sprite agora exibem um indicador animado enquanto a busca do Pokémon está em andamento, deixando o tempo de espera de rede explícito em vez de parecer travado.
- **Evolution sprite loading feedback**: Evolution nodes now distinguish between loading and failure states, rendering `CARREGANDO...` while the sprite is being fetched and `SEM SPRITE` when it cannot be loaded.
- **Feedback de carregamento dos sprites de evolução**: Os nós da evolução agora distinguem estados de carregamento e falha, renderizando `CARREGANDO...` enquanto o sprite é buscado e `SEM SPRITE` quando ele não pode ser carregado.

### Changed / Alterado
- **Stats panel typography**: All text inside `TStatsPanel` now uses a unified font size (`STATS_FONT_SIZE = 9.5`) for labels, values, descriptions and defensive-effectiveness badges, creating a more consistent reading rhythm.
- **Tipografia do painel de stats**: Todo o texto dentro de `TStatsPanel` agora usa um tamanho de fonte unificado (`STATS_FONT_SIZE = 9.5`) para labels, valores, descrições e badges de efetividade defensiva, criando um ritmo visual mais consistente.
- **Loading accent color**: The loading spinner highlight now uses a Pokéball-inspired red instead of yellow, better matching the app's visual language.
- **Cor de destaque do loading**: O destaque do spinner de carregamento agora usa um vermelho inspirado em Pokébola em vez de amarelo, combinando melhor com a linguagem visual do app.

### Fixed / Corrigido
- **Infinite HTTP waits**: All relevant `TNetHTTPClient` calls now use explicit connection and response timeouts (`10000 ms`), avoiding hangs when PokeAPI or the translation endpoint becomes unavailable.
- **Espera infinita em HTTP**: Todas as chamadas relevantes de `TNetHTTPClient` agora usam timeouts explícitos de conexão e resposta (`10000 ms`), evitando travamentos quando a PokeAPI ou o endpoint de tradução ficam indisponíveis.
- **Search race condition**: Concurrent searches are now protected by a request-generation token (`FActiveSearchRequest`), so stale background responses can no longer overwrite the most recent Pokémon on screen.
- **Race condition na busca**: Buscas concorrentes agora são protegidas por um token de geração de requisição (`FActiveSearchRequest`), impedindo que respostas antigas de background sobrescrevam o Pokémon mais recente na tela.
- **Silent shiny fallback**: If a shiny sprite is missing or fails to download, the UI falls back to the normal sprite and informs the user instead of leaving stale art visible.
- **Fallback shiny silencioso**: Se um sprite shiny estiver ausente ou falhar no download, a interface volta para o sprite normal e informa o usuário em vez de deixar a arte anterior visível.
- **Oval search spinner**: The search spinner bounding box is now forced to a square rect, preventing the circular indicator from rendering as an ellipse in the search bar.
- **Spinner oval na busca**: A área de desenho do spinner da busca agora é forçada para um retângulo quadrado, impedindo que o indicador circular seja renderizado como elipse na barra de busca.

---

## [5.4.0] - 2026-04-22

### Added / Adicionado
- **Search history overlay**: Focusing the search input now opens a hoverable/clickable history overlay with recent searches, making repeated lookups faster.
- **Overlay de histórico de busca**: Focar o campo de busca agora abre um overlay com hover/click contendo buscas recentes, acelerando consultas repetidas.
- **Type filtering by badge click**: Clicking a type badge filters the navigation flow to Pokémon of that type through `GetPokemonByType`, with filtered progress reflected in the ID label.
- **Filtro por tipo via clique no badge**: Clicar em um badge de tipo filtra a navegação para Pokémon daquele tipo via `GetPokemonByType`, com o progresso do filtro refletido no label de ID.
- **Favorites system**: Added persistent favorites with toggle, favorite-mode navigation and star icons integrated into the main image panel.
- **Sistema de favoritos**: Adicionados favoritos persistidos com toggle, modo de navegação por favoritos e ícones de estrela integrados ao painel principal da imagem.

### Changed / Alterado
- **Filter/favorite context in header**: The dedicated filter label was removed; filtered context is now embedded directly in `FIdLabel` (`#025 · FIRE 3/30`, `FAV 2/8`), reducing UI clutter.
- **Contexto de filtro/favorito no cabeçalho**: O label dedicado de filtro foi removido; o contexto filtrado agora é embutido diretamente em `FIdLabel` (`#025 · FIRE 3/30`, `FAV 2/8`), reduzindo poluição visual.
- **Ability description language handling**: `GetAbilityDescription` now accepts the current language and falls back to English when the target language is unavailable.
- **Tratamento de idioma na descrição de habilidade**: `GetAbilityDescription` agora aceita o idioma atual e faz fallback para inglês quando o idioma alvo não está disponível.
- **Translation flow restored**: Locale mapping was corrected so native PokeAPI languages stay native and `pt-BR` continues to use MyMemory only as fallback.
- **Fluxo de tradução restaurado**: O mapeamento de locale foi corrigido para que idiomas nativos da PokeAPI permaneçam nativos e `pt-BR` continue usando MyMemory apenas como fallback.

### Fixed / Corrigido
- **Alternative-form contamination in type results**: Type-based search now excludes IDs above `1025`, preventing alternate forms from polluting the standard Pokédex flow.
- **Contaminação por formas alternativas nos resultados por tipo**: A busca por tipo agora exclui IDs acima de `1025`, impedindo que formas alternativas poluam o fluxo padrão da Pokédex.
- **Favorite icon guards**: Favorite UI updates now include nil-safety checks and a proper initial SVG setup for `FFavModeIcon`, avoiding inconsistent startup rendering.
- **Guards no ícone de favoritos**: As atualizações da UI de favoritos agora incluem verificações de nil e configuração inicial correta do SVG de `FFavModeIcon`, evitando renderizações inconsistentes na inicialização.
- **Repository cleanup**: IDE `__recovery` artifacts were removed from source control in this sprint branch.
- **Limpeza do repositório**: Artefatos `__recovery` da IDE foram removidos do controle de versão nesta branch da sprint.

---

## [5.3.0] - 2026-04-21

### Added / Adicionado
- **Built-in translation fallback**: Flavor text and ability descriptions can now be auto-translated through MyMemory when the system language is not natively supported by PokeAPI.
- **Fallback interno de tradução**: Flavor text e descrições de habilidade agora podem ser traduzidos automaticamente via MyMemory quando o idioma do sistema não é suportado nativamente pela PokeAPI.
- **BST total row**: The stats panel now shows a `TOTAL` row summarizing base stat total (`BST`) in the same panel.
- **Linha de total de BST**: O painel de stats agora exibe uma linha `TOTAL` resumindo o total de stats base (`BST`) no mesmo painel.
- **Defensive effectiveness header**: The merged effectiveness area gained an explicit section heading (`EFETIVIDADE DEFENSIVA`) for clearer scanning.
- **Cabeçalho de efetividade defensiva**: A área de efetividade mesclada passou a ter um cabeçalho explícito (`EFETIVIDADE DEFENSIVA`) para melhorar a leitura.

### Changed / Alterado
- **Equidistant left-panel layout**: The left column (ID, name, type badges, sprite and shiny button) was rebalanced to keep vertical spacing more even.
- **Layout equidistante no painel esquerdo**: A coluna esquerda (ID, nome, badges de tipo, sprite e botão shiny) foi reequilibrada para manter espaçamento vertical mais uniforme.
- **Type chart merged into stats panel**: Defensive type effectiveness was moved into `TStatsPanel`, eliminating the gap and redundancy of a separate panel.
- **Type chart integrado ao painel de stats**: A efetividade defensiva de tipos foi movida para `TStatsPanel`, eliminando a lacuna e redundância de um painel separado.
- **Sprite rendering path**: Main sprite rendering now uses `ISkImage`/`MakeFromEncoded` inside a single `TSkPaintBox`, which also enabled a composited Pokéball watermark without the old HWND artifact.
- **Fluxo de renderização do sprite**: A renderização do sprite principal agora usa `ISkImage`/`MakeFromEncoded` dentro de um único `TSkPaintBox`, o que também permitiu uma marca d'água de Pokébola composta sem o antigo artefato de HWND.
- **Shiny control and identity badges**: `VER SHINY` became a pill button and the Pokémon ID gained a dedicated badge treatment.
- **Controle shiny e badge de identidade**: `VER SHINY` virou um botão pill e o ID do Pokémon ganhou tratamento visual próprio de badge.
- **Evolution and type name capitalization**: Labels for evolution nodes and type names now display with normalized capitalization.
- **Capitalização de nomes de evolução e tipos**: Os labels dos nós de evolução e nomes de tipos agora exibem capitalização normalizada.

---

## [5.2.0] - 2026-04-21

### Added / Adicionado
- **Defensive type effectiveness chart**: Added type-effectiveness calculation and rendering, showing what damages the current Pokémon for 4x, 2x, 1/2x, 1/4x and 0x.
- **Chart de efetividade defensiva**: Adicionado cálculo e renderização de efetividade de tipos, mostrando o que causa dano 4x, 2x, 1/2x, 1/4x e 0x no Pokémon atual.
- **`TTypeEffect` model and controller flow**: Introduced data structures and controller logic to aggregate multipliers across one or two defensive types using PokeAPI `damage_relations`.
- **Modelo `TTypeEffect` e fluxo no controller**: Introduzidos estruturas de dados e lógica no controller para agregar multiplicadores entre um ou dois tipos defensivos usando `damage_relations` da PokeAPI.
- **Horizontal stats panel**: The old radial stats layout was replaced with horizontal bars, opening room for more textual information and type-effectiveness data.
- **Painel de stats horizontal**: O antigo layout radial de stats foi substituído por barras horizontais, abrindo espaço para mais informação textual e dados de efetividade de tipos.

### Changed / Alterado
- **Main layout polish**: The main view and stats panel were reorganized to support the new type chart and denser information layout.
- **Polimento do layout principal**: A view principal e o painel de stats foram reorganizados para suportar o novo chart de tipos e uma densidade maior de informação.
- **Service contract**: The service/controller stack now includes the extra type endpoint flow needed for effectiveness lookup.
- **Contrato de serviço**: A pilha service/controller agora inclui o fluxo extra de endpoint de tipos necessário para a consulta de efetividade.

---

## [5.1.1] - 2026-04-20

### Fixed / Corrigido
- **"VER SHINY" unreadable on light backgrounds**: The label now uses `FThemeTextColor` for its normal state (black on light backgrounds, white on dark) instead of hardcoded white. `ApplyTheme` also calls `UpdateShinyIcon` at the end so the color stays in sync when navigating between Pokémon.
- **"VER SHINY" ilegível em fundos claros**: O label agora usa `FThemeTextColor` no estado normal (preto em fundos claros, branco em escuros) em vez de branco fixo. `ApplyTheme` também chama `UpdateShinyIcon` ao final para manter a cor sincronizada ao navegar entre Pokémon.
- **Stat arcs indistinguishable on gray/dark backgrounds**: The unfilled arc opacity was raised from `$33` to `$55`. Bar color now receives a brightness boost when luminance < 200 (`Max(0, 200 − lum)` added to each RGB channel); below lum 60 gold is used, replacing the hardcoded `$FF2C2C2C` special-case in `StatsPanel`.
- **Arcos de stat indistinguíveis em fundos cinza/escuros**: A opacidade do arco vazio subiu de `$33` para `$55`. A cor da barra agora recebe boost de brilho quando luminância < 200 (`Max(0, 200 − lum)` somado a cada canal RGB); abaixo de lum 60 usa dourado, substituindo o caso especial hardcoded `$FF2C2C2C` no `StatsPanel`.
- **Unequal icon spacing**: Search bar icons (random, search, cry) are now positioned using `SEARCH_W − (ICON_PAD + ICON_SIZE) × N`, giving a uniform `ICON_PAD = 8 px` gap between all icons and edges.
- **Espaçamento desigual dos ícones**: Os ícones da barra de busca (aleatório, pesquisar, ouvir) agora são posicionados com `SEARCH_W − (ICON_PAD + ICON_SIZE) × N`, garantindo gap uniforme de `ICON_PAD = 8 px` entre todos os ícones e bordas.
- **Missing icon hints**: Added `Hint` + `ShowHint := True` to all three search bar icons: "Pokémon Aleatório", "Buscar Pokémon", "Ouvir Pokémon".
- **Hints ausentes nos ícones**: Adicionado `Hint` + `ShowHint := True` nos três ícones da barra de busca: "Pokémon Aleatório", "Buscar Pokémon", "Ouvir Pokémon".

---

## [5.1.0] - 2026-04-20

### Added / Adicionado
- **Random Pokémon Button**: A shuffle icon added to the search bar. Clicking it generates a random ID (1–1025) and loads a random Pokémon immediately.
- **Botão de Pokémon Aleatório**: Ícone de shuffle adicionado na barra de busca. Ao clicar, gera um ID aleatório (1–1025) e carrega um Pokémon aleatório imediatamente.
- **Windows Locale Flavor Text**: `GetPreferredLanguage` detects the system UI language via `GetUserDefaultLocaleName` and maps it to PokeAPI language codes (`fr`, `de`, `es`, `it`, `ja`, `ko`, `zh-Hans`, `zh-Hant`, fallback `en`). The flavor text description is now shown in the OS language when available.
- **Flavor Text no Idioma do Windows**: `GetPreferredLanguage` detecta o idioma da interface do sistema via `GetUserDefaultLocaleName` e mapeia para os códigos de idioma da PokeAPI (`fr`, `de`, `es`, `it`, `ja`, `ko`, `zh-Hans`, `zh-Hant`, fallback `en`). A descrição do flavor text agora é exibida no idioma do sistema quando disponível.

### Changed / Alterado
- **`GetDescription`**: Now accepts `ALang: string = 'en'` parameter. Iterates all entries without breaking, keeping the last match per language (most recent game version's text is used instead of the oldest).
- **`GetDescription`**: Agora aceita parâmetro `ALang: string = 'en'`. Itera todas as entradas sem interromper, mantendo a última correspondência por idioma (texto da versão de jogo mais recente é usado em vez do mais antigo).
- **`POKEMON_MAX_ID = 1025`**: Generation IX Pokémon are now included in the random pool.
- **`POKEMON_MAX_ID = 1025`**: Pokémon da Geração IX estão agora incluídos no sorteio aleatório.
- **Responsive Evolution Panel**: Sprite sizes and font sizes in the evolution panel now scale dynamically with the number of nodes. Sprite cap increases from 72 px to 96 px in horizontal mode; vertical mode uses a dynamic cap (`Max(36, 72 - leafCount×4)`). Name font size is `LImgSize × 0.20` (clamped 8–14 px); trigger font size is `LImgSize × 0.16` (clamped 8–11 px).
- **Painel de Evolução Responsivo**: Tamanhos de sprite e fonte no painel de evolução agora escalam dinamicamente com o número de nós. O cap do sprite aumenta de 72 px para 96 px no modo horizontal; o modo vertical usa um cap dinâmico (`Max(36, 72 - leafCount×4)`). O tamanho da fonte do nome é `LImgSize × 0.20` (limitado entre 8–14 px); o tamanho da fonte do gatilho é `LImgSize × 0.16` (limitado entre 8–11 px).

---

## [5.0.1] - 2026-04-20

### Fixed / Corrigido
- **Sprite centering**: `skImgPokemon` was positioned near the top of the image panel without vertical centering. New `CenterSprite` procedure positions the sprite equidistant between the type badges and the `★ VER SHINY` label, called from both `SetupLayout` and `FormResize`.
- **Centralização do sprite**: `skImgPokemon` estava posicionado no topo do painel de imagem sem centralização vertical. Nova procedure `CenterSprite` posiciona o sprite equidistante entre os badges de tipo e o label `★ VER SHINY`, chamada em `SetupLayout` e `FormResize`.
- **Next button invisible**: `btnNext` and `btnPrev` were children of `skImgPokemon` in the .dfm. After reducing the image control to `200×200 px`, `btnNext` at its original X=297 was outside the control's bounds and clipped. Both buttons are now re-parented to `pnlImage` and positioned at the sprite's left/right edges via `CenterSprite`.
- **Botão próximo invisível**: `btnNext` e `btnPrev` eram filhos de `skImgPokemon` no .dfm. Após reduzir o controle de imagem para `200×200 px`, `btnNext` na posição original X=297 ficou fora dos limites do controle e era cortado. Ambos os botões agora são re-parentados para `pnlImage` e posicionados nas bordas laterais do sprite via `CenterSprite`.
- **Shiny color on navigation**: Navigating to a new Pokémon while in shiny mode applied the species color (not the shiny dominant color). `PerformSearch` now runs `ExtractDominantColor` in the background thread whenever `FIsShiny` is true and applies the result instead of `FSpeciesColor`.
- **Cor shiny na navegação**: Navegar para um novo Pokémon em modo shiny aplicava a cor da espécie (não a cor dominante do shiny). `PerformSearch` agora executa `ExtractDominantColor` na thread de background quando `FIsShiny` é verdadeiro e aplica o resultado em vez de `FSpeciesColor`.

---

## [5.0.0] - 2026-04-20

### Added / Adicionado
- **Shiny Sprite Toggle**: A `★ VER SHINY` / `★ VER NORMAL` label (`TSkLabel`) appears at the bottom of the image panel after a successful search. Clicking it swaps the sprite between the default and shiny variants via a background download, keeping the UI responsive.
- **Toggle de Sprite Shiny**: Um label `★ VER SHINY` / `★ VER NORMAL` (`TSkLabel`) aparece na parte inferior do painel de imagem após uma busca bem-sucedida. Ao clicar, o sprite alterna entre a variante padrão e a shiny via download em background, mantendo a UI responsiva.
- **Shiny Theme Color**: When the shiny sprite is active, the dominant color is extracted directly from the sprite pixels (`ExtractDominantColor`) in the background thread and applied to the UI theme via `ApplyTheme`. Toggling back to normal restores the species color from PokeAPI (`FSpeciesColor`).
- **Cor de Tema Shiny**: Quando o sprite shiny está ativo, a cor dominante é extraída diretamente dos pixels do sprite (`ExtractDominantColor`) na thread de background e aplicada ao tema da UI via `ApplyTheme`. Ao voltar ao normal, a cor da espécie da PokeAPI é restaurada (`FSpeciesColor`).

### Changed / Alterado
- **Sprite Display Size**: `skImgPokemon` reduced from full panel width to a fixed `200×200 px` centered area (`SPRITE_SIZE = 200`), preventing the low-resolution PokeAPI sprites from looking blown up on screen.
- **Tamanho de Exibição do Sprite**: `skImgPokemon` reduzido da largura total do painel para uma área fixa de `200×200 px` centralizada (`SPRITE_SIZE = 200`), evitando que os sprites de baixa resolução da PokeAPI aparecessem exageradamente aumentados na tela.

### Fixed / Corrigido
- **Shiny Click Intercepted by Image**: `skImgPokemon` (`TWinControl`) HWND covered `FShinyLabel`'s bounds, causing every click in that region to fire `ImgPokemonMouseDown` (cry) instead of the shiny toggle. Fixed by routing inside `ImgPokemonMouseDown`: if the click coordinates fall within `FShinyLabel`'s bounds, `ShinyIconClick` is called instead of `PlayCry`.
- **Click no Shiny Interceptado pela Imagem**: O HWND de `skImgPokemon` (`TWinControl`) cobria os limites de `FShinyLabel`, fazendo com que todo clique naquela região disparasse `ImgPokemonMouseDown` (grito) em vez do toggle shiny. Corrigido com roteamento dentro de `ImgPokemonMouseDown`: se as coordenadas do click caírem dentro dos limites de `FShinyLabel`, `ShinyIconClick` é chamado no lugar de `PlayCry`.
- **Hand Cursor on Image Panel**: Removed `crHandPoint` from `skImgPokemon`, which was causing the pointer cursor to appear over the entire image panel area. The speaker icon in the search bar provides sufficient affordance for the cry interaction.
- **Cursor de Mão no Painel de Imagem**: Removido `crHandPoint` de `skImgPokemon`, que causava o aparecimento do cursor de ponteiro em toda a área do painel de imagem. O ícone de som na barra de busca já oferece indicação suficiente para a interação de grito.

---

## [4.1.0] - 2026-04-20

### Fixed / Corrigido
- **PlayCry Race Condition**: Rapid clicks on the cry button now correctly discard stale download callbacks. A generation counter (`FCryGeneration`) ensures that only the most recent download writes to `FCurrentStream`; superseded streams are freed immediately, eliminating the memory leak and double-playback.
- **Race Condition em PlayCry**: Cliques rápidos no botão de grito agora descartam corretamente callbacks de download obsoletos. Um contador de geração (`FCryGeneration`) garante que apenas o download mais recente escreva em `FCurrentStream`; streams substituídos são liberados imediatamente, eliminando o memory leak e a reprodução dupla.

### Added / Adicionado
- **Exception Hierarchy**: `EPokemonError` base class with `EPokemonNotFound`, `EPokemonNetworkError` and `EPokemonParseError` subclasses declared in `Pokedex.Service.Interfaces`. The service layer now raises typed exceptions (HTTP 404 → `EPokemonNotFound`, other non-200 / network failure → `EPokemonNetworkError`), the controller propagates them with `raise`, and the view shows distinct messages for each failure kind.
- **Hierarquia de Exceções**: Classe base `EPokemonError` com subclasses `EPokemonNotFound`, `EPokemonNetworkError` e `EPokemonParseError` declaradas em `Pokedex.Service.Interfaces`. A camada de serviço agora levanta exceções tipadas (HTTP 404 → `EPokemonNotFound`, outros não-200 / falha de rede → `EPokemonNetworkError`), o controller as propaga com `raise`, e a view exibe mensagens distintas para cada tipo de falha.

### Changed / Alterado
- **MVC: Evolution Chain Filtering**: `UpdateEvolutionChain` (previously in `TPokedexView`) extracted to `TPokemonController.FilterEvolutionChain` as a class function. The view is now a single-line call-site with no filtering logic.
- **MVC: Filtro da Cadeia Evolutiva**: `UpdateEvolutionChain` (anteriormente em `TPokedexView`) extraído para `TPokemonController.FilterEvolutionChain` como class function. A view ficou como um call-site de uma linha, sem lógica de filtragem.
- **MVC: Service Injection**: `TPokedexView` no longer references `TdmPokeService` or `Pokedex.Service.API` directly. A new public `Initialize(AService: IPokemonService)` method receives the service via interface injection. `Pokedex.dpr` wires the two after `Application.CreateForm`.
- **MVC: Injeção de Serviço**: `TPokedexView` não referencia mais `TdmPokeService` nem `Pokedex.Service.API` diretamente. Um novo método público `Initialize(AService: IPokemonService)` recebe o serviço via injeção de interface. O `Pokedex.dpr` conecta os dois após `Application.CreateForm`.
- **Service Deduplication**: Three identical HTTP methods (`GetPokemonJSON`, `GetSpeciesJSON`, `GetEvolutionChainJSON`) collapsed into a single private `DoGet(AUrl)` helper.
- **Deduplicação do Service**: Três métodos HTTP idênticos (`GetPokemonJSON`, `GetSpeciesJSON`, `GetEvolutionChainJSON`) consolidados em um único helper privado `DoGet(AUrl)`.
- **Comment Cleanup**: Removed all comments describing *what* the code does. Retained only comments explaining non-obvious constraints (Skia line-wrap invariant, `EInvalidCast` on `TJSONNull`, baseline formula), PokeAPI contract quirks (nullable fields, `evolves_to` schema), magic-number documentation for layout constants, and the swallowed-exception rationale.
- **Limpeza de Comentários**: Removidos todos os comentários que descrevem *o que* o código faz. Mantidos apenas comentários que explicam restrições não óbvias (invariante de quebra de linha do Skia, `EInvalidCast` em `TJSONNull`, fórmula de baseline), quirks do contrato da PokeAPI (campos nullable, schema do `evolves_to`), documentação de números mágicos de layout e a justificativa da exceção suprimida.

---

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
