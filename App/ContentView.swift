import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AuraThemeStore
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Início", systemImage:"house") }
            ThemeGalleryView()
                .tabItem { Label("Temas", systemImage:"paintpalette") }
            SettingsView()
                .tabItem { Label("Ajustes", systemImage:"gearshape") }
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
                            Text(store.selectedTheme.emoji).font(.title2)
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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:16) {
                    Label("Ativar o teclado AuraBR",systemImage:"keyboard")
                        .font(.title3.bold())
                    Text("1. Abra Ajustes do iPhone.")
                    Text("2. Vá até Geral → Teclado → Teclados.")
                    Text("3. Escolha Adicionar Novo Teclado → AuraBR.")
                    Text("4. Use o botão de globo para alternar para AuraBR ao digitar.")
                    Divider()
                    Label("Privacidade desde a primeira versão",systemImage:"lock.shield")
                        .font(.headline)
                    Text("A extensão solicita RequestsOpenAccess = false, não transmite digitação pela internet e usa um pequeno vocabulário local de exemplo. Configurações de tema são lidas do App Group.")
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
