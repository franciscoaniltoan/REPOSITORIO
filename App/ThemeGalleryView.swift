import SwiftUI

/// Same 48/52 card split, aligned top edges and compact card heights as the
/// approved Android 0.5.50 UI. Color samples are four equal-sized squares.
struct ThemeGalleryView: View {
    @EnvironmentObject private var store: AuraThemeStore

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment:.leading,spacing:14) {
                        appearancePicker
                        ForEach(AuraCategory.allCases,id:\.self) { category in
                            VStack(alignment:.leading,spacing:10) {
                                Text(category.rawValue.uppercased())
                                    .font(.system(size:11,weight:.bold))
                                    .tracking(2.2)
                                    .foregroundStyle(AuraStyle.secondary)
                                    .padding(.leading,5)
                                    .padding(.top,12)
                                ForEach(AuraCatalog.themes.filter { $0.category == category }) { theme in
                                    ThemeCardView(
                                        theme:theme,
                                        palette:AuraCatalog.palette(for:theme.id,appearance:store.appearance),
                                        isSelected:store.selectedThemeID == theme.id,
                                        availableWidth:max(270,geometry.size.width - 36)
                                    ) { store.selectedThemeID = theme.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal,18)
                    .padding(.bottom,20)
                }
            }
            .background(AuraStyle.background)
            .navigationTitle("Temas")
        }
    }

    private var appearancePicker: some View {
        VStack(alignment:.leading,spacing:8) {
            Text("APARÊNCIA")
                .font(.system(size:11,weight:.bold))
                .tracking(2).foregroundStyle(AuraStyle.secondary)
            Picker("Aparência",selection:$store.appearance) {
                ForEach(AuraAppearance.allCases,id:\.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.top,8)
    }
}

struct ThemeCardView: View {
    let theme: AuraTheme
    let palette: AuraPalette
    let isSelected: Bool
    let availableWidth: CGFloat
    let select: () -> Void

    private var previewWidth: CGFloat { (availableWidth - 16 - 8) * 0.48 }
    private var detailsWidth: CGFloat { (availableWidth - 16 - 8) * 0.52 }
    private var previewHeight: CGFloat { max(72,min(132,previewWidth*222/320)) }
    private var contentHeight: CGFloat { max(103,previewHeight) }

    var body: some View {
        Button(action:select) {
            HStack(alignment:.top,spacing:8) {
                KeyboardMiniature(palette:palette)
                    .frame(width:previewWidth,height:previewHeight,alignment:.top)
                    .clipped()
                VStack(alignment:.leading,spacing:0) {
                    HStack(spacing:4) {
                        Text(theme.name)
                            .font(.system(size:16,weight:.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(palette.background.isDark ? Color.white : AuraStyle.text)
                            .frame(maxWidth:.infinity,alignment:.leading)
                        Image(systemName:isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size:22,weight:.medium))
                            .foregroundStyle(isSelected ? Color(red:86/255,green:137/255,blue:228/255) : AuraStyle.secondary)
                    }
                    .padding(.horizontal,8)
                    .frame(height:35)
                    .background(Color(rgb:palette.background),in:RoundedRectangle(cornerRadius:11))

                    HStack(spacing:6) {
                        ThemeIdentityArt(theme: theme)
                            .frame(width: min(40,detailsWidth * 0.27),height:54)
                            .background(Color(rgb:palette.background).opacity(0.38),in:RoundedRectangle(cornerRadius:9))
                        Rectangle()
                            .fill(AuraStyle.secondary.opacity(0.5))
                            .frame(width:1,height:56)
                        HStack(spacing:3) {
                            ForEach([palette.background,palette.key,palette.action,palette.ink],id:\.self) { color in
                                RoundedRectangle(cornerRadius:5)
                                    .fill(Color(rgb:color))
                                    .overlay(RoundedRectangle(cornerRadius:5).stroke(Color.gray.opacity(0.14),lineWidth:0.6))
                                    .aspectRatio(1,contentMode:.fit)
                            }
                        }
                        .frame(maxWidth:.infinity)
                    }
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.center)
                }
                .frame(width:detailsWidth,height:contentHeight,alignment:.top)
            }
            .padding(8)
            .frame(width:availableWidth,height:contentHeight+16,alignment:.topLeading)
            .background(.white,in:RoundedRectangle(cornerRadius:19))
            .overlay {
                RoundedRectangle(cornerRadius:19)
                    .stroke(isSelected ? AuraStyle.selectedBorder : Color.gray.opacity(0.12),lineWidth:isSelected ? 1.7 : 0.7)
            }
            .shadow(color:.black.opacity(0.04),radius:7,y:2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tema \(theme.name) \(isSelected ? "selecionado" : "não selecionado")")
    }
}
