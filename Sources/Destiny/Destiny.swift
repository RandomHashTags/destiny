//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Utilities
import HTTPTypes

@freestanding(expression)
public macro router(version: String, middleware: [Middleware], _ routes: Route...) -> Router = #externalMacro(module: "Macros", type: "Router")