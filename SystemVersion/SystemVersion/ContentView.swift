//
//  ContentView.swift
//  SystemVersion
//
//  Created by Volodymyr Myroniuk on 19.03.2024.
//

import SwiftUI

@Observable final class ViewModel {
    private let _CFCopySystemVersionDictionary: (@convention(c) () -> CFDictionary)? = {
        let handle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY)
        let function = dlsym(handle, "_CFCopySystemVersionDictionary")
        let signature = (@convention(c) () -> CFDictionary)?.self
        return unsafeBitCast(function, to: signature)
    }()
    
    var items = [String]()
    
    func load() {
        guard let versionDictionary: NSDictionary = _CFCopySystemVersionDictionary?() else {
            items = ["No any information"]
            return
        }
        items = versionDictionary.allKeys.map { "\($0): \(versionDictionary[$0] ?? "no information")" }
    }
}

struct ContentView: View {
    @Bindable var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Button("Print System Version") {
                viewModel.load()
            }
            List {
                ForEach($viewModel.items, id: \.self) { item in
                    Text(item.wrappedValue)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
