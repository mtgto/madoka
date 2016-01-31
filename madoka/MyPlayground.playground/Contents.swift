import Cocoa

let app = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.apple.finder")

app[0].localizedName

String(format: "%2.0f%%", 1.0)

let bundle = NSBundle(identifier: "com.culturedcode.things")

let things: String = NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier("com.culturedcode.things")!

NSFileManager.defaultManager().displayNameAtPath(things)
