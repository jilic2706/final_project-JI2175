//
//  LocationsViewModel.swift
//  final_project-JI2175
//
//  Created by Illy Byos on 10.12.2021..
//

import Foundation
import Combine

final class LocationsViewModel: ObservableObject {
    @Published private(set) var data: [Location] = []
    
    private var cancellable: Set<AnyCancellable> = []
    
    init() {
        getData()
        if(self.data.isEmpty) {
            getDataFromLocalJSON()
        }
    }
    
    func getData() {
        guard let url = URL(string: "http://mhfudb.mocklab.io/locations") else {
            fatalError("---! An error has occured while trying to create the URL !---")
        }
        
        let jsonDecoder = JSONDecoder()
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap({ $0.data })
            .decode(type: [Location].self, decoder: jsonDecoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { print($0) },
                  receiveValue: {
                    self.data = $0
                  })
            .store(in: &cancellable)
    }
    
    func getDataFromLocalJSON() {
        if let localJSONPath = Bundle.main.url(forResource: "Locations", withExtension: "json") {
            do {
                let data = try Data(contentsOf: localJSONPath)
                let dataFromJSON = try JSONDecoder().decode([Location].self, from: data)
                self.data = dataFromJSON
            } catch {
                print(error)
            }
        }
    }
}
