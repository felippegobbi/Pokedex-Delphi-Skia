# Changelog

All notable changes to this project will be documented in this file.
Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

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