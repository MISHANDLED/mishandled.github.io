---
title: 'How We Shrank the Zomato Merchant App from 197 MB to 117 MB'
description: 'Compiler flags, static linking, symbol stripping, and deleting what we did not need: the checklist behind a 41% smaller iOS app, with the traps that hide the savings.'
publicationDate: '2026-10-12'
---

The Zomato merchant app is what restaurants use to accept and manage orders. Many of them run it on older, low-storage phones over slow networks, so every extra megabyte means a slower install, a failed update, or a restaurant that stays on an old version.

Over a few months, we cut the iOS app from **197 MB to 117 MB**, 41% smaller, and the work is still going. There was no single big win. Some changes saved megabytes, some saved kilobytes, and the biggest lesson was that build settings lie more often than you expect.

## The app

Most of these fixes only make sense once you know how the app is built, so here is a short overview.

- **One app, many local packages.** The app target itself is thin. Most features, the design system, networking, analytics, and shared models are in dozens of local Swift packages, built from source with Swift Package Manager.
- **Shared with other apps.** Many of these packages are also used by Zomato's other iOS apps. A change to a package affects more than one app, and a package can bring code, assets, and languages that only another app needs.
- **Mostly dynamic.** Most packages were built as dynamic frameworks and embedded in the app, so the app shipped with dozens of frameworks, each with its own binary.
- **Swift and Objective-C.** It is mostly Swift, with older Objective-C code and a few third-party SDKs for things like analytics and support chat.
- **Extensions.** Besides the app, it has a widget with Live Activities, a notification service extension, and a share extension. Each is a separate binary with its own dependencies.
- **Years of features.** The app has grown for years. Some flows were replaced but never removed, and some dependencies stayed after the feature that needed them was gone.

This is why the app was big, and why the usual advice was not enough. The build settings that make an app small are set on the app target, but most of the code is in packages that do not read them. And a package that is shared between apps cannot simply be changed for one of them.

This is the checklist I wish I had at the start, roughly in order of impact.

## 1. Delete what nobody runs

Before you tune anything, remove what should not ship at all: unreachable flows, old screens, unused views, and dependencies that only one forgotten file still imports.

Guessing what is unused does not scale. Build a file-level reachability graph instead. Start at `@main`, the resources, and the test targets, and mark everything they reach. What is left is a candidate for deletion.

The graph has blind spots. Some code is loaded by the system, not by your code, so nothing references it. App Shortcuts intents and Core Data migration policies are two examples. Check every candidate before you delete it.

**Trap:** a debug-only tool whose call sites are all inside `#if DEBUG` can still be linked into every build. Its type metadata alone can cost megabytes in Release. Gating the call sites is not enough. Remove the dependency from Release builds too.

## 2. Make the compiler optimize for size

Most apps are compiled to be fast, not small. For Release:

```
SWIFT_OPTIMIZATION_LEVEL = -Osize
SWIFT_COMPILATION_MODE   = wholemodule
GCC_OPTIMIZATION_LEVEL   = z
LLVM_LTO                 = YES

OTHER_SWIFT_FLAGS = -Xllvm -enable-machine-outliner
OTHER_CFLAGS      = -mllvm -enable-machine-outliner
OTHER_LDFLAGS     = -Wl,-mllvm,-enable-machine-outliner
```

The machine outliner finds identical instruction sequences across functions and replaces them with calls to one shared copy. A large app has a lot of repeated code. The linker needs the flag too, as link-time optimization moves code generation for C and Objective-C to the linker.

Swift packages do not read your app's `.xcconfig`. Set release-only `unsafeFlags` or `swiftSettings` in each package, including `-dead_strip` and `-dead_strip_dylibs` for the linker.

Expect a high single-digit percentage off the compiled code. Crash reports still symbolicate fine with outlined functions, but confirm it with a test crash before you ship.

### Check what the build really uses

