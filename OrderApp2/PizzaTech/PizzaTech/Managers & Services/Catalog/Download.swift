//
//  Download.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import Foundation

extension CatalogService {
    private func startDownload() {
        logger.debug("Starting download of catalog data.")
        
        downloadInProgress = true
        downloadInProgress = false
        downloadErrorOccurred = false
        
        var catalogRequest = URLRequest(
            url: BackendAPI.downloadCatalogURL,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        catalogRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: catalogRequest) { data, _, error in
            if let data = data {
                var decodedData: Catalog? = nil
                
                let jsonDecoder = JSONDecoder()
                do {
                    decodedData = try jsonDecoder.decode(Catalog.self, from: data)
                } catch {
                    print(error)
                    logger.error("Returned catalog data couldn't be decoded to valid JSON: \(error.localizedDescription)")
                }
                
                if decodedData != nil {
                    logger.debug("Successfully downloaded catalog.")
                    self.catalog = decodedData
                }
            }
            
            if let error = error {
                logger.error("Error occurred downloading catalog data: \(error.localizedDescription)")
                self.downloadErrorOccurred = true
            }
        }.resume()
    }
    
    func fetchCatalog() {
        #if PREVIEW
            catalog = loadPreviewJSON("CatalogPreview")
        #else
            startDownload()
        #endif
    }
}
