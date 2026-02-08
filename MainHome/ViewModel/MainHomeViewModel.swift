//
//  MainHomeViewModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation
import Combine

// MARK: - MainHomeViewModel

final class MainHomeViewModel {

    @Published private(set) var carouselItems: [MainCarouselModel] = []
    @Published private(set) var carouselError: Error?

    private let service: MainHomeServiceProtocol

    init(service: MainHomeServiceProtocol = MainHomeService()) {
        self.service = service
    }

    func loadCarousel() {
        Task { @MainActor in
            carouselError = nil
            do {
                carouselItems = try await service.fetchTodayCarouselEvents()
            } catch {
                carouselError = error
                carouselItems = []
            }
        }
    }
}
