//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSCognitoIdentityProvider

class AWSAuthConfirmSignUpTask: AuthConfirmSignUpTask, DefaultLogger {

    private let request: AuthConfirmSignUpRequest
    private let authEnvironment: AuthEnvironment

    var eventName: HubPayloadEventName {
        HubPayload.EventName.Auth.confirmSignUpAPI
    }

    init(_ request: AuthConfirmSignUpRequest, authEnvironment: AuthEnvironment) {
        self.request = request
        self.authEnvironment = authEnvironment
    }

    func execute() async throws -> AuthSignUpResult {
        try request.hasError()
        let userPoolEnvironment = authEnvironment.userPoolEnvironment
        do {

            let asfDeviceId = try await CognitoUserPoolASF.asfDeviceID(
                for: request.username,
                credentialStoreClient: authEnvironment.credentialsClient)
            let metadata = (request.options.pluginOptions as? AWSAuthConfirmSignUpOptions)?.metadata
            let forceAliasCreation = (request.options.pluginOptions as? AWSAuthConfirmSignUpOptions)?.forceAliasCreation
            let client = try userPoolEnvironment.cognitoUserPoolFactory()
            let input = await ConfirmSignUpInput(username: request.username,
                                           confirmationCode: request.code,
                                           clientMetadata: metadata,
                                           asfDeviceId: asfDeviceId,
                                           forceAliasCreation: forceAliasCreation,
                                           environment: userPoolEnvironment)
            _ = try await client.confirmSignUp(input: input)
            log.verbose("Received success")
            return AuthSignUpResult(.done, userID: nil)
        } catch let error as AuthErrorConvertible {
            throw error.authError
        } catch {
            throw AuthError.configuration(
                "Unable to create a Swift SDK user pool service",
                AuthPluginErrorConstants.configurationError,
                error
            )
        }
    }
}
