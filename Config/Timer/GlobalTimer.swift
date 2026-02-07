//
//  GlobalTimer.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit

@MainActor
final class GlobalTimer {

    // MARK: - Singleton

    static let shared = GlobalTimer()

    // MARK: - Properties

    private var displayLink: CADisplayLink?
    private var handlers: [UUID: HandlerEntry] = [:]
    private(set) var isRunning: Bool = false

    var handlerCount: Int { handlers.count }

    // MARK: - Initialization

    private init() {
        observeAppLifecycle()
    }

    // MARK: - Handler Entry

    private struct HandlerEntry {
        let key: String?
        let block: () -> Void
    }

    // MARK: - Public Methods

    @discardableResult
    func addHandler(key: String? = nil, _ block: @escaping () -> Void) -> UUID {
        if let key {
            if let existing = handlers.first(where: { $0.value.key == key }) {
                handlers[existing.key] = nil
            }
        }
        let id = UUID()
        handlers[id] = HandlerEntry(key: key, block: block)
        if handlers.count == 1 { start() }
        return id
    }

    func removeHandler(_ id: UUID) {
        handlers[id] = nil
        if handlers.isEmpty { stop() }
    }

    func removeHandler(forKey key: String) {
        let matching = handlers.filter { $0.value.key == key }.map(\.key)
        matching.forEach { handlers[$0] = nil }
        if handlers.isEmpty { stop() }
    }

    func removeAllHandlers() {
        handlers.removeAll()
        stop()
    }

    // MARK: - Private Methods

    private func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 30)
        link.add(to: .main, forMode: .common)
        displayLink = link
        isRunning = true
    }

    private func stop() {
        displayLink?.invalidate()
        displayLink = nil
        isRunning = false
    }

    @objc private func tick() {
        handlers.values.forEach { $0.block() }
    }

    // MARK: - App Lifecycle

    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.pause() }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.resume() }
        }
    }

    private func pause() {
        displayLink?.isPaused = true
    }

    private func resume() {
        guard !handlers.isEmpty else { return }
        if displayLink == nil {
            start()
        } else {
            displayLink?.isPaused = false
        }
    }
}
