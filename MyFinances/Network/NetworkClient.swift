//
//  NetworkClient.swift
//  MyFinances
//
//  Created by Артём on 17.07.2025.
//

import Foundation

// MARK: - Network Client
final class NetworkClient {
    let session: URLSession
    private let token: String

    init(token: String, session: URLSession = .shared) {
        self.token = token
        self.session = session
    }

    // MARK: - Request without body (GET, DELETE)
    func request<ResponseBody: Decodable>(
        url: URL,
        method: String = NetworkConstants.Methods.get
    ) async throws -> ResponseBody {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(NetworkConstants.Headers.bearerPrefix + token, forHTTPHeaderField: NetworkConstants.Headers.authorization)
        request.setValue(NetworkConstants.Headers.jsonContentType, forHTTPHeaderField: NetworkConstants.Headers.contentType)
        return try await performRequest(request, responseType: ResponseBody.self)
    }

    // MARK: - Request with body (POST, PUT, PATCH)
    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        url: URL,
        method: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(NetworkConstants.Headers.bearerPrefix + token, forHTTPHeaderField: NetworkConstants.Headers.authorization)
        request.setValue(NetworkConstants.Headers.jsonContentType, forHTTPHeaderField: NetworkConstants.Headers.contentType)
        do {
            let bodyData = try JSONEncoder().encode(body)
            request.httpBody = bodyData
        } catch {
            throw NetworkError.encodingFailed(error)
        }
        return try await performRequestWithBody(request, body: body, responseType: ResponseBody.self)
    }

    private func performRequest<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            if httpResponse.statusCode == 204 {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw NetworkError.invalidResponse
            }
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            } else {
                throw NetworkError.httpError(code: httpResponse.statusCode, data: data)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.network(error)
        }
    }
    
    private func performRequestWithBody<T: Encodable, R: Decodable>(_ request: URLRequest, body: T, responseType: R.Type) async throws -> R {
        var mutableRequest = request
        do {
            let bodyData = try JSONEncoder().encode(body)
            mutableRequest.httpBody = bodyData
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw NetworkError.encodingFailed(error)
        }
        do {
            let (data, response) = try await session.data(for: mutableRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                do {
                    return try JSONDecoder().decode(R.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            } else {
                throw NetworkError.httpError(code: httpResponse.statusCode, data: data)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.network(error)
        }
    }
}
