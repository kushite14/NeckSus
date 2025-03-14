//
//  NavigationPathEnv.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 11/03/2025.
//
import SwiftUI

struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath> = .constant(NavigationPath())
}

extension EnvironmentValues {
    var navigationPath: Binding<NavigationPath> {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}
