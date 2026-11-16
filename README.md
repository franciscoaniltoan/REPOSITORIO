# AuraBR iOS

Versão inicial **nativa de iOS** da identidade visual aprovada do AuraBR Android **v0.5.50**, desenvolvida independentemente do repositório Android.

## Estado

- Galeria de **23 temas**: Clássicos/Pastéis, Pedras preciosas e Frutas, com modo Claro, Glass e Escuro.
- Melancia rosa/verde e Morango rosa/cacau com paletas separadas; cards compactos **48%/52%** e miniatura/cápsula alinhados no topo.
- Teclado iOS nativo inicial (`UIInputViewController`) com letras, Shift, Backspace, Enter, símbolos, emoji, tecla de troca de teclado e pequenas sugestões **offline** em PT-BR.
- App iOS em SwiftUI; extensão em UIKit; núcleo em Swift puro testável no Linux/macOS.
- **Protótipo**, não equivalência funcional ao corretor contextual do Android. Digitação e apresentação precisam de testes em simulador e iPhone.

## Compilar sem Mac local

O GitHub Actions usa macOS e Xcode para testes e uma build para **simulador**. Não é um IPA assinado nem distribuição via TestFlight. O projeto Xcode é gerado pelo `XcodeGen` a partir de `project.yml`:

```bash
brew install xcodegen
xcodegen generate
swift test
xcodebuild -project AuraBRiOS.xcodeproj -scheme AuraBR -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

A publicação no iPhone exigirá Apple Developer e assinaturas/capacidades App Group configuradas na conta Apple, além da configuração do TestFlight.

## Privacidade e limitações

`RequestsOpenAccess=false`: a extensão **não solicita Full Access** e não possui código de rede. A seleção de temas é salva no App Group pela aplicação; se o sistema negar leitura compartilhada ao teclado, ele permanece funcional no tema padrão Morango. A integração universal dos temas será validada em iPhone e poderá depender de uma opção de sincronização sujeita à permissão do usuário. **Não ativar Full Access silenciosamente**.

O iOS pode trocar para seu teclado padrão em senhas e outros campos protegidos. O teclado deve sempre disponibilizar a troca de método de entrada.

## Referência do Android

Somente a aparência e os valores de temas foram replicados. O pacote Android `com.aurakeyboard.br`, o motor Java/C++, os dicionários e o APK **não são utilizados no iOS**. IDs estáveis das 23 cores foram transportados para `Sources/AuraBRCore/Theme.swift`.

## Organização

- `App/`: tela inicial, galeria de temas, miniatura e controles de aparência.
- `KeyboardExtension/`: teclado nativo (extensão iOS) e `Info.plist`.
- `Sources/AuraBRCore/`: modelos e paletas portáteis, sugestões offline básicas.
- `Tests/`: regressões das cores, IDs e sugestões.
- `project.yml`: definição reproduzível do projeto Xcode.
- `.github/workflows/ios.yml`: testes e build de simulador em macOS.

Código inicial livre de chaves, certificados e dados de digitação. Ainda é necessário revisar propriedades e comportamentos no Xcode antes de enviar à App Store.

## Próxima evolução: digitação PT-BR e compilação do simulador

- Contexto Unicode limitado à palavra atual, sem capturar ou persistir frases.
- Sugestões offline mantêm acentos e capitalização (Na → Não; NA → NÃO).
- Testes Swift adicionais em `TextContextTests.swift`.
- O workflow permite alternar runners `macos-15-intel`, `macos-15` e `macos-26`, cancela jobs antigos do mesmo branch e publica ZIP do app de simulador **apenas se o Xcode compilar**.
- Limitação: a seleção de temas no teclado deve ser comprovada em iPhone; a extensão só possui acesso de leitura ao App Group em modo restrito. `RequestsOpenAccess` permanece `false`, sem conexão de rede.
- Enquanto o job macOS não for executado e aprovado, o projeto é um protótipo de código e **não** um IPA para instalação física.

## Fidelidade visual — ícones de frutas do Android v0.5.50

O iOS usa os **cinco PNGs aprovados** de Banana, Melancia, Morango, Kiwi e Uva,
reutilizados sem modificação do AuraBR Android. As imagens estão em
`App/Assets.xcassets` (128×128, transparência original) e são utilizadas
na galeria de temas e na tela inicial. O teste
`scripts/validate_fruit_assets.py` confere o hash Git, a dimensão PNG,
os metadados Xcode e os IDs das frutas. Outros ícones continuam provisórios
até serem convertidos com fidelidade.

## Usar sem pagar Apple Developer (Personal Team)

A configuração **gratuita** de desenvolvimento está em `project-free.yml`, independente de `project.yml`, sem App Group e sem assinatura de distribuição. É possível compilar e gerar ZIP de **simulador** pelo GitHub Actions (`.github/workflows/ios-free.yml`).

Para instalar em um **iPhone próprio**, é necessário um Mac com Xcode e um Apple ID gratuito configurado como Personal Team. A assinatura de desenvolvimento expira após 7 dias e precisa ser refeita no Xcode. **Não há TestFlight, IPA para terceiros nem App Store** nessa opção.

No teclado gratuito, os botões **🎨** (tema) e **◐** (aparência) permitem experimentar as 23 cores no próprio teclado, sem sincronização com a galeria ou persistência entre reinícios da extensão. Isso mantém o teclado offline e evita permissões indisponíveis na conta gratuita.

**[Passo a passo completo de instalação gratuita](docs/APPLE_ID_GRATUITO.md).**