A target that sets `OTHER_LDFLAGS = -ObjC` **without** `$(inherited)` silently drops every linker flag from the `.xcconfig`. The settings look right in the file and do nothing in the build. Check the resolved values with `xcodebuild -showBuildSettings`, not the file you edited.

### What not to turn on

`SWIFT_REFLECTION_METADATA_LEVEL = none` saves space, but it breaks string interpolation of enums, `String(describing:)`, and `Mirror`. These are behavior changes that tests rarely catch.

## 3. Fewer dynamic frameworks

Each embedded dynamic framework has a cost: its own Mach-O overhead, its own copy of some runtime data, and work for the dynamic loader at every launch.

The rule: **only make a package static if the app is its only consumer.** If a shared package becomes static, its code is copied into every dynamic framework that uses it, and the app gets bigger, not smaller.

Draw the dependency graph of your packages first, and find the leaves. Make those `type: .static`, and remove them from the Embed Frameworks phase. After each change, check that no Objective-C class or Swift module ends up in two binaries. The runtime warns about duplicate classes, and the behavior is undefined.

Do not convert interdependent packages all at once. It tends to fail with duplicate symbols at link time, and the error does not tell you which package to undo.

Mergeable Libraries look like the answer, but Apple supports them for prebuilt XCFrameworks, not Swift packages built from source.

## 4. Strip the symbols that slip through

Release builds should already strip:

```
DEPLOYMENT_POSTPROCESSING = YES
STRIP_INSTALLED_PRODUCT   = YES
STRIP_STYLE               = all
```

But frameworks built by Swift Package Manager do not read these settings, so they can ship with every local symbol. Check with `nm`. A run-script phase can run `xcrun strip -x` on each embedded framework and sign it again. Make sure the dSYMs are generated before this phase, so their UUIDs still match, and confirm with a crash from a TestFlight build.

The app executable has a smaller version of the same waste. Nothing links against an app, yet it exports every symbol. An `EXPORTED_SYMBOLS_FILE` with a single line, `__mh_execute_header`, shrinks its export table to almost nothing. Keep it out of Debug, and out of any test target that uses the app as its `BUNDLE_LOADER`.

## 5. Assets, fonts, and sounds

Usually there is no single big file. It is a long tail of small ones:

- **Localization:** shared packages often bring bundles with dozens of languages that your app never reads.
- **Animations:** Lottie files that came along with a shared package, for a feature you do not have.
- **Fonts:** check that each font in `UIAppFonts` registers and is used. Fonts that fail to register, often because another package already did, still ship.
- **Images:** resize to the size they are shown at. A 512-pixel image shown at 55 points has almost ten times the pixels it needs at 3×. Opaque PNGs are usually much smaller as JPEGs.
- **Sounds:** a short system-style sound does not need 48 kHz stereo.

## 6. Do not forget the extensions

Nobody looks at app extensions. Check each one for:

- an icon or image far larger than it is shown;
- source files compiled in that only the app uses;
- a whole SDK linked for one or two calls;
- a Release configuration still using `-Onone`.

Extensions have tight memory limits, so this also makes them more reliable, not only smaller.

## How to measure

You do not need a dashboard. Measure every change on a clean Release archive for arm64, with:

- the size of each stripped Mach-O binary, before and after;
- the number of embedded frameworks, and `otool -L` for what each binary loads;
- `nm` for the number of local symbols in each framework;
- the size of each `Assets.car`;
- `codesign --verify --deep --strict` after every change that touches signing;
- `xcodebuild -showBuildSettings` for what the build really uses.

One rule made the biggest difference: a pull request that claims a saving shows the numbers.

## Takeaways

1. **Check what the build really uses, not what you wrote.**
2. **Static linking is not free.** Map the dependency graph first.
3. **Swift packages do not read your app's settings.** Optimize and strip them separately.
4. **Delete before you optimize.** The cheapest byte to compress is one you do not ship.
5. **Look at the extensions.** They are small, so nobody checks them.
