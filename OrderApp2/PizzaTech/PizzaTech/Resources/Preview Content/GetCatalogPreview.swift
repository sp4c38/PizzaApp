//
//  GetCatalogPreview.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import Foundation

/// Load preview JSON from the apps main bundle. Parse the filename without the .json extension.
func loadPreviewJSON<T: Decodable>(_ filename: String) -> T {
    guard let filePath = Bundle.main.url(forResource: filename, withExtension: "json") else {
        fatalError("Couldn't find catalog preview file named \(filename).")
    }

    let catalogData: Data
    do {
        catalogData = try Data(contentsOf: filePath)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle: \(error).")
    }
    
    let decoder = JSONDecoder()
    do {
        let decodedData = try decoder.decode(T.self, from: catalogData)
        return decodedData
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self): \(error).")
    }
}
