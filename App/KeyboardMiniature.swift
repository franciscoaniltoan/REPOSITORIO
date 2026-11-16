import SwiftUI

/// The iOS gallery preview shares design tokens with the real extension.
/// Draws all rows in 320x222 coordinates to stay proportional at any width.
struct KeyboardMiniature: View {
    let palette: AuraPalette

    var body: some View {
        Canvas { graphics,size in
            var canvas = graphics
            let scale = min(size.width/320,size.height/222)
            guard scale > 0 else { return }
            canvas.translateBy(x:(size.width-320*scale)/2,y:(size.height-222*scale)/2)
            canvas.scaleBy(x:scale,y:scale)
            let background = Path(roundedRect:CGRect(x:0,y:0,width:320,height:222),cornerRadius:12)
            canvas.fill(background,with:.linearGradient(
                Gradient(colors:[Color(rgb:palette.backgroundStart),Color(rgb:palette.backgroundEnd)]),
                startPoint:CGPoint(x:0,y:0),endPoint:CGPoint(x:320,y:0)))

            // Suggestion strip: no fake clipboard on miniature.
            for (i,word) in ["bom","dia","pessoal"].enumerated() {
                canvas.draw(Text(word).font(.system(size:11,weight:.medium)).foregroundColor(Color(rgb:palette.ink)),
                            at:CGPoint(x:53+i*107,y:16))
                if i<2 {
                    var line=Path()
                    line.move(to:CGPoint(x:107+i*107,y:7))
                    line.addLine(to:CGPoint(x:107+i*107,y:26))
                    canvas.stroke(line,with:.color(Color(rgb:palette.ink).opacity(0.12)),lineWidth:1)
                }
            }
            drawLetters("QWERTYUIOP",y:35,offset:7,width:26,gap:5,canvas:&canvas)
            drawLetters("ASDFGHJKL",y:80,offset:22,width:26,gap:5,canvas:&canvas)
            drawKey("⇧",x:5,y:125,w:35,h:40,action:true,canvas:&canvas)
            drawLetters("ZXCVBNM",y:125,offset:44,width:30,gap:5,canvas:&canvas)
            drawKey("⌫",x:290,y:125,w:25,h:40,action:true,canvas:&canvas)
            drawKey("123",x:5,y:173,w:48,h:39,action:true,canvas:&canvas)
            drawKey("☺",x:58,y:173,w:38,h:39,action:true,canvas:&canvas)
            drawKey("PT EN",x:102,y:173,w:157,h:39,action:false,canvas:&canvas)
            drawKey("↵",x:265,y:173,w:50,h:39,action:true,canvas:&canvas)
        }
        .accessibilityHidden(true)
    }

    private func drawLetters(_ letters:String,y:CGFloat,offset:CGFloat,width:CGFloat,gap:CGFloat,
                             canvas:inout GraphicsContext) {
        for (index,char) in letters.enumerated() {
            drawKey(String(char),x:offset+CGFloat(index)*(width+gap),y:y,w:width,h:39,action:false,canvas:&canvas)
        }
    }

    private func drawKey(_ text:String,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,action:Bool,
                         canvas:inout GraphicsContext) {
        let rect=CGRect(x:x,y:y,width:w,height:h)
        let path=Path(roundedRect:rect,cornerRadius:7)
        canvas.fill(path,with:.color(Color(rgb:action ? palette.action : palette.key).opacity(palette.glass ? 0.88 : 1)))
        canvas.stroke(path,with:.color(Color.white.opacity(0.55)),lineWidth:0.8)
        let labelInk=action ? palette.actionInk : palette.keyInk
        canvas.draw(Text(text).font(.system(size:text=="PT EN" ? 8 : 13,weight:.medium))
            .foregroundColor(Color(rgb:labelInk)),at:CGPoint(x:rect.midX,y:rect.midY))
    }
}
