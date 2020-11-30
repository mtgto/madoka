import Cocoa

let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.google.Chrome")
let image = NSWorkspace.shared.icon(forFile: path!)
