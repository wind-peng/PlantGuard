import UIKit
import WebKit

/// PlantGuard: a WKWebView shell around the 植物守卫 word-learning game.
///
/// Landscape is the main experience: the app imposes NO orientation lock.
/// All four orientations are declared in Info.plist for iPhone and iPad,
/// and the web view resizes freely on rotation. In landscape the game shows
/// its wide lawn (8 columns, plant bar along the bottom); portrait works too.
///
/// Content updates: the game HTML lives on GitHub Pages. On launch the app
/// fetches version.json (8s timeout). If the remote version is newer than the
/// stored version, it downloads index.html, saves it locally and loads it.
/// If offline or the fetch fails, it loads the locally cached copy. If there
/// is no cache at all (first launch, no network), it loads the copy bundled
/// inside the app, so the game always opens.
class ViewController: UIViewController {

    private static let remoteBase = "https://wind-peng.github.io/PlantGuard/"
    private static let versionURL = URL(string: remoteBase + "version.json")!
    private static let gameURL = URL(string: remoteBase + "index.html")!

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        // Sounds (sun taps, quiz, effects) must play without a prior
        // media gesture requirement; the game is tap-driven anyway.
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        self.webView = webView

        updateAndLoad()
    }

    // MARK: - Local cache

    private var gameDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("game", isDirectory: true)
    }

    private var cachedGameURL: URL {
        gameDir.appendingPathComponent("index.html")
    }

    private func storedVersion() -> Int {
        UserDefaults.standard.integer(forKey: "plantguardGameVersion")
    }

    private func setStoredVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: "plantguardGameVersion")
    }

    // MARK: - Update check

    private func updateAndLoad() {
        var request = URLRequest(url: Self.versionURL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 8)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self else { return }
            var remoteVersion = 0
            if let data = data,
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let version = obj["version"] as? Int {
                remoteVersion = version
            }
            if remoteVersion > 0 && remoteVersion > self.storedVersion() {
                self.downloadGame(version: remoteVersion)
            } else {
                DispatchQueue.main.async { self.loadLocalOrBundled() }
            }
        }
        task.resume()
    }

    private func downloadGame(version: Int) {
        var request = URLRequest(url: Self.gameURL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 120)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data, !data.isEmpty {
                do {
                    try FileManager.default.createDirectory(at: self.gameDir,
                                                            withIntermediateDirectories: true)
                    try data.write(to: self.cachedGameURL, options: .atomic)
                    self.setStoredVersion(version)
                } catch {
                    // Keep the old cache / bundled copy; load proceeds below.
                }
            }
            DispatchQueue.main.async { self.loadLocalOrBundled() }
        }
        task.resume()
    }

    // MARK: - Load

    private func loadLocalOrBundled() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: cachedGameURL.path) {
            webView.loadFileURL(cachedGameURL, allowingReadAccessTo: gameDir)
            return
        }
        if let bundled = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(bundled, allowingReadAccessTo: bundled.deletingLastPathComponent())
        }
    }
}
