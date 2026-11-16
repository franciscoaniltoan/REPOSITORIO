import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AuraThemeStore
    // Only for automated simulator screenshots; normal launches open Início.
    @State private var selectedTab = ProcessInfo.processInfo.arguments.contains("--aurabr-visual-fruits") ? 1 : 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Início", systemImage:"house") }
                .tag(0)
            ThemeGalleryView()
                .tabItem { Label("Temas", systemImage:"paintpalette") }
                .tag(1)
            SettingsView()
                .tabItem { Label("Ajustes", systemImage:"gearshape") }
                .tag(2)
        }
        .tint(AuraStyle.accent)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var store: AuraThemeStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading, spacing:18) {
                    VStack(alignment:.leading, spacing:2) {
                        Text("Seu teclado.").font(.system(size:30,weight:.bold))
                        HStack {
                            Spacer()
                            Text("Do seu jeito.").font(.system(size:30,weight:.bold))
                        }
                    }
                    .foregroundStyle(AuraStyle.text)
                    .padding(.top,12)

                    Text("TEMA ATUAL")
                        .font(.caption.weight(.bold)).tracking(2)
                        .foregroundStyle(AuraStyle.secondary)
                    VStack(alignment:.leading,spacing:12) {
                        HStack {
                            ThemeIdentityArt(theme: store.selectedTheme).frame(width:30,height:30)
                            Text(store.selectedTheme.name).font(.headline)
                            Spacer()
                            Text(store.appearance.rawValue).font(.caption).foregroundStyle(AuraStyle.secondary)
                        }
                        KeyboardMiniature(palette:store.selectedPalette)
                            .aspectRatio(320/222,contentMode:.fit)
                    }
                    .padding(16)
                    .background(.white,in:RoundedRectangle(cornerRadius:20))
                    Text("SEU TECLADO, SEU JEITO")
                        .font(.caption.weight(.semibold)).tracking(1.5)
                        .foregroundStyle(AuraStyle.secondary)
                    Text("Uma identidade familiar, agora com um teclado próprio para iPhone. Esta é a primeira versão funcional para desenvolvimento e testes.")
                        .font(.subheadline).foregroundStyle(AuraStyle.secondary)
                }
                .padding(18)
            }
            .background(AuraStyle.background)
            .navigationTitle("AuraBR")
        }
    }
}

private struct SettingsView: View {
    @State private var sampleText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:16) {
                    Label("Ativar o teclado AuraBR",systemImage:"keyboard")
                        .font(.title3.bold())
                    Text("1. Abra Ajustes do iPhone.")
                    Text("2. Vá até Geral → Teclado → Teclados.")
                    Text("3. Escolha Adicionar Novo Teclado → AuraBR.")
                    Text("4. Use o controle de troca de teclado do iOS para ativar o AuraBR ao digitar.")
                    Text("O iOS pode mostrar o globo na barra inferior em vez de dentro do teclado.")
                        .font(.footnote)
                        .foregroundStyle(AuraStyle.secondary)
                    #if AURABR_FREE_PERSONAL
                    Text("Versão gratuita para desenvolvimento: escolha cores no próprio teclado pelos controles 🎨 (tema) e ◐ (Claro / Glass / Escuro). A galeria deste aplicativo serve como prévia; sem App Group, a seleção não é compartilhada com o teclado e os controles reiniciam quando o iOS recria a extensão.")
                        .font(.footnote)
                        .foregroundStyle(AuraStyle.secondary)
                    #endif
                    Divider()
                    Label("Experimente a digitação", systemImage:"text.cursor")
                        .font(.headline)
                    Text("Depois de ativar o AuraBR em Ajustes, toque no campo abaixo e selecione-o no controle de teclado do iOS.")
                        .font(.subheadline)
                        .foregroundStyle(AuraStyle.secondary)
                    TextField("Digite uma mensagem em português...", text:$sampleText,axis:.vertical)
                        .lineLimit(2...4)
                        .padding(12)
                        .background(AuraStyle.background,in:RoundedRectangle(cornerRadius:12))
                        .accessibilityIdentifier("aurabr.testInput")
                    Divider()
                    Label("Privacidade desde a primeira versão",systemImage:"lock.shield")
                        .font(.headline)
                    #if AURABR_FREE_PERSONAL
                    Text("A extensão funciona offline, sem Acesso Total, rede ou App Group. Os controles de aparência atuam apenas na sessão atual do teclado.")
                    #else
                    Text("A extensão solicita RequestsOpenAccess = false, não transmite digitação pela internet e usa um pequeno vocabulário local de exemplo. O aplicativo grava as preferências de tema e o teclado as lê do App Group, sem pedir Acesso Total.")
                    #endif
                    Divider()
                    Text("Compatibilidade inicial: iOS 17 ou superior. O iOS pode substituir teclados de terceiros em campos de senha, alguns campos telefônicos ou aplicativos que os bloqueiam.")
                        .font(.footnote)
                        .foregroundStyle(AuraStyle.secondary)
                }
                .padding(20)
                .frame(maxWidth:.infinity,alignment:.leading)
                .background(.white,in:RoundedRectangle(cornerRadius:20))
                .padding(16)
            }
            .background(AuraStyle.background)
            .navigationTitle("Ajustes")
        }
    }
}
