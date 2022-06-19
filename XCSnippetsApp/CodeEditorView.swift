import CodeEditor
import SwiftUI

struct CodeEditorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var content: String
    var body: some View {
        CodeEditor(source: $content, language: .swift, theme: colorScheme == .dark ? .init(rawValue: "monokai-sublime") : .init(rawValue: "xcode"))
    }
}

struct CodeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CodeEditorView(content: .constant("let hello = \"World\""))
    }
}
