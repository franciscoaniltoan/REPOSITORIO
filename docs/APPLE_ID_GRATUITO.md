# AuraBR iOS gratuito — guia do Apple ID Personal Team

Este projeto separa **compilação grátis de simulador pelo GitHub** de **instalação em iPhone usando Xcode e um Apple ID gratuito**. Não é TestFlight, App Store ou distribuição de um IPA para terceiros.

## 1. O que está disponível sem pagar à Apple

- Projeto completo: `project.yml`. Mantém App Groups para desenvolvimento futuro com os recursos correspondentes.
- **Projeto de uso pessoal:** `project-free.yml`. App `com.aurabr.ios.free` e extensão `com.aurabr.ios.free.keyboard`, sem `CODE_SIGN_ENTITLEMENTS`/App Groups.
- Ambos usam os mesmos fontes, cores, 23 temas e teclado iOS com sugestões PT-BR iniciais.
- `.github/workflows/ios-free.yml` gera um ZIP de **simulador apenas**, não assinado para dispositivo real. O arquivo fica temporariamente nos artefatos da execução do Actions.

## 2. Instalar em iPhone próprio gratuitamente (precisa de um Mac)

1. Instale o **Xcode** e o **XcodeGen** num Mac; Xcode pode ser baixado na Mac App Store. No Terminal, `brew install xcodegen`.
2. Clone `https://github.com/franciscoaniltoan/REPOSITORIO.git`, entre na pasta e execute `xcodegen generate --spec project-free.yml`.
3. Abra `AuraBRiOSFree.xcodeproj` no Xcode.
4. Em **Signing & Capabilities**, escolha **Automatically manage signing** e o seu Apple ID sob **Personal Team** para **AuraBR** e **AuraBRKeyboard**. Se o Xcode solicitar, ajuste os identificadores dos dois alvos em `project-free.yml` para valores exclusivos, mantendo a extensão como sufixo `.keyboard`; gere o projeto novamente.
5. Conecte seu iPhone ao Mac, autorize a conexão, habilite o **Modo de Desenvolvedor** no iPhone se o sistema pedir, selecione o iPhone no Xcode e clique em **Run (▶)**.
6. Depois da instalação, no iPhone abra **Ajustes → Geral → Teclado → Teclados → Adicionar Novo Teclado → AuraBR**. Teste no campo de digitação em Ajustes do aplicativo.
7. Ao expirar o provisionamento gratuito (normalmente **7 dias**), execute novamente o aplicativo pelo Xcode. É uma limitação da Apple, não do AuraBR.

Não envie senha, token, certificados nem o Apple ID ao GitHub. A assinatura da Personal Team ocorre localmente no Xcode.

## 3. Temas na edição gratuita

A App Gallery mostra todos os temas e salva a seleção **no próprio aplicativo**. Sem um App Group assinado, o teclado não consegue receber automaticamente essa escolha.

Para permitir testar todas as cores sem pagar, o teclado em execução traz dois controles próprios na barra superior:
- **🎨**: próximo tema (percorre os 23 temas);
- **◐**: alterna **Claro → Glass → Escuro**.

Essas escolhas são **temporárias**, válidas enquanto o iOS mantém aquela instância do teclado. Ao recriá-la, o sistema volta ao Morango Claro. Não é possível prometer sincronização persistente nem identidade de comportamento da versão completa sem testes reais.

O teclado segue **offline**, com `RequestsOpenAccess=false`; não pede acesso à rede nem ao conteúdo de outros aplicativos.

## 4. O que a opção gratuita não faz

- Não gera IPA de distribuição para terceiros nem publica no **TestFlight/App Store**.
- Não substitui uma validação presencial do teclado em iPhone real (ex.: Notas, Safari, WhatsApp, rotação, campo seguro, emojis, corretor).
- Não permite usar as mesmas permissões de App Groups para sincronizar automaticamente tema entre os dois processos na configuração Personal Team.
- Não torna o motor inicial de sugestões equivalente ao AuraBR Android.

## 5. CI e verificação

- No GitHub: **Actions → AuraBR iOS · modo gratuito Personal Team**.
- Os testes Swift e o validador de permissões executam em Ubuntu; o Xcode cria o app e a extensão para **simulador** em um runner macOS.
- Para continuar o desenvolvimento normal, use `project.yml`. Para testar em iPhone com Apple ID gratuito, gere `project-free.yml`.

Fontes:
- https://developer.apple.com/help/account/basics/about-your-developer-account
- https://developer.apple.com/help/account/reference/supported-capabilities-ios/
- https://developer.apple.com/help/account/membership/programs-overview/
