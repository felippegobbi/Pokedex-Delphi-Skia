# Pokédex Delphi Skia

Uma Pokédex moderna construída em **Delphi 12** com renderização vetorial via **Skia4Delphi**, consumo da **PokeAPI** e áudio nativo via **BASS**.

A modern Pokédex built with **Delphi 12**, vector rendering via **Skia4Delphi**, **PokeAPI** integration, and native audio via **BASS**.

---

## Funcionalidades / Features

- **Busca** por nome ou ID do Pokémon / **Search** by name or ID
- **Tema dinâmico** — cor de fundo muda conforme a espécie / **Dynamic theme** — background color changes per species
- **Sprites oficiais** baixados em tempo real / **Official sprites** downloaded at runtime
- **Grito do Pokémon** — clique no sprite ou no ícone de som para ouvir o cry oficial / **Pokémon cry** — click the sprite or speaker icon to play the official cry
- **Painel de stats** com arcos circulares Skia / **Stats panel** with Skia circular arcs
- **Cadeia evolutiva completa** com ramificações (ex.: todas as evoluções do Eevee) e gatilhos de evolução (nível, amizade, item, troca, etc.) / **Full evolution tree** with branching chains (e.g. all Eevee evolutions) and evolution triggers (level, friendship, item, trade, etc.)
- **Busca assíncrona** — interface nunca trava durante requisições de rede / **Async search** — UI never freezes during network requests
- **Tipos, peso, altura e habilidades** do Pokémon / Pokémon **types, weight, height and abilities**

---

## Stack

| Componente | Tecnologia |
|---|---|
| Linguagem | Delphi 12 (Object Pascal) |
| Renderização gráfica | [Skia4Delphi](https://github.com/skia4delphi/skia4delphi) |
| HTTP | `TNetHTTPClient` (System.Net) |
| JSON | `REST.Json` + `System.JSON` |
| Áudio / Audio | [BASS](https://www.un4seen.com) (`bass.dll`) |
| API | [PokeAPI v2](https://pokeapi.co) |
| Fonte / Font | [Montserrat](https://fonts.google.com/specimen/Montserrat) *(opcional / optional)* |

---

## Arquitetura / Architecture

```
src/
├── Model/      TPokemon, TPokemonSpecies, TEvolutionNode, TEvolutionTrigger, ...
├── Controller/ TPokemonController — lógica de negócio, parsing JSON, URLs
├── Service/    TdmPokeService (IPokemonService) — camada HTTP
├── View/       TPokedexView, TStatsPanel, TEvolutionPanel
└── Audio/      Pokedex.Audio.Bass — bindings externos da bass.dll
```

Padrão **MVC** com injeção de dependência via interface `IPokemonService`.

---

## Dependências / Dependencies

### Skia4Delphi
Instale o pacote **Skia4Delphi** no RAD Studio antes de compilar.  
Install the **Skia4Delphi** package in RAD Studio before compiling.  
→ https://github.com/skia4delphi/skia4delphi

### BASS audio library (`bass.dll`)
Necessária para reprodução dos gritos dos Pokémon.  
Required for Pokémon cry audio playback.

1. Baixe / Download: https://www.un4seen.com → **BASS** (versão Windows / Windows build)
2. Copie `bass.dll` para a mesma pasta do executável compilado (`Win32/Debug/` ou `Win32/Release/`)  
   Copy `bass.dll` to the same folder as the compiled executable (`Win32/Debug/` or `Win32/Release/`)

> A DLL é gratuita para uso não-comercial / The DLL is free for non-commercial use.

### Fonte Montserrat *(opcional / optional)*
Se a fonte **Montserrat** estiver instalada no sistema, ela será usada automaticamente. Caso contrário, o app usa **Segoe UI** como fallback.  
If **Montserrat** is installed on the system it will be used automatically. Otherwise the app falls back to **Segoe UI**.  
→ https://fonts.google.com/specimen/Montserrat

---

## Como rodar / How to run

```bash
git clone https://github.com/felippegobbi/Pokedex-Delphi-Skia.git
```

1. Instale o **Skia4Delphi** no RAD Studio / Install **Skia4Delphi** in RAD Studio
2. Coloque `bass.dll` na pasta de saída do compilador / Place `bass.dll` in the compiler output folder
3. Abra `Pokedex.dproj` e compile / Open `Pokedex.dproj` and compile
4. Execute — o Bulbasaur carrega automaticamente / Run — Bulbasaur loads automatically

---

## Changelog

Veja [CHANGELOG.md](CHANGELOG.md) para o histórico completo de versões.  
See [CHANGELOG.md](CHANGELOG.md) for the full version history.
