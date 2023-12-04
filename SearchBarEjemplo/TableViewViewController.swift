//
//  ViewController.swift
//  SearchBarEjemplo
//
//  Created by Jorge Abalo Dieste on 26/11/23.
//
import UIKit
import CryptoKit
import CommonCrypto

class Personaje {
    var name: String

    init(name: String) {
        self.name = name
    }
}

class TableViewViewController: UIViewController {
    
    var personajes: [Personaje] = []
    var personajesFiltrados: [Personaje] = []
    
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Definir los delegados de la tabla
        // Definir el delegado del searchBar
        searchBar.delegate = self
        tabla.delegate = self
        tabla.dataSource = self
        
        obtenerPersonajesDesdeAPI()
    }
    
    func obtenerPersonajesDesdeAPI() {
        let publicKey = "91876cd71efdc7d4d08056257a5dd7bf"
        let privateKey = "4b31ba5c27608c34ec0d47763e976f32001d59e6"
        let baseURL = "https://gateway.marvel.com/v1/public/characters"
        
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration)
        
        // Construir la URL con las claves y otros parámetros
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = "\(timestamp)\(privateKey)\(publicKey)".md5()
        let urlString = "\(baseURL)?apikey=\(publicKey)&ts=\(timestamp)&hash=\(hash)"
        if let url = URL(string: urlString) {
            // Crear y configurar la sesión de URLSession
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let data = data {
                    // Procesar los datos obtenidos
                    // Puedes implementar el código necesario para manejar la respuesta de la API
                    print("Data received: \(data)")
                }
            }
            // Iniciar la tarea
            task.resume()
        } else {
            print("Invalid URL")
        }
    }
}

// Función para calcular el hash MD5
extension String {
    func md5() -> String {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let baseAddress = messageBytes.baseAddress, let data = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let length = CC_LONG(messageData.count)
                    CC_MD5(baseAddress, length, data)
                }
                return 0
            }
        }
        
        // Convertir el resultado de CC_MD5 a una cadena hexadecimal
        let hash = digestData.map { String(format: "%02hhx", $0) }.joined()
        return hash
    
    }
}


// Métodos SearchBar
extension TableViewViewController: UISearchBarDelegate {
    // Identificar cuando el usuario empieza a escribir
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        personajesFiltrados = []
        
        if searchText == "" {
            personajesFiltrados = personajes
        } else {
            for personaje in personajes {
                if personaje.name.lowercased().contains(searchText.lowercased()) {
                    personajesFiltrados.append(personaje)
                }
            }
        }
        
        // Actualizar la tabla constantemente cuando se escriba el texto.
        DispatchQueue.main.async {
            // Actualizar la interfaz aquí
            self.tabla.reloadData()
        }

      
    }
}

// Métodos UITableView
extension TableViewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personajesFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tabla.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        celda.textLabel?.text = personajesFiltrados[indexPath.row].name
        
        return celda
    }
}
