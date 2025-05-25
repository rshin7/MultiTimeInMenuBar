//
//  TimezoneRowView.swift
//  MultiTimeInMenuBar
//
//  Created by Richard Shin on 4/6/25.
//


// TimezoneRowView.swift
// MultiTimeInMenuBar

import SwiftUI

struct TimezoneRowView: View {
    @Binding var item: TimezoneItem
    var deleteAction: () -> Void

    @FocusState private var prefixIsFocused: Bool
    @State private var isEditing = false
    @State private var tempPrefix: String = ""

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .frame(width: 16)

            if isEditing {
                TextField("Prefix", text: $tempPrefix)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .focused($prefixIsFocused)
                    .onAppear { prefixIsFocused = true }
                    .onSubmit {
                        tempPrefix = String(tempPrefix.prefix(15))
                        item.customPrefix = tempPrefix.isEmpty ? nil : tempPrefix
                        isEditing = false
                    }
            } else {
                if let prefix = item.customPrefix, !prefix.isEmpty {
                    Text(prefix)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 40, alignment: .leading)
                        .padding(.leading, 4)
                } else {
                    Image(nsImage: flagImage(for: item.timezoneID))
                        .resizable()
                        .frame(width: 20, height: 14)
                        .cornerRadius(2)
                        .frame(width: 40, alignment: .leading)
                        .padding(.leading, 4)
                }
            }

            Text(item.cityName ?? item.timezoneID)
                .frame(minWidth: 130, alignment: .leading)

            Spacer()

            Button {
                if isEditing {
                    tempPrefix = String(tempPrefix.prefix(15))
                    item.customPrefix = tempPrefix.isEmpty ? nil : tempPrefix
                } else {
                    tempPrefix = item.customPrefix ?? ""
                }
                isEditing.toggle()
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(BorderlessButtonStyle())

            Button(action: deleteAction) {
                Image(systemName: "xmark")
            }
            .foregroundColor(.red)
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }

    func flagImage(for timezoneID: String) -> NSImage {
        return TimezoneUtils.flagImage(for: timezoneID)
    }
}
